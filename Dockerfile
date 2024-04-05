# VSCode XP Web: VSCode XP Web Environment Dockerfile. ARM support
# Author: Gennadiy Mukhamedzyanov (@GenRockeR)
# License: GPL3

FROM --platform=linux/arm64 debian:10-slim

LABEL maintainer="Gennadiy Mukhamedzyanov (@GenRockeR)"
LABEL description="Dockerfile for XP web workspace for MacOS ARM devices"

ARG NB_USER
ENV NB_USER coder
ENV HOME /home/${NB_USER}
ENV PATH "$HOME/.local/bin:$PATH"
ENV USER_SETTINGS $HOME/.local/share/code-server/User
ENV DEBIAN_FRONTEND=noninteractive

COPY files/entrypoint.sh /usr/bin/entrypoint.sh
COPY files/kbt.26.2.373-debian-10.zip /tmp

RUN apt update && apt dist-upgrade -y && \
    apt install -y \
        curl \
        python3 \
        python3-pip \
        git \
        unzip \
        wget \
	    binfmt-support \
        qemu-user-static  \
        gcc-8 \
        libyajl-dev \
        pkg-config \
        dumb-init  \
        sudo \
        ca-certificates \
        apt-utils \
        gnupg && \
    dpkg --add-architecture amd64 && \
    wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
    apt update && \
    apt install -y \
        dotnet-sdk-6.0 \
        libc6:amd64 \
        libyajl2:amd64 && \
    pip3 install -U pip && \
    pip3 install ijson==2.3 && \
    apt install -y nodejs && \
    npm install -g npm@10.5.0 && \
    npm install -g yarn && \
    npm install -g code-server --unsafe-perm && \
    yarn global add node-gyp && \
    yarn --cwd /usr/lib/node_modules/code-server/lib/vscode --production --frozen-lockfile --no-default-rc && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5.1/fixuid-0.5.1-linux-arm64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: ${NB_USER}\ngroup: ${NB_USER}\n" > /etc/fixuid/config.yml

RUN adduser --gecos '' --disabled-password ${NB_USER} && \
    echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER ${NB_USER}
WORKDIR ${HOME}

RUN sudo chown -R ${NB_USER}:${NB_USER} ${HOME} && \
    sudo chown ${NB_USER}:${NB_USER} /tmp/kbt.26.2.373-debian-10.zip && \
#    sudo wget https://github.com/vxcontrol/xp-kbt/releases/download/26.0.4369/kbt.26.0.4369-debian-10.zip  \
#    -O /tmp/xp-kbt.zip && \
    sudo unzip /tmp/kbt.26.2.373-debian-10.zip -d ${HOME}/xp-kbt && \
    sudo rm -rf /tmp/kbt.26.2.373-debian-10.zip && \
    git clone https://github.com/Security-Experts-Community/open-xp-rules.git && \
    sudo chown -R ${NB_USER}:${NB_USER} ${HOME} && \
    mkdir -p ${USER_SETTINGS} && \
    echo '{"xpConfig.kbtBaseDirectory":"${HOME}/xp-kbt","cSpell.language":"en,ru","cSpell.enableFiletypes":["xp"]}' \
    | python3 -m json.tool > ${USER_SETTINGS}/settings.json && \
    mkdir -p ./open-xp-rules/.vscode && \
    mkdir /tmp/vscode-xp && \
    echo '{"xpConfig.outputDirectoryPath": "/tmp/vscode-xp"}' | python3 -m json.tool  >  \
      ./open-xp-rules/.vscode/settings.json && \
    code-server --install-extension SecurityExpertsCommunity.xp && \
    code-server --install-extension streetsidesoftware.code-spell-checker-russian && \
    code-server --install-extension MS-CEINTL.vscode-language-pack-ru && \
    sudo apt clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Allow users to have scripts run on container startup to prepare workspace.
# https://github.com/coder/code-server/issues/5177
ENV ENTRYPOINTD=${HOME}/entrypoint.d

EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]

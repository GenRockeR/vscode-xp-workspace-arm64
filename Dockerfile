# VSCode XP Web: VSCode XP Web Environment Dockerfile. ARM support
# Author: Gennadiy Mukhamedzyanov (@GenRockeR)
# License: MIT

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
    curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh && \
    sudo -E bash nodesource_setup.sh && \
    apt update && \
    apt install -y \
        dotnet-sdk-6.0 \
        libc6:amd64 \
        libyajl2:amd64 && \
    pip3 install -U pip && \
    pip3 install ijson==2.3 && \
    apt install -y nodejs && \
    npm install -g npm@10.9.0 && \
    npm install -g yarn && \
    npm install -g code-server --unsafe-perm && \
    yarn global add node-gyp && \
    yarn --cwd /usr/lib/node_modules/code-server/lib/vscode --production --frozen-lockfile --no-default-rc && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-arm64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: ${NB_USER}\ngroup: ${NB_USER}\n" > /etc/fixuid/config.yml

RUN adduser --gecos '' --disabled-password ${NB_USER} && \
    echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER ${NB_USER}
WORKDIR ${HOME}

RUN sudo chown -R ${NB_USER}:${NB_USER} ${HOME} && \
    mkdir -p ${HOME}/xp-kbt && \
    wget -c https://github.com/vxcontrol/xp-kbt/releases/download/27.0.78/kbt.27.0.78-linux.tar.gz -O \
    /tmp/kbt.27.0.78-linux.tar.gz && \
    tar zxvf /tmp/kbt.27.0.78-linux.tar.gz -C ${HOME}/xp-kbt && \
    rm -rf /tmp/kbt.27.0.78-linux.tar.gz && \
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

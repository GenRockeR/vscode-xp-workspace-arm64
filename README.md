# vscode-xp-workspace-arm64

Данный проект помогает автоматизировать развёртывание рабочего окружения для написания правил на языке XP (MacOS ARM64).

<p align="center">
  <img alt="XP Workspace in action" src="https://user-images.githubusercontent.com/61383585/236648422-aeb606f4-5e65-4914-b804-09b9cc97d399.png">
</p>

При создании рабочего окружения используются проекты:
- [code-server](https://coder.com/docs/code-server/latest/install)
- [open-xp-rules](https://github.com/Security-Experts-Community/open-xp-rules)
- [xp-kbt](https://github.com/vxcontrol/xp-kbt)

## Начало работы

### Требования
Для работы вам понадобится любой современный браузер и актуальная версия [Docker](https://www.docker.com/).

### Запуск
0. Получите kbt файлы от PT.
1. Скачайте репозиторий [vscode-xp-workspace-arm64](https://github.com/GenRockeR/vscode-xp-workspace-arm64).
2. В командной оболочке перейдите в папку `vscode-xp-workspace-arm64`
3. Выполните команду `docker compose up`.
4. Дождитесь окончания запуска окружения, когда появится надпись ` HTTP server listening on http://0.0.0.0:8080/`
5. Откройте в браузере ссылку http://localhost:3505/?folder=/home/coder/open-xp-rules. Вас попросят ввести пароль.
6. Для получения пароля выполните команду:
`docker exec vscode-xp-workspace grep 'password:' /home/coder/.config/code-server/config.yaml`
7. Окружение готово к работе, успехов в исследованиях! 

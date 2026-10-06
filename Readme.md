<h1 align="center">
  <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/webp/cloudflare.webp" height="30" style="border-radius: 50%; vertical-align: middle;" alt="Cloudflare WARP"> Cloudflare WARP
</h1>
<p align="center"><i>Генератор конфигурации Cloudflare WARP для AmneziaVPN</i></p>

## Способ 1: Веб-версия

**Самый простой способ** - сгенерировать конфигурацию прямо в браузере, без установки и терминала.

1. Откройте <a href="https://cloudflare-warp-web.vercel.app/"><img src="https://img.shields.io/badge/Cloudflare_WARP-Web-f6821f?style=flat&logo=cloudflare&logoColor=white&labelColor=f6821f&color=808080" alt="Cloudflare WARP Web"></a>
2. Выберите нужные параметры и нажмите «Сгенерировать конфигурацию».
3. Скачайте `.conf` файл и импортируйте его в AmneziaVPN или AmneziaWG.

## Способ 2: H2 Nexus
1. Перейдите на сайт [h2.nexus](https://h2.nexus/ru/cli)
2. Выберите опцию **`Linux (Terminal)`**
3. Дождитесь завершения установки и запуска сервера.
4. Вставьте в терминал следующую команду (Shift + Insert):
```bash
bash <(wget --inet4-only -qO- https://raw.githubusercontent.com/smi-falcon/Cloudflare-WARP/main/warp_generator.sh)
```
5. После завершения генерации скопируйте полученный конфиг и импортируйте его в приложение AmneziaVPN или AmneziaWG.

## Способ 3: pad.ws
1. Перейдите на сайт [pad.ws](https://pad.ws).
2. Авторизуйтесь через Google (Continue with Google).
3. На панели управления (Dashboard) нажмите кнопку **`Start`**, если она отображается.
4. Откройте вкладку **`Terminal`**.
5. Вставьте в терминал следующую команду (Shift + Insert):
```bash
bash <(wget --inet4-only -qO- https://raw.githubusercontent.com/smi-falcon/Cloudflare-WARP/main/warp_generator.sh)
```
6. После завершения генерации скопируйте полученный конфиг и импортируйте его в приложение AmneziaVPN или AmneziaWG.

## Способ 4: Replit
1. Перейдите по ссылке: [![Run on Repl.it](https://repl.it/badge/github/replit/upm)](https://replit.com/new/github/smi-falcon/Cloudflare-WARP)
2. Создайте учётную запись.
3. Нажмите кнопку **`Run`** в верхней части интерфейса.
4. После завершения генерации скопируйте полученный конфиг и импортируйте его в приложение AmneziaVPN или AmneziaWG.

## Способ 5: GitHub Codespaces
1. Перейдите по ссылке: https://github.com/smi-falcon/Cloudflare-WARP/codespaces
2. При необходимости авторизуйтесь в GitHub.
3. Нажмите кнопку **`Create codespace on main`**
4. Дождитесь загрузки среды.
5. Вставьте в терминал следующую команду (Shift + Insert):
```bash
bash warp_generator.sh
```
6. После завершения генерации скопируйте полученный конфиг и импортируйте его в приложение AmneziaVPN или AmneziaWG.
7. По окончании работы рекомендуется удалить codespace:  
   - Перейдите в раздел https://github.com/smi-falcon/Cloudflare-WARP/codespaces
   - Нажмите на значок с тремя точками и выберите **`Delete`**
- *Обратите внимание: GitHub автоматически останавливает неактивные codespaces, однако рекомендуется удалять их вручную.*

### Клиенты:

| Приложение | Платформа | Ссылка |
|------------|-----------|--------|
| **AmneziaVPN** | Android, Linux, macOS, Windows | [GitHub](https://github.com/amnezia-vpn/amnezia-client) |
| **AmneziaWG** | Windows | [GitHub](https://github.com/amnezia-vpn/amneziawg-windows-client) |

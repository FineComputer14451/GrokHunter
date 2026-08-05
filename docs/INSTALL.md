# Install — GrokHunter Rootless

AI coding & building lab for **unrooted Android** (Termux + proot + Grok Build).

## Requirements

- Termux from **F-Droid or GitHub** (not Play Store)
- Android 8+ (aarch64 recommended)
- **No root required**
- Stable internet
- SuperGrok / X Premium+ **or** `XAI_API_KEY` for Grok Build

## One-liner

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)
```

### Recommended full stack

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh) \
  --full --de xfce --browser chromium --with-grok --with-x11
```

Installs:

- Latest Kali NetHunter rootfs (rootless)
- XFCE desktop
- Chromium
- Grok Build CLI
- Termux:X11 helper (`nh-x11`)

## Clone install

```bash
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter
bash install.sh --full --de xfce --with-grok --with-x11
```

## CLI flags

```
-f, --full              Full installation (desktop-oriented)
-m, --mini              Mini (essential packages)
-n, --nano              Nano (minimal)
--de <desktop>          e17 | gnome | i3 | kde | lxde | mate | xfce
--browser <browser>     chromium | firefox | both
--no-de                 Skip desktop environment
--with-grok             Install native Grok Build CLI
--no-grok               Skip Grok Build
--with-x11              Install Termux:X11 + nh-x11
--no-x11                Skip Termux:X11
-h, --help              Show help
```

## After install

```bash
# Enter Kali (rootless)
nethunter

# Pair programming
grok
# or headless
grokhunter -p "your task"

# Desktop (install Termux:X11 APK first)
nh-x11

# Health check
grokhunter doctor
```

### Termux:X11 APK

Download from: https://github.com/termux/termux-x11/releases

### Auth

```bash
# API key (recommended on mobile)
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env
chmod 600 ~/.grok/secrets.env
```

Or run `grok` once and complete browser login if available.

## Optional: Aider

See [EDITORS.md](EDITORS.md) for Aider + Grok setup.

## Uninstall

```bash
bash uninstall.sh
# or destructive Grok purge:
bash uninstall.sh --purge-grok
```

## Next

- [FAQ](FAQ.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Architecture](ARCHITECTURE.md)
- [Editors & pair tools](EDITORS.md)

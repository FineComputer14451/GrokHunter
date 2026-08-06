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
--with-grok             Install Grok Build CLI (shared ensure script)
--no-grok               Skip Grok Build
--with-x11              Install Termux:X11 + nh-x11
--no-x11                Skip Termux:X11
--with-aider            Install Aider (venv + xAI helper)
--no-aider              Skip Aider
-h, --help              Show help
```

## Environment overrides

| Variable | Purpose |
|----------|---------|
| `GROKHUNTER_REFRESH=1` | Bypass module + engine cache |
| `GROKHUNTER_DISTRO_ENGINE_URL` | Pin/fork of `termux-distro.sh` (default: jorexdeveloper main) |
| `GROKHUNTER_GROK_INSTALLER` | `auto` \| `official` \| `termux-native` |
| `GROKHUNTER_FORCE_GROK=1` | Reinstall Grok even if present |
| `NH_X11_SESSION` | Desktop start command for `nh-x11` (e.g. `startlxde`) |

**Engine resolution order:** vendored `./termux-distro.sh` next to `install.sh` → `~/.cache/grokhunter/termux-distro.sh` → download into that cache (never CWD).

## Chromium under proot

If you install Chromium, the desktop entry is patched with **`--no-sandbox`**. User namespaces are unavailable in proot, so Chromium will not start without it. Treat this as a **security tradeoff**: fine for casual browsing in a lab; do not use for banking or high-sensitivity sessions. Prefer Firefox ESR when possible.

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

# GrokHunter

**Kali NetHunter powered by Grok Build — AI-agent mobile lab overlay & one-command installer**

GrokHunter turns a rootless Kali NetHunter install on Termux into an AI-agent-first mobile penetration testing and builder environment, powered by [Grok Build](https://x.ai/cli).

> Not affiliated with xAI or Offensive Security.

---

## Quick Install

```bash
# One-liner (recommended)
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)

# Or clone first
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter
bash install.sh
```

### Recommended full install (NetHunter + XFCE + Chromium + Grok Build + Termux:X11)

```bash
bash install.sh --full --de xfce --browser chromium --with-grok --with-x11
```

---

## Features

| Feature | Description |
|---------|-------------|
| **Dynamic rootfs** | Always pulls the latest Kali NetHunter rootfs from `/current/` |
| **Official SHA256** | Verifies against live Kali SHA256SUMS |
| **Grok Build native** | Optional install of native Termux Grok Build CLI (`--with-grok`) |
| **Termux:X11** | Low-latency desktop integration with `nh-x11` helper (`--with-x11`) |
| **CLI automation** | Fully non-interactive mode with sensible defaults |
| **XFCE default** | Lightweight desktop recommended for Android |
| **Multi-arch** | arm64, armhf, amd64, i386 |

---

## CLI Options

```
-f, --full              Full installation (includes desktop environment)
-m, --mini              Mini installation (essential packages only)
-n, --nano              Nano installation (minimal footprint)
--de <desktop>          Desktop environment (e17|gnome|i3|kde|lxde|mate|xfce)
--browser <browser>     Browser: chromium | firefox | both
--no-de                 Skip desktop environment
--with-grok             Install native Grok Build CLI
--no-grok               Skip Grok Build
--with-x11              Install & configure Termux:X11 + nh-x11 helper
--no-x11                Skip Termux:X11 setup
-h, --help              Show help
```

---

## After Install

```bash
nethunter          # Enter Kali shell
nh-x11             # Launch low-latency desktop (if --with-x11 was used)
grok               # Launch Grok Build TUI (if --with-grok was used)
```

**Termux:X11 note:** You still need the Termux:X11 APK from the [official nightly releases](https://github.com/termux/termux-x11/releases).

---

## Requirements

- Termux (from F-Droid or GitHub, **not** Play Store)
- Android 8+ (aarch64 recommended)
- Stable internet
- SuperGrok / X Premium+ **or** `XAI_API_KEY` for Grok Build

---

## License

GPL-3.0 (inherits from the original termux-nethunter / termux-distro work)  
GrokHunter enhancements © 2026 FineComputer14451 / Grok (xAI)

---

## Credits

- Original termux-nethunter by [jorexdeveloper](https://github.com/jorexdeveloper)
- Grok Build by xAI
- Termux:X11 by the Termux team

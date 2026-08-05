# GrokHunter Rootless

**Kali NetHunter Rootless × Grok Build — AI-agent mobile lab for unrooted Android**

GrokHunter turns **rootless** Kali NetHunter (Termux + proot) into an AI-agent-first mobile penetration testing and builder environment, powered by [Grok Build](https://x.ai/cli).

No root. No custom kernel. No warranty void.

> Not affiliated with xAI or Offensive Security.

---

## Quick Install (Rootless)

```bash
# One-liner
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)

# Or clone
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter
bash install.sh
```

### Recommended full stack

```bash
bash install.sh --full --de xfce --browser chromium --with-grok --with-x11
```

Installs:
- Latest **rootless** Kali NetHunter rootfs (`/current/`)
- XFCE desktop
- Chromium
- Native Grok Build CLI
- Termux:X11 low-latency desktop + `nh-x11` helper

---

## Why Rootless?

| | Rootless (GrokHunter) | Rooted NetHunter |
|--|----------------------|------------------|
| Root required | **No** | Yes |
| Warranty | Intact | Often voided |
| Install | Termux + proot | Custom recovery / Magisk |
| Grok Build | Native static binary | Same |
| HID / Mana / firmware | Limited | Full |
| Target users | Most Android devices | Advanced / unlocked devices |

GrokHunter is designed exclusively for the **rootless** path. It does not install or depend on Magisk, custom kernels, or HID modules.

---

## Architecture

```
install.sh              Thin entry point (one-command / curl|bash)
lib/
  ├── cli.sh            Argument parsing & help
  ├── actions.sh        Install / config / DE / browser hooks
  ├── grok.sh           Native Grok Build installer
  └── x11.sh            Termux:X11 setup + nh-x11 helper

bin/
  ├── grokhunter        Primary CLI (status, doctor, plan, install, …)
  ├── grok-nethunter    Full-screen TUI launcher
  └── grokhunter-doctor Health report

config/                 Grok Build profile + shell integration
skills/                 Agent skills (orchestrator + recon)
docs/                   Architecture & install notes
```

---

## CLI Options

```
-f, --full              Full installation (includes desktop)
-m, --mini              Mini (essential packages)
-n, --nano              Nano (minimal footprint)
--de <desktop>          e17 | gnome | i3 | kde | lxde | mate | xfce
--browser <browser>     chromium | firefox | both
--no-de                 Skip desktop environment
--with-grok             Install native Grok Build CLI
--no-grok               Skip Grok Build
--with-x11              Install Termux:X11 + nh-x11 helper
--no-x11                Skip Termux:X11
-h, --help              Show help
```

---

## After Install

```bash
nethunter          # Enter Kali shell (rootless proot)
nh-x11             # Low-latency desktop (requires Termux:X11 APK)
grok               # Grok Build interactive TUI
grokhunter         # Primary GrokHunter CLI
grokhunter status  # Quick status (includes x11=yes/no)
grokhunter doctor  # Full health report
```

**Termux:X11 note**  
Install the Termux:X11 APK from the [official nightly releases](https://github.com/termux/termux-x11/releases).

---

## GrokHunter CLI

```bash
grokhunter                  # Interactive TUI
grokhunter status           # Short status line
grokhunter doctor           # Full health report
grokhunter ensure           # Install/upgrade Grok Build binary
grokhunter install [args]   # Run / re-run the rootless installer
grokhunter plan "…"         # Plan mode
grokhunter -p "…"           # Headless one-shot
```

---

## Requirements

- Termux from F-Droid or GitHub (**not** Play Store)
- Android 8+ (aarch64 recommended)
- **No root required**
- Stable internet
- SuperGrok / X Premium+ **or** `XAI_API_KEY` for Grok Build

---

## License

GPL-3.0 (inherits from the original termux-nethunter / termux-distro work)  
GrokHunter Rootless enhancements © 2026 FineComputer14451 / Grok (xAI)

---

## Credits

- Original termux-nethunter by [jorexdeveloper](https://github.com/jorexdeveloper)
- Grok Build by xAI
- Termux:X11 by the Termux team

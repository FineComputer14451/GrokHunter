# GrokHunter Rootless

**Kali NetHunter Rootless × Grok Build — AI coding & building lab for unrooted Android**

GrokHunter turns **rootless** Kali NetHunter (Termux + proot) into a capable Linux development environment on your phone, powered by [Grok Build](https://x.ai/cli).

Write code, build projects, run tools, and use Grok as your on-device agent — **no root required**.

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
- Latest **rootless** Kali NetHunter rootfs
- XFCE desktop (comfortable for coding)
- Chromium
- Native Grok Build CLI
- Termux:X11 low-latency desktop + `nh-x11` helper

---

## Why this stack for coding?

| Need | What you get |
|------|----------------|
| Real Linux toolchain | apt, gcc, python, node, rust, go, etc. inside Kali |
| No root | Stock Android, warranty intact |
| AI pair-programmer | Grok Build TUI + headless mode on-device |
| Desktop IDE feel | XFCE + Termux:X11 (low latency) |
| Portability | Entire lab lives in Termux |

Perfect for:
- Learning and practicing languages
- Building small tools and scripts
- Mobile-first development sessions
- Using Grok as a coding agent while offline-capable packages stay local

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
skills/                 Agent skills for coding workflows
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
nh-x11             # Low-latency desktop for coding
grok               # Grok Build interactive TUI
grokhunter         # Primary CLI
grokhunter status  # Quick status
grokhunter doctor  # Health report
```

**Termux:X11 note**  
Install the Termux:X11 APK from the [official nightly releases](https://github.com/termux/termux-x11/releases).

---

## GrokHunter CLI

```bash
grokhunter                  # Interactive TUI
grokhunter status           # Short status line
grokhunter doctor           # Full health report
grokhunter ensure           # Install/upgrade Grok (scripts/ensure_grok.sh)
grokhunter install [args]   # Run / re-run the rootless installer
grokhunter plan "…"         # Plan a coding task
grokhunter -p "…"           # Headless one-shot
```

Desktop: `nh-x11` auto-detects DE, or `NH_X11_SESSION=startlxde nh-x11`.  
Refresh install cache: `GROKHUNTER_REFRESH=1 bash install.sh …`

---

## Requirements

- Termux from F-Droid or GitHub (**not** Play Store)
- Android 8+ (aarch64 recommended)
- **No root required**
- Stable internet
- SuperGrok / X Premium+ **or** `XAI_API_KEY` for Grok Build

---

## Docs

- [Install](docs/INSTALL.md)
- [FAQ](docs/FAQ.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Editors & pair tools](docs/EDITORS.md)
- [Architecture](docs/ARCHITECTURE.md)

## License

GPL-3.0 (inherits from the original termux-nethunter / termux-distro work)  
GrokHunter Rootless enhancements © 2026 FineComputer14451 / Grok (xAI)

---

## Credits

- Original termux-nethunter by [jorexdeveloper](https://github.com/jorexdeveloper)
- Grok Build by xAI
- Termux:X11 by the Termux team

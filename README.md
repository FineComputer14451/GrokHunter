<p align="center">
  <img src="branding/logo-horizontal.png" alt="GrokHunter" width="520">
</p>

<h1 align="center">GrokHunter</h1>

<p align="center"><strong>Ship code from your pocket.</strong></p>

<p align="center">Kali NetHunter (rootless) × Grok Build — AI coding lab for unrooted Android</p>

<p align="center">
  <a href="https://github.com/FineComputer14451/GrokHunter/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/FineComputer14451/GrokHunter?label=release&color=00E5C7&labelColor=0D1117"></a>
  <a href="https://github.com/FineComputer14451/GrokHunter/actions/workflows/smoke.yml"><img alt="Smoke" src="https://img.shields.io/github/actions/workflow/status/FineComputer14451/GrokHunter/smoke.yml?branch=main&label=smoke&labelColor=0D1117"></a>
  <a href="https://finecomputer14451.github.io/GrokHunter/"><img alt="Pages" src="https://img.shields.io/badge/site-live-00E5C7?labelColor=0D1117"></a>
  <a href="https://www.kali.org/"><img alt="Kali Linux" src="https://img.shields.io/badge/Kali-Linux-2777FF?labelColor=0D1117"></a>
  <a href="https://www.kali.org/docs/nethunter/"><img alt="Kali NetHunter" src="https://img.shields.io/badge/Kali-NetHunter-E31C3D?labelColor=0D1117"></a>
</p>

Turn Termux + proot Kali into a Linux development environment on your phone, with [Grok](https://x.ai/cli) as an on-device pair programmer. **No root required.**

> Built on [termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter) / [termux-distro](https://github.com/jorexdeveloper/termux-distro) by **[jorexdeveloper](https://github.com/jorexdeveloper)**.  
> Not affiliated with xAI, Offensive Security, or jorexdeveloper — we credit and depend on their work. See [CREDITS.md](CREDITS.md).

**Product site:** [finecomputer14451.github.io/GrokHunter](https://finecomputer14451.github.io/GrokHunter/)  
**Release:** [v1.0.10](https://github.com/FineComputer14451/GrokHunter/releases/tag/v1.0.10) · Grok Build **1.0.5+** · Grok **4.6**

Source: [`website/`](website/) · deploy: push `website/**` or `branding/**`, or **Actions → Deploy website**.


---

## Quick install

```bash
# One-liner (Termux from F-Droid / GitHub — not Play Store)
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)

# Or clone
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter && bash install.sh
```

### Recommended full stack

```bash
bash install.sh --full --de xfce --browser chromium \
  --with-grok --with-x11 --with-aider --with-v9-models
```

| Component | What you get |
|-----------|----------------|
| Kali rootfs | Latest NetHunter **rootless** image (proot) |
| Desktop | XFCE (or other DE) + Chromium |
| Grok Build | **1.0.5+** TUI / headless pair programmer (default model **grok-4.6**) |
| Termux:X11 | Low-latency GUI + `nh-x11` helper |
| Aider | Optional git-native pair (uv + Python 3.12) |
| Agents / personas / roles | Coding Team + lab specialists (`skills install`) |
| V9 pickers | `/model chat-expert` · `multi` · `auto` · `grok-v9` aliases |

Refresh cached modules after upgrades:

```bash
GROKHUNTER_REFRESH=1 bash install.sh --help
```

---

## Why this stack?

| Need | What you get |
|------|----------------|
| Real Linux toolchain | `apt`, gcc, python, node, rust, go inside Kali |
| No root | Stock Android |
| AI pair-programmer | Grok Build TUI + headless + optional Aider |
| Desktop | XFCE via Termux:X11 (`nh-x11`) |
| Portability | Lab lives entirely under Termux |

---

## Install flags

```
-f, --full              Full install (desktop-capable rootfs)
-m, --mini              Mini (essential packages)
-n, --nano              Nano (minimal footprint)
--de <desktop>          e17 | gnome | i3 | kde | lxde | mate | xfce
--browser <browser>     chromium | firefox | both
--no-de                 Skip desktop environment
--with-grok / --no-grok
--with-x11 / --no-x11
--with-aider / --no-aider
--with-v9-models / --no-v9-models
--with-completions / --no-completions
--overlay-only          Optional overlays only (no rootfs re-download)
-h, --help
```

Unknown `--de` / `--browser` values are rejected.

---

## After install

```bash
nethunter              # Kali shell (rootless proot)
nh-x11                 # XFCE via Termux:X11 (compositor off by default)
grok                   # Interactive Grok session
grokhunter             # Primary CLI / TUI
grokhunter status      # auth / x11 / v9 quick line
grokhunter doctor      # Full health report
grokhunter binds       # Proot binds (status|repair|optimize)
grokhunter git-identity  # GitHub-attributable git user.name / email
grokhunter setup       # One-shot: ensure + skills + doctor
grokhunter ensure      # Grok Build ≥ 1.0.5 + NetHunter profile
grokhunter team        # Coding Team multi-agent
grokhunter scout "…"   # Fast map agent (headless when prompt given)
grokhunter overlay|ship|docs "…"  # Lab specialists (install / release / docs)
grokhunter modeler|ci|aider "…"   # Models/V9, CI, Aider (modeler ≠ grokhunter models)
grokhunter session|host|mcp "…"   # tmux/resume, Termux vs Kali, MCP (mcp ≠ grok mcp)
grokhunter plugin|flow|storage "…"  # plugins (≠ grok plugin), workflows, disk
grokhunter editor|hook|shell "…"  # nvim/micro, Grok hooks, profile/completions
grokhunter github|secrets|toolchain "…"  # git-identity agent, secrets.env, apt (github ≠ git-identity CLI)
grokhunter models      # Install or status V9 model pickers
grokhunter ai-smoke    # SpaceXAI API smoke (needs XAI_API_KEY)
grokhunter plan "…"    # Plan agent (Grok Build 1.0.5)
grokhunter -p "…"      # Headless one-shot
```

### Grok Build 1.0.5 + Grok 4.6

```bash
grokhunter ensure                  # binary ≥ 1.0.5 + stable profile
bash scripts/install_grok_profile.sh --force
grokhunter models install          # optional /model aliases → grok-4.6
grokhunter models status
```

In-session: `/model chat-expert` · `/model multi` · `/model auto` · `/model grok-v9`  
Base model is **grok-4.6**. See [docs/GROK-46.md](docs/GROK-46.md) and [docs/GROK-BUILD-1.0.md](docs/GROK-BUILD-1.0.md).

### Termux:X11

1. Install the [Termux:X11 APK](https://github.com/termux/termux-x11/releases) (prefer **sharedUserId** builds with GitHub Termux).
2. Run `nh-x11`.
3. Black screen? `nh-x11` defaults to legacy drawing; `NH_X11_LEGACY=0` disables it.
4. Performance tips: [docs/X11-PERFORMANCE.md](docs/X11-PERFORMANCE.md)

### Aider (optional)

```bash
aider-grok             # uses XAI_API_KEY from ~/.grok/secrets.env
```

Details: [docs/EDITORS.md](docs/EDITORS.md).

---

## Architecture

```
install.sh                 Termux one-liner entry (wake-lock, module cache)
lib/
  cli.sh                   Flags & help
  actions.sh               Rootfs / DE / Grok / X11 / Aider / V9 hooks
  grok.sh                  Grok Build + Aider + V9 helpers
  x11.sh                   Termux:X11 + nh-x11 + /tmp bind patch
bin/
  grokhunter               status | doctor | binds | models | ai-smoke | ensure | plan | install
  grokhunter-doctor        Health report
  grok-nethunter           Full-screen launcher
  nh-x11 / aider-grok      Desktop + Aider helpers
scripts/
  install_v9_grok_models.sh   Atomic V9 [model.*] picker install
  spacexai_smoke.sh           SpaceXAI Responses API smoke
  ci-unit.sh                  Local unit checks (bash scripts/ci-unit.sh)
config/                    Completions, profile, model examples
skills/                    grokhunter · pair-programming · aider-grok · x11-desktop · nethunter-recon
                           toolchain · github-lab · grok-models · ci-lab · secrets-lab
                           session-lab · host-lab · mcp-lab · plugin-lab · flow-lab · storage-lab
                           editor-lab · hooks-lab · shell-lab (optional)
agents/                    benjamin · lucas · harper · coding-team · scout · review · fix · desktop
                           overlay · ship · docs · models · ci · aider · session · host · mcp
                           plugin · flow · storage · editor · hook · shell
docs/                      INSTALL, FAQ, X11, PROOT, EDITORS, GROK-46
```

---

## Requirements

- **Termux** from F-Droid or GitHub (**not** Play Store)
- Android 8+ (aarch64 recommended)
- **No root**
- Several GB free for full desktop (mini/nano need less)
- SuperGrok / X Premium+ **or** `XAI_API_KEY` for Grok Build

Keep API keys in `~/.grok/secrets.env` (mode `600`).

---

## Docs

| Doc | Topic |
|-----|--------|
| [INSTALL.md](docs/INSTALL.md) | Step-by-step install |
| [GROK-46.md](docs/GROK-46.md) | Grok 4.6 profile + V9 pickers |
| [GROK-BUILD-1.0.md](docs/GROK-BUILD-1.0.md) | Grok Build **1.0.5** compatibility |
| [CODING-TEAM.md](docs/CODING-TEAM.md) | Agents · personas · roles |
| [X11-PERFORMANCE.md](docs/X11-PERFORMANCE.md) | Termux:X11 tuning |
| [EDITORS.md](docs/EDITORS.md) | Aider / editors |
| [PROOT.md](docs/PROOT.md) | proot binds & storage |
| [FAQ.md](docs/FAQ.md) | Common questions |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Fixes |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Design |
| [CREDITS.md](CREDITS.md) | **jorexdeveloper** + upstream attribution |

---

## License

- **This repository** (GrokHunter overlay, CLI, docs): see [LICENSE](LICENSE)
- **Upstream install engine** ([termux-distro](https://github.com/jorexdeveloper/termux-distro) / [termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter)): **GPL-3.0**, © jorexdeveloper and contributors  

GrokHunter Rootless enhancements © 2026 FineComputer14451 and contributors.

## Credits

**Full attribution:** [CREDITS.md](CREDITS.md) · CLI: `grokhunter credits`

| Pillar | Who | What GrokHunter uses |
|--------|-----|----------------------|
| **Install engine** | **[jorexdeveloper](https://github.com/jorexdeveloper)** | [termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter) · [termux-distro](https://github.com/jorexdeveloper/termux-distro) (GPL-3.0) |
| **Host platform** | **[Termux team](https://github.com/termux)** | Termux app/packages · [Termux:X11](https://github.com/termux/termux-x11) · [termux.dev](https://termux.dev) |
| **Guest rootfs** | **[Kali](https://www.kali.org/) / [Offensive Security](https://www.offsec.com/)** | Official NetHunter rootfs images · Kali `apt` toolchains |
| **AI agent** | **[xAI](https://x.ai)** | [Grok Build](https://x.ai/cli) · Grok models / API · [docs.x.ai](https://docs.x.ai) |

**Thank you** to jorexdeveloper, the Termux project, Kali/OffSec, and xAI. Please support their work directly.

Also: [Aider](https://aider.chat) (optional pair tool).

> **Not affiliated** with xAI, Offensive Security, Termux, or jorexdeveloper. We credit and depend on their work.

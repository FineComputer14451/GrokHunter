# GrokHunter Rootless

**Kali NetHunter (rootless) × Grok Build — AI coding lab for unrooted Android**

Turn Termux + proot Kali into a Linux development environment on your phone, with [Grok](https://x.ai/cli) as an on-device pair programmer. **No root required.**

> Not affiliated with xAI or Offensive Security.

**Product site:** [`website/`](website/) · live (after Pages + Actions):
[finecomputer14451.github.io/GrokHunter](https://finecomputer14451.github.io/GrokHunter/)

Deploy: **Settings → Pages → Source = GitHub Actions**, then push to `main` or run
**Actions → Deploy website**. Workflow: [`.github/workflows/deploy-website.yml`](.github/workflows/deploy-website.yml).


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
| Grok Build | Native CLI pair programmer |
| Termux:X11 | Low-latency GUI + `nh-x11` helper |
| Aider | Optional git-native pair tool (xAI-ready) |
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
grokhunter models      # Install or status V9 model pickers
grokhunter ai-smoke    # SpaceXAI API smoke (needs XAI_API_KEY)
grokhunter plan "…"    # Plan a coding task
grokhunter -p "…"      # Headless one-shot
```

### Grok 4.5 + V9 pickers

```bash
grokhunter models install          # write aliases into ~/.grok/config.toml
grokhunter models status
bash scripts/install_v9_grok_models.sh --force
```

In-session: `/model chat-expert` · `/model multi` · `/model auto` · `/model grok-v9`  
Base model remains **grok-4.5**. See [docs/GROK-45.md](docs/GROK-45.md).

### Termux:X11

1. Install the [Termux:X11 APK](https://github.com/termux/termux-x11/releases) (prefer **sharedUserId** builds with GitHub Termux).
2. Run `nh-x11`.
3. Black screen? `NH_X11_LEGACY=1 nh-x11`
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
  grokhunter               status | doctor | models | ai-smoke | ensure | plan | install
  grokhunter-doctor        Health report
  grok-nethunter           Full-screen launcher
  nh-x11 / aider-grok      Desktop + Aider helpers
scripts/
  install_v9_grok_models.sh   Atomic V9 [model.*] picker install
  spacexai_smoke.sh           SpaceXAI Responses API smoke
  ci-unit.sh                  Local unit checks (bash scripts/ci-unit.sh)
config/                    Completions, profile, model examples
skills/                    grokhunter · pair-programming · aider-grok · nethunter-recon
docs/                      INSTALL, FAQ, X11, PROOT, EDITORS, GROK-45
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
| [GROK-45.md](docs/GROK-45.md) | Grok 4.5 profile + V9 pickers |
| [X11-PERFORMANCE.md](docs/X11-PERFORMANCE.md) | Termux:X11 tuning |
| [EDITORS.md](docs/EDITORS.md) | Aider / editors |
| [PROOT.md](docs/PROOT.md) | proot binds & storage |
| [FAQ.md](docs/FAQ.md) | Common questions |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Fixes |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Design |

---

## License

GPL-3.0 (inherits termux-nethunter / termux-distro lineage)  
GrokHunter Rootless enhancements © 2026 FineComputer14451

## Credits

- [jorexdeveloper](https://github.com/jorexdeveloper) — termux-nethunter / termux-distro
- xAI — Grok Build
- Termux team — Termux & Termux:X11

---
name: grokhunter
description: >-
  GrokHunter Rootless orchestrator for the on-device coding lab. Activate for
  install, overlay-only updates, doctor, PATH/config repair, models/skills
  pickers, SpaceXAI smoke, and launching pair-programming or build workflows.
---

# GrokHunter Skill

You are the **GrokHunter** operator on a rootless Kali NetHunter lab optimized for **coding and building** with Grok Build as the pair programmer.

**Not affiliated with xAI, Offensive Security, Termux, or jorexdeveloper.**  
**Always credit** (see `CREDITS.md` / `grokhunter credits`): jorexdeveloper (termux-nethunter/distro), Termux team, Kali/OffSec (NetHunter rootfs), xAI (Grok Build).  
Default mission is a **coding lab**, not offensive ops (see optional `nethunter-recon` only with explicit authorized scope).

## When to activate

- User says `grokhunter`, `fix my grok`, `mobile coding lab`, or similar
- Install / doctor / PATH / auth / models / skills issues
- Adding optional pieces without re-downloading rootfs (`--overlay-only`)
- Choosing desktop (`nh-x11`) vs shell-only workflows
- Starting or repairing a pair-programming session
- SpaceXAI API smoke / app LLM key checks

## Facts

| Item | Value |
|------|-------|
| Version | See repo `VERSION` (product site tracks major.minor) |
| Overlay | `~/GrokHunter` or `$GROKHUNTER_HOME` |
| Launch | `grokhunter` / `grok` (wrappers in `~/.local/bin`) |
| Doctor | `grokhunter doctor` |
| Status | `grokhunter status` → auth, x11, models, skills N/3, wrappers |
| Ensure binary | `grokhunter ensure` [`--force`] |
| Models | `grokhunter models` [`status` \| `install` \| `force`] |
| Skills | `grokhunter skills` [`status` \| `install`] |
| SpaceXAI smoke | `grokhunter ai-smoke` / `smoke` / alias `ghai` |
| Unit checks | `bash scripts/ci-unit.sh` |
| Install | `grokhunter install …` or `bash install.sh …` |
| Overlay-only | `bash install.sh --overlay-only --with-…` (no rootfs) |
| Config | `~/.grok/config.toml` (Grok Build **1.0.0+** profile) |
| Min Grok | **1.0.0** (`GROKHUNTER_MIN_GROK`) |
| Secrets | `~/.grok/secrets.env` mode **600** (never print) |
| Engine cache | `~/.cache/grokhunter/termux-distro.sh` (upstream: **jorexdeveloper/termux-distro**) |
| Credits | `grokhunter credits` · repo `CREDITS.md` |
| Module cache | `~/.cache/grokhunter/lib` (`MODULES_VERSION`) |
| Skills install dir | `~/.grok/skills/{name}/SKILL.md` |
| Related skills | `pair-programming`, `aider-grok` (coding); `x11-desktop` (X11 fix/tune); `nethunter-recon` (legacy/scoped) |
| Coding Team agents | `benjamin` · `lucas` · `harper` · `coding-team` in `~/.grok/agents/` after install — runtime `/config-agents` |

## CLI map

```text
grokhunter                     # fullscreen TUI (via grok-nethunter)
grokhunter status              # auth | x11 | models | skills | wrappers
grokhunter doctor              # full health report
grokhunter setup [--with-models] [--with-aider]  # one-shot lab sync
grokhunter ensure [--force]    # Grok Build ≥ 1.0.0 + NetHunter profile
grokhunter team [prompt]       # Coding Team agent
grokhunter scout|review|fix|desktop [prompt]
grokhunter agents status
grokhunter models status|install|force
grokhunter skills status|install
grokhunter ai-smoke [prompt]   # SpaceXAI Responses smoke
grokhunter smoke [prompt]      # alias
grokhunter install [flags]     # same as install.sh
grokhunter plan "…"
grokhunter -p "…"              # headless one-shot
grokhunter -- <grok args>      # pass-through
grokhunter help | version
```

**Aliases** (after profile / completions):

| Alias | Expands to |
|-------|------------|
| `ghn` | `grok-nethunter` |
| `ghd` | `doctor` |
| `ghs` | `status` |
| `ghp` | `plan` |
| `ghm` | `models` |
| `ghk` | `skills` |
| `ghai` | `ai-smoke` |
| `ghh` | headless `-p` |

## Decision tree (quick)

```
Need Kali rootfs?     → full/mini/nano install.sh
Already have Kali?    → --overlay-only --with-*
Only Grok binary?     → grokhunter ensure   # requires Grok Build 1.0.0+
Profile only?         → bash scripts/install_grok_profile.sh
Only V9 pickers?      → grokhunter models install
Only skills/PATH?     → grokhunter skills install
Desktop?              → --with-x11 + Termux:X11 APK + nh-x11
X11 black/lag/tune?   → skill x11-desktop (docs/X11-PERFORMANCE.md)
API key check?        → grokhunter ai-smoke
Broken PATH?          → export PATH + skills install / doctor
```

## Playbooks

### Fresh bootstrap (Termux host)

```bash
cd ~/GrokHunter && bash install.sh --full --de xfce \
  --with-grok --with-x11 --with-aider --with-v9-models --with-completions
source ~/.grok/profile.sh 2>/dev/null || true
grokhunter doctor
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env
grokhunter skills status
grok
```

### Overlay-only (rootfs already present)

Skip NetHunter re-download; install optional pieces only:

```bash
bash ~/GrokHunter/install.sh --overlay-only --with-x11 --with-aider
bash ~/GrokHunter/install.sh --overlay-only --with-grok --with-v9-models --with-completions
# or:
grokhunter install --overlay-only --with-v9-models
grokhunter skills install    # wrappers + ~/.grok/skills
```

Requires at least one `--with-*`. Overlay complete always runs `install_cli_bins` (PATH wrappers + skills).

### Repair PATH / wrappers / skills

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
grokhunter skills install
# or:
bash ~/GrokHunter/install.sh --overlay-only --with-completions
source ~/.grok/profile.sh 2>/dev/null || true
grokhunter doctor
grokhunter status
```

### V9 / 4.5 model pickers

```bash
grokhunter models status
grokhunter models install
grokhunter models force    # refresh config.toml pickers
# in-session: /model chat-expert · multi · auto · grok-v9
```

### Grok binary only

```bash
grokhunter ensure
GROKHUNTER_FORCE_GROK=1 GROKHUNTER_GROK_INSTALLER=official grokhunter ensure --force
# modes: auto | official | termux-native
```

### Refresh installer overlay (one-liner cache)

```bash
GROKHUNTER_REFRESH=1 bash install.sh --overlay-only --with-completions
# pin engine fork:
# GROKHUNTER_DISTRO_ENGINE_URL=https://… bash install.sh …
```

### Pair session

```bash
grok
# headless:
grokhunter -p "Implement X and show the diff"
# plan first:
grokhunter plan "Refactor the CLI to use subcommands"
# desktop (Termux host + Termux:X11 APK):
nh-x11
# black screen:
NH_X11_LEGACY=1 nh-x11
```

### SpaceXAI API smoke (app / key check)

```bash
source ~/.grok/secrets.env   # or export XAI_API_KEY=…
grokhunter ai-smoke
# alias: ghai
# or: bash ~/GrokHunter/scripts/spacexai_smoke.sh
# or: python3 ~/GrokHunter/templates/spacexai_hello.py
```

Anchors: `XAI_API_KEY`, base `https://api.x.ai/v1`, model **`grok-4.5`**. Never invent `SPACEXAI_*` API hosts.

### Local unit checks

```bash
bash ~/GrokHunter/scripts/ci-unit.sh
# syntax, parse_cli, maybe_install, bind patch, status fields, skills install
```

### Uninstall (overlay only; keeps rootfs)

```bash
bash ~/GrokHunter/uninstall.sh
# also strip Grok binary dirs:
bash ~/GrokHunter/uninstall.sh --purge-grok
```

## Install flags (quick)

| Flag | Effect |
|------|--------|
| `-f/--full`, `-m/--mini`, `-n/--nano` | Rootfs size |
| `--de`, `--browser`, `--no-de` | Desktop / browser |
| `--with-grok` / `--no-grok` | Grok Build |
| `--with-x11` / `--no-x11` | Termux:X11 + `nh-x11` |
| `--with-aider` / `--no-aider` | Aider venv + helper |
| `--with-v9-models` / `--no-v9-models` | Model pickers |
| `--with-completions` / `--no-completions` | Completions + `~/.grok/profile.sh` (does not edit rc files) |
| `--overlay-only` | No rootfs/engine; overlays only |

Canonical helpers: repo `bin/` (`nh-x11`, `aider-grok`, `grokhunter`, …) → `~/.local/bin`.

## Doctor interpretation

| Finding | Typical fix |
|---------|-------------|
| grok missing / &lt; 1.0.0 | `grokhunter ensure` (target **1.0.0+**) |
| channel=alpha / bad fork model | `bash scripts/install_grok_profile.sh --force` |
| nethunter not on PATH | Termux host; re-run install |
| nh-x11 missing | `--overlay-only --with-x11` + X11 APK |
| skill (repo only) | `grokhunter skills install` |
| V9 pickers missing | `grokhunter models install` |
| wrapper not on PATH | `source ~/.grok/profile.sh` or fix PATH |
| no secrets / key | write `~/.grok/secrets.env` mode 600 |
| x.ai unreachable | network / DNS; offline lab still OK for non-API work |

## Response style

Short commands, mobile-friendly, never print secrets. Prefer paste-ready lines over essays. Cross-link `pair-programming` for coding sessions and `aider-grok` for git-native pair.

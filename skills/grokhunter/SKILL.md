---
name: grokhunter
description: >-
  GrokHunter Rootless orchestrator for the on-device coding lab. Activate for
  install, overlay-only updates, doctor, PATH/config repair, models pickers,
  and launching pair-programming or build workflows.
---

# GrokHunter Skill

You are the **GrokHunter** operator on a rootless Kali NetHunter lab optimized for **coding and building** with Grok Build as the pair programmer.

## When to activate

- User says `grokhunter`, `fix my grok`, `mobile coding lab`, or similar
- Install / doctor / PATH / auth / models issues
- Adding optional pieces without re-downloading rootfs (`--overlay-only`)
- Choosing desktop (`nh-x11`) vs shell-only workflows
- Starting or repairing a pair-programming session

## Facts

| Item | Value |
|------|-------|
| Overlay | `~/GrokHunter` or `$GROKHUNTER_HOME` |
| Launch | `grokhunter` / `grok` (wrappers in `~/.local/bin`) |
| Doctor | `grokhunter doctor` |
| Ensure binary | `grokhunter ensure` [`--force`] |
| Models | `grokhunter models` [`status` \| `install` \| `force`] |
| Install | `grokhunter install …` or `bash install.sh …` |
| Overlay-only | `bash install.sh --overlay-only --with-…` (no rootfs) |
| Config | `~/.grok/config.toml` |
| Secrets | `~/.grok/secrets.env` mode **600** (never print) |
| Engine cache | `~/.cache/grokhunter/termux-distro.sh` |
| Module cache | `~/.cache/grokhunter/lib` (`MODULES_VERSION`) |
| Related skills | `pair-programming`, `aider-grok` |

## CLI map

```text
grokhunter                  # fullscreen TUI (via grok-nethunter)
grokhunter status           # short status line
grokhunter doctor           # full health report
grokhunter ensure [--force] # Grok Build binary
grokhunter models status|install|force
grokhunter install [flags]  # same as install.sh
grokhunter plan "…"
grokhunter -p "…"           # headless one-shot
```

Aliases (after profile): `gh`, `ghd`, `ghs`, `ghp`, `ghm`, `ghn`, `ghh`.

## Playbooks

### Fresh bootstrap (Termux host)

```bash
cd ~/GrokHunter && bash install.sh --full --de xfce \
  --with-grok --with-x11 --with-aider --with-v9-models --with-completions
# or one-liner from README
source ~/.zshrc 2>/dev/null || source ~/.bashrc 2>/dev/null || true
grokhunter doctor
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env
grok
```

### Overlay-only (rootfs already present)

Skip NetHunter re-download; install optional pieces only:

```bash
# From Termux host (or clone with install.sh)
bash ~/GrokHunter/install.sh --overlay-only --with-x11 --with-aider
bash ~/GrokHunter/install.sh --overlay-only --with-grok --with-v9-models --with-completions
# equivalent:
grokhunter install --overlay-only --with-v9-models
```

Requires at least one `--with-*`. Always refreshes CLI wrappers into `~/.local/bin`.

### Repair PATH / wrappers

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
bash ~/GrokHunter/install.sh --overlay-only --with-completions
# or re-copy wrappers only via any overlay run
grokhunter doctor
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
```

### Refresh installer modules (one-liner cache)

```bash
GROKHUNTER_REFRESH=1 bash install.sh --help
# pin engine:
# GROKHUNTER_DISTRO_ENGINE_URL=https://… bash install.sh …
```

### Pair session

```bash
grok
# headless:
grokhunter -p "Implement X and show the diff"
# desktop (Termux host + Termux:X11 APK):
nh-x11
```

### SpaceXAI API smoke (app / key check)

```bash
source ~/.grok/secrets.env
bash ~/GrokHunter/scripts/spacexai_smoke.sh
# or: python3 ~/GrokHunter/templates/spacexai_hello.py
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
| `--with-completions` / `--no-completions` | Shell profile |
| `--overlay-only` | No rootfs/engine; overlays only |

Canonical helpers live in repo `bin/` (`nh-x11`, `aider-grok`, `grokhunter`, …) and are copied to `~/.local/bin`.

## Response style

Short commands, mobile-friendly, never print secrets. Prefer paste-ready lines over essays.

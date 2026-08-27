---
name: grokhunter
description: >-
  GrokHunter Rootless orchestrator for the on-device coding lab. Activate for
  install, overlay-only updates, doctor, PATH/config repair, models/skills
  pickers, grokhunter binds, bwrap-proot, SpaceXAI smoke, and launching
  pair-programming or build workflows.
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
- Proot binds (runtime X11 triage is still skill `x11-desktop`; TLS is skill `tls-lab`)

## Facts

| Item | Value |
|------|-------|
| Version | **1.0.10** (repo `VERSION`; overlay cache **2026.2.25**) |
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
| Config | `~/.grok/config.toml` (Grok Build **1.0.5+** profile, default **grok-4.6**) |
| Min Grok | **1.0.5** (`GROKHUNTER_MIN_GROK`) |
| Secrets | `~/.grok/secrets.env` mode **600** (never print) |
| Engine cache | `~/.cache/grokhunter/termux-distro.sh` (upstream: **jorexdeveloper/termux-distro**) |
| Credits | `grokhunter credits` · repo `CREDITS.md` |
| Module cache | `~/.cache/grokhunter/lib` (`MODULES_VERSION`) |
| Skills install dir | `~/.grok/skills/{name}/SKILL.md` |
| Git identity | `grokhunter git-identity` [`show` \| `set`] — flags, env, gh, `GH_TOKEN`, or GitHub origin |
| Binds | `grokhunter binds` [`status` \| `repair` \| `optimize`] — `lib/x11.sh`; runtime triage is skill `x11-desktop` |
| TLS | skill `tls-lab` / agent `tls` — `lib/tls.sh`; overlay still writes install symlink |
| Net | skill `net-lab` / agent `net` — `lib/https-probe.sh`; 401/403 = reachable |
| Related skills | coding: `pair-programming`, `aider-grok`; optional lab skills (toolchain…shell-lab, specialist-lab, tls-lab, net-lab, x11-desktop); scoped: `nethunter-recon` |
| Coding Team agents | core + specialists (overlay…toolchain, tls, net) → `~/.grok/agents/` |
| TUI status line | `~/.grok/statusline.sh` via `scripts/install_grok_statusline.sh` (restart `grok`) |

## CLI map

```text
grokhunter                     # fullscreen TUI (via grok-nethunter)
grokhunter status              # auth | x11 | models | skills | wrappers
grokhunter doctor              # full health report
grokhunter binds [cmd]         # proot binds (status|repair|optimize)
grokhunter setup [--with-models] [--with-aider]  # one-shot lab sync
grokhunter ensure [--force]    # Grok Build ≥ 1.0.5 + NetHunter profile
grokhunter team [prompt]       # Coding Team agent
grokhunter scout|review|fix|desktop [prompt]
grokhunter overlay|ship|docs [prompt]
grokhunter modeler|ci|aider [prompt]
grokhunter session|host|mcp [prompt]
grokhunter plugin|flow|storage [prompt]
grokhunter editor|hook|shell [prompt]
grokhunter github|secrets|toolchain|tls|net [prompt]  # github ≠ git-identity CLI
grokhunter git-identity [show|set]
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
| `ghsu` | `setup` |
| `ghp` | `plan` |
| `ghm` | `models` |
| `ghk` | `skills` |
| `ghai` | `ai-smoke` |
| `ghh` | headless `-p` |

## Decision tree (quick)

```
Need Kali rootfs?     → full/mini/nano install.sh
Already have Kali?    → --overlay-only --with-*
Only Grok binary?     → grokhunter ensure   # requires Grok Build 1.0.5+
Profile only?         → bash scripts/install_grok_profile.sh
Only V9 pickers?      → grokhunter models install
Only skills/PATH?     → grokhunter skills install
Desktop?              → --with-x11 + Termux:X11 APK + nh-x11
X11 black/lag/tune?   → skill x11-desktop (docs/X11-PERFORMANCE.md)
Binds /tmp / X socket? → grokhunter binds status  then skill x11-desktop
XFCE panel / glycin bwrap? → skill x11-desktop (docs/TROUBLESHOOTING.md)
TLS / SSL_CERT_FILE / CA? → skill tls-lab / agent tls (never print certs)
x.ai offline / DNS?       → skill net-lab / agent net (401/403 = reachable)
API key check?        → grokhunter ai-smoke
GitHub invalid-email? → grokhunter git-identity set  (skill github-lab / agent github)
Secrets / missing key? → skill secrets-lab / agent secrets (never print)
Compilers / apt?      → skill toolchain / agent toolchain (Aider stays aider-grok)
Termux vs Kali?       → skill host-lab
TUI died / resume?    → skill session-lab
TUI status line?      → bash scripts/install_grok_statusline.sh  (restart grok)
MCP tools missing?    → skill mcp-lab (`grok mcp`; agent `mcp`)
Plugin missing?       → skill plugin-lab (`grok plugin`; agent `plugin`)
Grok workflow .rhai?  → skill flow-lab (agent `flow`; Actions = ci-lab)
Disk / SD full?       → skill storage-lab
nvim / micro?         → skill editor-lab
Grok hook missing?    → skill hooks-lab (TUI /hooks; agent `hook`)
TAB / ghd missing?    → skill shell-lab
New lab agent/skill?  → skill specialist-lab (recipe in agents/README)
Broken PATH?          → export PATH + skills install / doctor; source ~/.grok/profile.sh
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

### Git identity (GitHub attribution)

```bash
grokhunter git-identity          # show
grokhunter git-identity set      # gh, GH_TOKEN, or GitHub origin owner
# doctor warns if placeholder (root, @localhost, empty)
```

Resolution order lives in `lib/git-identity.sh`. Deeper playbook: skill `github-lab`.

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

### V9 / 4.6 model pickers

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
# GPU path (legacy drawing is the default):
NH_X11_LEGACY=0 nh-x11
```

### Proot binds / X sockets

Runtime triage is skill `x11-desktop`. Overlay *patches* the launcher on `--with-x11`.

```bash
grokhunter binds status
grokhunter binds repair      # re-apply if the nethunter launcher drifted
grokhunter binds optimize    # fails if the patch does not apply
```

Canonical recipes: `docs/PROOT.md`, `docs/TROUBLESHOOTING.md` (`/tmp` or display errors).

### SpaceXAI API smoke (app / key check)

```bash
source ~/.grok/secrets.env   # or export XAI_API_KEY=…
grokhunter ai-smoke
# alias: ghai
# or: bash ~/GrokHunter/scripts/spacexai_smoke.sh
# or: python3 ~/GrokHunter/templates/spacexai_hello.py
```

Anchors: `XAI_API_KEY`, base `https://api.x.ai/v1`, model **`grok-4.6`**. Never invent `SPACEXAI_*` API hosts.

### Local unit checks

```bash
bash ~/GrokHunter/scripts/ci-unit.sh
# syntax, parse_cli, maybe_install, bind patch, status fields, skills install, statusline
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
| No /etc/os-release | Warning only. Check `/usr/lib/os-release`; Termux host often has none. Not a lab blocker. |
| grok missing / &lt; 1.0.5 | `grokhunter ensure` (target **1.0.5+**) |
| channel=alpha / bad fork model | `bash scripts/install_grok_profile.sh --force` |
| nethunter not on PATH | Termux host; re-run install (skill `host-lab`) |
| nh-x11 missing | `--overlay-only --with-x11` + X11 APK |
| skill (repo only) | `grokhunter skills install` |
| V9 pickers missing | `grokhunter models install` |
| wrapper not on PATH | overlay-only installs to `~/.local/bin`; `source ~/.grok/profile.sh` or new shell; skill `host-lab` if Termux vs Kali |
| git identity placeholder | `grokhunter git-identity set` |
| no secrets / key | write `~/.grok/secrets.env` mode 600 |
| x.ai unreachable | skill `net-lab` / agent `net`. Real outage only if probe gets no HTTP status (`000`); Cloudflare 403 / API 401 are reachable. Offline lab still OK for non-API work |
| TLS / `SSL_CERT_FILE` | skill `tls-lab` / agent `tls`. Kali CA vs injected `/etc/tls/cert.pem`; overlay writes the install symlink. Never print certs |
| binds marker missing | `grokhunter binds status` then skill `x11-desktop` |

## Response style

Short commands, mobile-friendly, never print secrets. Prefer paste-ready lines over essays. Cross-link `pair-programming` / `aider-grok` for coding, optional lab skills (`shell-lab`, `editor-lab`, `hooks-lab`, `host-lab`, `session-lab`, `storage-lab`, `toolchain`, `tls-lab`, `net-lab`) for the phone environment.

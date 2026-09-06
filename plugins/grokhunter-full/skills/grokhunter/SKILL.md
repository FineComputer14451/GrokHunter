---
name: grokhunter
description: >-
  Use for GrokHunter Rootless lab ops: install, overlay-only, doctor,
  PATH/config, models/skills, binds, ai-smoke, and routing to lab specialist
  skills.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/grokhunter` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI; no unauthorized offensive activity. Do not claim affiliation with those projects.

# GrokHunter Skill

You are the **GrokHunter** operator for a rootless Kali NetHunter coding lab with Grok Build as the pair programmer. Default mission is a **coding lab**, not offensive ops.

## When to activate

- User says `grokhunter`, `fix my grok`, `mobile coding lab`, or similar
- Install / doctor / PATH / auth / models / skills issues
- Overlay-only updates without re-downloading rootfs
- Desktop (`nh-x11`) vs shell-only, binds, SpaceXAI smoke
- Starting or repairing a pair-programming session

## Facts

| Item | Value |
|------|-------|
| Version | **1.0.10** (overlay cache **2026.8.27**) |
| Overlay | `~/GrokHunter` or `$GROKHUNTER_HOME` |
| Launch | `grokhunter` / `grok` in `~/.local/bin` |
| Doctor | `grokhunter doctor` |
| Ensure | `grokhunter ensure` [`--force`] — Grok Build ≥ **1.0.5**, default model **grok-4.6** |
| Secrets | `~/.grok/secrets.env` mode **600** (never print) |
| Repo | https://github.com/FineComputer14451/GrokHunter |

## CLI map

```text
grokhunter                     # fullscreen TUI
grokhunter status|doctor
grokhunter binds [status|repair|optimize]
grokhunter setup|ensure [--force]
grokhunter team|scout|review|fix|desktop [prompt]
grokhunter overlay|ship|docs|modeler|ci|aider [prompt]
grokhunter session|host|mcp|plugin|flow|storage [prompt]
grokhunter editor|hook|shell|github|secrets|toolchain|tls|net [prompt]
grokhunter git-identity [show|set]
grokhunter models|skills status|install|force
grokhunter ai-smoke|smoke|plan|-p
grokhunter install [flags]     # same as install.sh (Termux only for rootfs)
```

Aliases after profile: `ghn` `ghd` `ghs` `ghsu` `ghp` `ghm` `ghk` `ghai` `ghh`.

## Decision tree

```
Need Kali rootfs?     → Termux: bash install.sh (wizard) or --yes / flags
Already have Kali?    → --overlay-only --with-*
Only Grok binary?     → grokhunter ensure
Only V9 pickers?      → grokhunter models install
Only skills/PATH?     → grokhunter skills install
X11 black/lag?        → skill x11-desktop
TLS / CA?             → skill tls-lab
x.ai offline / DNS?   → skill net-lab
GitHub invalid-email? → grokhunter git-identity set (skill github-lab)
Secrets missing?      → skill secrets-lab
Compilers / apt?      → skill toolchain
Termux vs Kali?       → skill host-lab
TUI died / resume?    → skill session-lab
```

## Playbooks

### Fresh bootstrap (Termux host only)

```bash
cd ~/GrokHunter && bash install.sh --full --de xfce \
  --with-grok --with-x11 --with-aider --with-v9-models --with-completions
source ~/.grok/profile.sh 2>/dev/null || true
grokhunter doctor
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env
grok
```

### Overlay-only

```bash
bash ~/GrokHunter/install.sh --overlay-only --with-grok --with-v9-models --with-completions
grokhunter skills install
```

### Repair PATH

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
grokhunter skills install
source ~/.grok/profile.sh 2>/dev/null || true
grokhunter doctor
```

One-liner install only works inside Termux on Android — not on desktop Linux/Windows.

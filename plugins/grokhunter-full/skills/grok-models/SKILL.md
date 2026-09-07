---
name: grok-models
description: >-
  Use when GrokHunter models=no, wrong default, grok-4.6 profile needs a
  refresh, or legacy V9 /model pickers remain.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/grok-models`.
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Grok models

You keep **Grok 4.6** as the catalog default. Binary install is `grokhunter ensure`
(skill `grokhunter`) — this skill is **profile + legacy picker cleanup**.

## When to activate

- `status` shows `models=no`
- Profile still on grok-4.5 or channel=alpha
- Legacy V9 pickers linger in config.toml

## Commands

```bash
grokhunter models status
grokhunter models clean
grokhunter ensure
bash scripts/install_grok_profile.sh --force
```

Default: **`grok-4.6`**. Cleanup script: `scripts/install_v9_grok_models.sh`.
Docs: `docs/GROK-46.md`, `docs/GROK-BUILD-1.0.md`.

## Facts

- Min Grok Build **1.0.5**
- Default catalog **`grok-4.6`**
- V9 `/model` pickers are **retired**

---
name: grok-models
description: >-
  Use when GrokHunter V9 /model pickers are missing, models=no, wrong model
  selected, or grok-4.6 profile needs a refresh.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/grok-models` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Grok models (optional)

You keep **Grok 4.6** as the catalog default and V9 pickers working. Binary install is `grokhunter ensure` (skill `grokhunter`) — this skill is **pickers + profile**.

## When to activate

- `/model` aliases missing
- `status` shows `models=no`
- User asks for chat-expert / multi / auto / grok-v9
- Profile still on grok-4.5 or channel=alpha

## Commands

```bash
grokhunter models status
grokhunter models install
grokhunter models force
grokhunter ensure
bash scripts/install_grok_profile.sh --force
```

In-session: `/model chat-expert` · `/model multi` · `/model auto` · `/model grok-v9`

Canonical installer: `scripts/install_v9_grok_models.sh`. Docs: `docs/GROK-46.md`, `docs/GROK-BUILD-1.0.md`.

## Facts

- Min Grok Build **1.0.5**
- Default catalog **`grok-4.6`**
- Former 4.5 picker IDs wrap 4.6
- Config: `~/.grok/config.toml` (never print secrets)

## Common failures

| Symptom | First step |
|---------|------------|
| `models=no` / pickers missing | `grokhunter models install` |
| Still grok-4.5 / channel=alpha | `bash scripts/install_grok_profile.sh --force` |
| Binary too old | `grokhunter ensure` |

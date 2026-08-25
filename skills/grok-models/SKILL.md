---
name: grok-models
description: >-
  Grok Build models on GrokHunter: grok-4.6 default, V9 /model pickers
  (chat-expert, multi, auto, grok-v9), grokhunter models install/status/force,
  and the NetHunter config.toml profile. Use when pickers are missing, the
  wrong model is selected, or ensure/profile needs a refresh. Optional skill.
---

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
grokhunter models force          # refresh ~/.grok/config.toml pickers
grokhunter ensure                # binary ≥ 1.0.5 + NetHunter profile
bash scripts/install_grok_profile.sh --force
```

In-session: `/model chat-expert` · `/model multi` · `/model auto` · `/model grok-v9`

Canonical installer: `scripts/install_v9_grok_models.sh`. Docs: `docs/GROK-46.md`, `docs/GROK-BUILD-1.0.md`. Do not copy those files here.

## Facts

- Min Grok Build **1.0.5** (`GROKHUNTER_MIN_GROK`)
- Default catalog **`grok-4.6`**
- Former 4.5 picker IDs wrap 4.6
- Config: `~/.grok/config.toml` (never print secrets)

## Common failures

| Symptom | First step |
|---------|------------|
| `models=no` / pickers missing | `grokhunter models install` |
| Still grok-4.5 / channel=alpha | `bash scripts/install_grok_profile.sh --force` |
| Binary too old | `grokhunter ensure` (skill `grokhunter`) |

## Verify

```bash
grokhunter models status
```

## Cross-links

- Lab orchestrator: skill `grokhunter`
- App LLM keys: `grokhunter ai-smoke` (SpaceXAI / `XAI_API_KEY`)
- Agent `models` for picker/profile work

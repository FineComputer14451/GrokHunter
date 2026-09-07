---
name: grok-models
description: >-
  Grok Build models on GrokHunter: grok-4.6 catalog default, NetHunter
  config.toml profile, grokhunter models status/clean, and cleanup of
  retired V9 /model pickers. Use when models=no, wrong default, or legacy
  pickers remain.
---

You keep **Grok 4.6** as the catalog default. Binary install is `grokhunter ensure`
(skill `grokhunter`) — this skill is **profile + legacy picker cleanup**.

## When to activate

- `status` shows `models=no`
- Profile still on grok-4.5 or channel=alpha
- Legacy V9 pickers (`chat-expert` / `multi` / `auto` / `grok-v9`) linger in config.toml

## Commands

```bash
grokhunter models status
grokhunter models clean          # remove retired V9 pickers (install/force are aliases)
grokhunter ensure
bash scripts/install_grok_profile.sh --force
```

Default coding model: **`grok-4.6`**. Imagine stills/video stay on `grok-imagine-*`.

Cleanup script (filename kept for back-compat): `scripts/install_v9_grok_models.sh`.
Docs: `docs/GROK-46.md`, `docs/GROK-BUILD-1.0.md`. Do not copy those files here.

## Facts

- Min Grok Build **1.0.5**
- Default catalog **`grok-4.6`**
- V9 `/model` pickers are **retired** (do not re-install them)

## Quick fixes

| Symptom | Fix |
|---------|-----|
| `models=no` / no default | `grokhunter ensure` or profile `--force` |
| legacy V9 pickers present | `grokhunter models clean` |
| channel=alpha / 4.5 leftovers | `bash scripts/install_grok_profile.sh --force` |

## Related

- Agent `models` for profile / cleanup work
- Skill `grokhunter` for binary / overlay

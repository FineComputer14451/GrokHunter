# Grok 4.6 profile — GrokHunter Rootless

This lab is tuned for **Grok 4.6** as the primary pair-programming intelligence on **Grok Build 1.0.5+** (stable).

See also: [GROK-BUILD-1.0.md](GROK-BUILD-1.0.md) for binary/profile upgrade steps.

## What “optimized for Grok 4.6” means here

| Area | Guidance |
|------|----------|
| Reasoning | Multi-step refactors, debugging, and architecture OK — still present results in small steps |
| Output | Mobile-scannable; short paragraphs; paste-ready commands |
| Tools | Grok Build CLI + optional Aider on the same xAI key |
| Secrets | `~/.grok/secrets.env` only |
| Display | Termux:X11 (`nh-x11`) when a desktop helps; shell is enough for most pairs |

Catalog id: **`grok-4.6`**. Docs: https://docs.x.ai/developers/grok-4-6 · https://docs.x.ai/developers/models

## Default session

```bash
nethunter
grok                    # Grok Build 1.0.5 TUI
# or
grokhunter -p "your task"
grokhunter plan "…"     # built-in plan agent
grok inspect            # skills / agents / config discovery
```

## Aider model pin

```bash
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"
export AIDER_MODEL=grok-4.6
# Preferred: use the helper (already defaults to grok-4.6)
aider-grok
# or
aider --model "$AIDER_MODEL"
```

Check current model ids with your xAI account / Grok Build docs: https://x.ai/cli

## Prompt patterns that work well

**One-shot fix**

```text
In main.py, fix the off-by-one in parse_args. Show a minimal diff only.
```

**Plan then implement**

```text
Plan a subcommand CLI for tools/ (list, run, doctor). Then implement step 1 only.
```

**Review**

```text
Review this diff for security and edge cases. Bullet risks; no rewrite unless critical.
```

## Doctor

```bash
grokhunter doctor
```

Confirms Grok binary, auth, and lab readiness before long sessions.

## Model default (grok-4.6)

Catalog default remains **`grok-4.6`** via the NetHunter profile (`grokhunter ensure` /
`bash scripts/install_grok_profile.sh`). Former V9 `/model` pickers (`chat-expert`,
`multi`, `auto`, `grok-v9`, …) are **retired** — clean leftovers with:

```bash
grokhunter models clean
# or: bash scripts/install_v9_grok_models.sh
```

Imagine stills/video stay on `grok-imagine-*` (unchanged).

## Related

- [Workflow map: chat ↔ Build](GROK-46-WORKFLOW.md)
- [pair-programming skill](../skills/pair-programming/SKILL.md)
- [EDITORS.md](EDITORS.md)
- [X11-PERFORMANCE.md](X11-PERFORMANCE.md)

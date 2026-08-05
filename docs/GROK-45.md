# Grok 4.5 profile — GrokHunter Rootless

This lab is tuned for **Grok 4.5** as the primary pair-programming intelligence.

## What “optimized for Grok 4.5” means here

| Area | Guidance |
|------|----------|
| Reasoning | Multi-step refactors, debugging, and architecture OK — still present results in small steps |
| Output | Mobile-scannable; short paragraphs; paste-ready commands |
| Tools | Grok Build CLI + optional Aider on the same xAI key |
| Secrets | `~/.grok/secrets.env` only |
| Display | Termux:X11 (`nh-x11`) when a desktop helps; shell is enough for most pairs |

## Default session

```bash
nethunter
grok
# or
grokhunter -p "your task"
```

## Aider model pin

```bash
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"
# Prefer the newest Grok coding model your account exposes, e.g.:
export AIDER_MODEL=grok-4
# If the API lists a 4.5-specific id, set that instead.
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

## V9 / specialist model pickers (optional)

Register `/model chat-expert`, `/model multi`, `/model auto`, etc. in Grok Build:

```bash
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter
bash scripts/install_v9_grok_models.sh
# force refresh:
bash scripts/install_v9_grok_models.sh --force
```

Template: `config/grok-build-v9-models.example.toml`  
All aliases wrap **grok-4.5**. Imagine stills/video stay on `grok-imagine-*`.

## Related

- [pair-programming skill](../skills/pair-programming/SKILL.md)
- [EDITORS.md](EDITORS.md)
- [X11-PERFORMANCE.md](X11-PERFORMANCE.md)

---
name: aider-grok
description: >-
  Use when the user wants Aider + Grok/xAI git-native pair programming on
  GrokHunter Rootless, or to repair aider-grok / the Aider venv.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/aider-grok` (v1.0.10).
Use when helping operate the user's GrokHunter Android/Termux coding lab or when the same playbook applies here.
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI; no unauthorized offensive activity.

# Aider + Grok (GrokHunter Rootless)

You help the operator use **Aider** as a terminal pair programmer with **xAI / Grok 4.6** inside the rootless Kali lab.

## When to activate

- User asks for Aider, git-aware pair, auto-commit coding sessions
- Preference for CLI-only pair programming over the Grok TUI
- Combining Aider with the existing `XAI_API_KEY`
- Repairing `aider-grok` helper or `~/venv-aider`

## Setup (paste-ready)

```bash
bash ~/GrokHunter/install.sh --overlay-only --with-aider
bash ~/GrokHunter/scripts/install_aider.sh
GROKHUNTER_FORCE_AIDER=1 bash ~/GrokHunter/scripts/install_aider.sh
grokhunter skills install
[ -f ~/.grok/secrets.env ] && source ~/.grok/secrets.env
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"
export AIDER_MODEL=grok-4.6
```

**Do not** `pip install aider-chat` into system Python 3.13. Use `scripts/install_aider.sh`.

## Daily use

```bash
cd ~/my-project
aider-grok
```

Overrides: `AIDER_MODEL=grok-4.6 aider-grok` or `aider-grok --model grok-4.6`.

## Rules

- Prefer small, reviewable edits
- Never print or commit API keys
- Aider auto-commits by default — mention that when starting a session
- Default model is **grok-4.6**

## Troubleshooting

```bash
grokhunter doctor
which aider-grok
grokhunter ai-smoke
```

| Symptom | Fix |
|---------|-----|
| `aider not found` | `bash scripts/install_aider.sh` or `--overlay-only --with-aider` |
| pip / Python 3.13 errors | Use uv installer, not plain pip on 3.13 |
| Auth / 401 | Fix `XAI_API_KEY` in secrets.env; `ai-smoke` |

Docs: `docs/EDITORS.md`, `docs/GROK-46.md`. Agent: `aider`.

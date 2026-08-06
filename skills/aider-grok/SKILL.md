---
name: aider-grok
description: Optional Aider pair-programmer wired to Grok/xAI inside GrokHunter Rootless. Activate when the user wants git-native terminal pair programming alongside or instead of grok TUI.
---

# Aider + Grok (GrokHunter Rootless)

You help the operator use **Aider** as a terminal pair programmer with **xAI / Grok 4.5** inside the rootless Kali lab.

## When to activate

- User asks for Aider, “git-aware pair”, auto-commit coding sessions
- Preference for CLI-only pair programming over the Grok TUI
- Combining Aider with the existing `XAI_API_KEY`

## Setup (paste-ready)

```bash
# Preferred (installer):
bash install.sh --with-aider

# Manual inside nethunter:
sudo apt update && sudo apt install -y python3-pip python3-venv git
python3 -m venv ~/venv-aider && source ~/venv-aider/bin/activate
pip install -U aider-chat

# Auth (reuse GrokHunter secrets)
[ -f ~/.grok/secrets.env ] && source ~/.grok/secrets.env
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"
export AIDER_MODEL=grok-4.5
```

## Daily use

```bash
cd ~/my-project
aider-grok                 # recommended — auto secrets + model
# or
source ~/venv-aider/bin/activate
aider --model "${AIDER_MODEL:-grok-4.5}"
```

## Rules

- Prefer small, reviewable edits
- Never print or commit API keys
- Aider auto-commits by default — mention that when starting a session
- Default model is **grok-4.5**; override with `AIDER_MODEL` or `--model` if needed

## Relation to Grok Build

| Tool | Role |
|------|------|
| `grok` / `grokhunter` | Default interactive + headless agent for this lab |
| `aider-grok` / `aider` | Optional git-native terminal pair-programmer using the same key |

Both can coexist. Guide the user to the tool that matches the session (TUI vs pure CLI + git).

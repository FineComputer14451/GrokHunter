---
name: aider-grok
description: >-
  Optional Aider pair-programmer wired to Grok/xAI inside GrokHunter Rootless.
  Activate when the user wants git-native terminal pair programming alongside
  or instead of the Grok TUI.
---

# Aider + Grok (GrokHunter Rootless)

You help the operator use **Aider** as a terminal pair programmer with **xAI / Grok 4.5** inside the rootless Kali lab.

## When to activate

- User asks for Aider, “git-aware pair”, auto-commit coding sessions
- Preference for CLI-only pair programming over the Grok TUI
- Combining Aider with the existing `XAI_API_KEY`

## Setup (paste-ready)

```bash
# Preferred — overlay only (no rootfs re-download):
bash ~/GrokHunter/install.sh --overlay-only --with-aider

# Full install path:
bash ~/GrokHunter/install.sh --with-aider

# Manual inside nethunter:
sudo apt update && sudo apt install -y python3-pip python3-venv git
python3 -m venv ~/venv-aider && source ~/venv-aider/bin/activate
pip install -U aider-chat

# Auth (reuse GrokHunter secrets — never print the key)
[ -f ~/.grok/secrets.env ] && source ~/.grok/secrets.env
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"
export AIDER_MODEL=grok-4.5
```

Installer places **`bin/aider-grok`** into `~/.local/bin` and (when possible) the Kali rootfs. Canonical source is the repo file — not a heredoc snapshot.

## Daily use

```bash
cd ~/my-project
aider-grok                 # recommended — auto secrets + model + venv
# or
source ~/venv-aider/bin/activate
aider --model "${AIDER_MODEL:-grok-4.5}"
```

### Overrides

```bash
AIDER_MODEL=grok-4.5 aider-grok
aider-grok --model grok-4.5
# OpenAI-compatible base (default already set by helper):
# OPENAI_API_BASE=https://api.x.ai/v1
```

## Rules

- Prefer small, reviewable edits
- Never print or commit API keys
- Aider auto-commits by default — mention that when starting a session
- Default model is **grok-4.5**; override with `AIDER_MODEL` or `--model` if needed
- If `aider` is missing: re-run `--overlay-only --with-aider` or manual venv steps above

## Relation to Grok Build

| Tool | Role |
|------|------|
| `grok` / `grokhunter` | Default interactive + headless agent for this lab |
| `aider-grok` / `aider` | Optional git-native terminal pair-programmer using the same key |
| `scripts/spacexai_smoke.sh` | API key / Responses smoke (not a pair session) |

Both can coexist. Guide the user to the tool that matches the session (TUI vs pure CLI + git).

## Troubleshooting

```bash
grokhunter doctor
which aider-grok
ls -la ~/venv-aider/bin/aider /home/kali/venv-aider/bin/aider 2>/dev/null
test -r ~/.grok/secrets.env && echo "secrets: present" || echo "secrets: missing"
# reinstall helper only:
bash ~/GrokHunter/install.sh --overlay-only --with-aider
```

Docs: `docs/EDITORS.md`, `docs/GROK-45.md`.

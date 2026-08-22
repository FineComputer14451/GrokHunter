---
name: aider-grok
description: >-
  Optional Aider pair-programmer wired to Grok/xAI inside GrokHunter Rootless.
  Activate when the user wants git-native terminal pair programming alongside
  or instead of the Grok TUI.
---

# Aider + Grok (GrokHunter Rootless)

You help the operator use **Aider** as a terminal pair programmer with **xAI / Grok 4.6** inside the rootless Kali lab.

## When to activate

- User asks for Aider, “git-aware pair”, auto-commit coding sessions
- Preference for CLI-only pair programming over the Grok TUI
- Combining Aider with the existing `XAI_API_KEY`
- Repairing `aider-grok` helper or `~/venv-aider`

## Setup (paste-ready)

```bash
# Preferred — overlay only (no rootfs re-download):
bash ~/GrokHunter/install.sh --overlay-only --with-aider

# Repair Aider only (uv + managed Python 3.12 — required on Kali 3.13):
bash ~/GrokHunter/scripts/install_aider.sh
GROKHUNTER_FORCE_AIDER=1 bash ~/GrokHunter/scripts/install_aider.sh

# Full install path:
bash ~/GrokHunter/install.sh --with-aider

# Also refresh wrappers + lab skills:
grokhunter skills install

# Official upstream (same uv approach):
curl -LsSf https://aider.chat/install.sh | sh

# Auth (reuse GrokHunter secrets — never print the key)
[ -f ~/.grok/secrets.env ] && source ~/.grok/secrets.env
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"
export AIDER_MODEL=grok-4.6
```

**Do not** `pip install aider-chat` into system Python 3.13 — it will fail (`requires-python <3.13`). Use `scripts/install_aider.sh`.

Installer places **`bin/aider-grok`** into `~/.local/bin` and (when possible) the Kali rootfs. Canonical source is the repo file.

## Daily use

```bash
cd ~/my-project
aider-grok                 # recommended — auto secrets + model + venv
# or
source ~/venv-aider/bin/activate
aider --model "${AIDER_MODEL:-grok-4.6}"
```

### Overrides

```bash
AIDER_MODEL=grok-4.6 aider-grok
aider-grok --model grok-4.6
# OPENAI_API_BASE defaults to https://api.x.ai/v1 inside the helper
```

### What `aider-grok` does

1. Sources `~/.grok/secrets.env` if present  
2. Sets `OPENAI_API_BASE=https://api.x.ai/v1` and maps `XAI_API_KEY` → `OPENAI_API_KEY`  
3. Defaults `AIDER_MODEL=grok-4.6`  
4. Finds `aider` via PATH, `~/.local/bin` (uv tool), or `~/venv-aider`  
5. Runs `aider --model …` unless user already passed `--model`

## Rules

- Prefer small, reviewable edits
- Never print or commit API keys
- Aider **auto-commits by default** — mention that when starting a session
- Default model is **grok-4.6**; override with `AIDER_MODEL` or `--model`
- If `aider` is missing: re-run `--overlay-only --with-aider` or manual venv steps

## Relation to other tools

| Tool | Role |
|------|------|
| `grok` / `grokhunter` | Default interactive + headless agent |
| `aider-grok` / `aider` | Git-native terminal pair (same key) |
| `grokhunter ai-smoke` | API key / Responses smoke (not a pair session) |
| `grokhunter skills` | Lab skill files + PATH wrappers |
| `pair-programming` skill | Coding session style for Grok TUI |
| skill `editor-lab` | Human editors (`nvim` / `micro`) — not a pair tool |

Both Grok Build and Aider can coexist. Match the tool to the session (TUI vs pure CLI + git).

## Troubleshooting

```bash
grokhunter doctor
which aider-grok
ls -la ~/venv-aider/bin/aider /home/kali/venv-aider/bin/aider 2>/dev/null
test -r ~/.grok/secrets.env && echo "secrets: present" || echo "secrets: missing"
grokhunter skills install
bash ~/GrokHunter/install.sh --overlay-only --with-aider
grokhunter ai-smoke    # verifies XAI_API_KEY reaches api.x.ai
```

| Symptom | Fix |
|---------|-----|
| `aider not found` | `bash scripts/install_aider.sh` or `--overlay-only --with-aider` |
| pip / Python 3.13 errors | Expected — use uv installer, not plain pip on 3.13 |
| `ensurepip` / venv errors | `sudo apt install -y python3-venv python3-full` then re-run script |
| `aider-grok` missing | `grokhunter skills install` or overlay install |
| Auth / 401 | Fix `XAI_API_KEY` in secrets.env; `ai-smoke` |
| Wrong model | `AIDER_MODEL=grok-4.6` or `--model` |
| Commits unwanted | Start Aider with no-auto-commit flags per Aider docs; warn user |

Docs: `docs/EDITORS.md`, `docs/GROK-46.md`.

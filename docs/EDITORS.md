# Editors & Pair Programmers on GrokHunter Rootless

Grok Build (`grok` / `grokhunter`) is the default on-device pair programmer.  
This doc covers optional tools that complement it.

## Default path (already installed with `--with-grok`)

```bash
grok                       # interactive pair session
grokhunter -p "…"          # headless one-shot
grokhunter plan "…"        # plan larger changes first
nh-x11                     # XFCE desktop for editors (if --with-x11)
```

## Aider + Grok (recommended optional)

[Aider](https://aider.chat) is a terminal pair-programmer that works well inside the Kali proot. It can use xAI’s API (or other providers).

### Install (inside `nethunter`)

```bash
nethunter
sudo apt update
sudo apt install -y python3-pip python3-venv git
python3 -m venv ~/venv-aider
source ~/venv-aider/bin/activate
pip install aider-chat
```

### Configure for Grok / xAI

```bash
# Prefer secrets file (already used by GrokHunter)
# Ensure XAI_API_KEY is set, e.g.:
#   export XAI_API_KEY=xai-...
# or source ~/.grok/secrets.env

export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"

# Optional: pin a model name your key supports
export AIDER_MODEL=grok-4
# or: export AIDER_MODEL=grok-3
```

### Usage

```bash
cd /path/to/your/project
source ~/venv-aider/bin/activate
aider                          # chat + edit with git-aware commits
aider --model grok-4           # explicit model
aider main.py utils.py         # limit to specific files
```

Tips:
- Aider auto-commits by default — great for mobile sessions where you want a clear history.
- Use `--no-auto-commits` if you prefer manual commits.
- Keep `XAI_API_KEY` in `~/.grok/secrets.env` (mode 600); never commit it.

### One-liner helper (optional)

```bash
# Save as ~/bin/aider-grok and chmod +x
#!/data/data/com.termux/files/usr/bin/bash
source "${HOME}/venv-aider/bin/activate" 2>/dev/null || true
[ -f "${HOME}/.grok/secrets.env" ] && source "${HOME}/.grok/secrets.env"
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY:-$OPENAI_API_KEY}"
exec aider "$@"
```

## opencode (optional)

Community Termux/ARM builds exist for [opencode](https://github.com/opencode-ai). Prefer official docs for the latest aarch64 package. Typical pattern:

```bash
# Example only — check current release assets
# wget …/opencode_*_aarch64.deb && sudo apt install ./opencode_*.deb
opencode
# Some builds support: opencode web
```

Use when you want a second agent UI; Grok Build remains the primary pair programmer for this lab.

## Lightweight editors on device

| Tool | When to use |
|------|-------------|
| `nh-x11` + XFCE | Full desktop (Geany, mousepad, etc.) |
| `nvim` / `micro` | Terminal editing inside `nethunter` |
| [Acode](https://acode.app) | Native Android editor beside Termux |

```bash
# Inside nethunter
sudo apt install -y neovim micro
```

## Recommendation

1. **Default:** `grok` / `grokhunter` (already optimized for this lab).  
2. **Add Aider** when you want git-native, auto-commit pair sessions with the same xAI key.  
3. **Desktop:** `nh-x11` when you need a visual editor.

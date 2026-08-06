# Editors & Pair Programmers on GrokHunter Rootless

**Default intelligence: Grok 4.5** via Grok Build (`grok` / `grokhunter`).  
This doc covers optional tools that complement it.

## Default path (`--with-grok`)

```bash
grok                       # interactive pair session (Grok 4.5-class)
grokhunter -p "…"          # headless one-shot
grokhunter plan "…"        # plan larger changes first
nh-x11                     # XFCE desktop for editors (if --with-x11)
```

See also: [GROK-45.md](GROK-45.md).

## Aider + Grok 4.5 (recommended optional)

[Aider](https://aider.chat) is a terminal pair-programmer that works well inside the Kali proot. Use the same xAI key.

### Install

```bash
# Via installer flag (preferred):
bash install.sh --with-aider

# Or manually inside nethunter:
sudo apt install -y python3-pip python3-venv git
python3 -m venv ~/venv-aider
source ~/venv-aider/bin/activate
pip install -U aider-chat
```

The installer also places the `aider-grok` helper in `~/.local/bin` and (when possible) inside the rootfs.

### Configure for Grok / xAI (Grok 4.5 tier)

```bash
[[ -f ~/.grok/secrets.env ]] && source ~/.grok/secrets.env
export OPENAI_API_BASE=https://api.x.ai/v1
export OPENAI_API_KEY="${XAI_API_KEY}"

# Default in aider-grok is already grok-4.5
# Override only if your account exposes a different coding id:
# export AIDER_MODEL=grok-4.5
```

### Usage

```bash
cd /path/to/your/project
aider-grok                 # recommended helper (auto model + secrets)
# or
source ~/venv-aider/bin/activate && aider --model "${AIDER_MODEL:-grok-4.5}"
aider-grok main.py utils.py   # limit to specific files
```

Tips:
- Aider auto-commits by default — good for mobile history.
- `--no-auto-commits` if you prefer manual commits.
- Never commit `~/.grok/secrets.env`.

## Lightweight editors on device

| Tool | When to use |
|------|-------------|
| `nh-x11` + XFCE | Full desktop |
| `nvim` / `micro` | Terminal editing inside `nethunter` |
| [Acode](https://acode.app) | Native Android editor beside Termux |

```bash
sudo apt install -y neovim micro
```

## Recommendation

1. **Default:** `grok` / `grokhunter` optimized for **Grok 4.5**.  
2. **Aider** (`aider-grok`) when you want git-native auto-commit pairs on the same key.  
3. **Desktop:** `nh-x11` when you need a visual editor.

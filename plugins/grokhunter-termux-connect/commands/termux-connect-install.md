---
name: termux-connect-install
description: Install the Termux Connect HTTP MCP on the phone (venv + token + start script)
---

Install Termux Connect on this device:

```bash
bash plugins/grokhunter-termux-connect/skills/termux-connect/scripts/install.sh
```

Then start (prefer tmux):

```bash
~/.grokhunter-termux-connect/start.sh
```

Do **not** print `~/.grokhunter-termux-connect/token`. Next: `/termux-connect-tunnel`.

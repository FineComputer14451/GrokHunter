---
name: grokhunter
description: GrokHunter Rootless orchestrator for the on-device coding lab. Activate for setup, doctor, PATH/config repair, and launching pair-programming or build workflows.
---

# GrokHunter Skill

You are the **GrokHunter** operator on a rootless Kali NetHunter lab optimized for **coding and building** with Grok Build as the pair programmer.

## When to activate

- User says `grokhunter`, `fix my grok`, `mobile coding lab`, or similar
- Install / doctor / PATH / auth issues
- Choosing desktop (`nh-x11`) vs shell-only workflows
- Starting or repairing a pair-programming session

## Facts

| Item | Value |
|------|-------|
| Overlay | `~/GrokHunter` or `$GROKHUNTER_HOME` |
| Launch | `grokhunter` / `grok` |
| Doctor | `grokhunter doctor` |
| Ensure binary | `grokhunter ensure` |
| Config | `~/.grok/config.toml` (pair-programming profile) |
| Secrets | `~/.grok/secrets.env` mode 600 |
| Skills | `pair-programming`, `grokhunter` |

## Playbooks

### Fresh bootstrap

```bash
cd ~/GrokHunter && bash install.sh --full --de xfce --with-grok --with-x11
source ~/.zshrc 2>/dev/null || true
grokhunter doctor
# auth
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env
grok
```

### Repair PATH

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
bash ~/GrokHunter/install.sh
```

### Pair session

```bash
grok
# or headless:
grokhunter -p "Implement X and show the diff"
```

## Response style

Short commands, mobile-friendly, never print secrets.

---
name: grokhunter
description: GrokHunter orchestrator for Kali NetHunter powered by Grok Build. Activate for NetHunter setup, doctor checks, agent workflows on mobile chroots, PATH and config repair, and launching recon or studio workflows on this rootfs.
---

# GrokHunter Skill

You are the **GrokHunter** operator agent on a Kali NetHunter rootfs with Grok Build as the primary coding/security assistant.

## When to activate

- User says `grokhunter`, `nethunter grok`, `fix my grok on nethunter`, or `mobile kali agent`
- Doctor / install / PATH / auth issues on this chroot
- Choosing between Termux-native GrokTerm vs NetHunter overlay
- Daily driver workflows that mix Kali tools + Grok Build

## Facts

| Item | Value |
|------|-------|
| Overlay root | `~/GrokHunter` or `$GROKHUNTER_HOME` |
| Launch | `grokhunter` / `grok-nethunter` |
| Doctor | `grokhunter doctor` |
| Ensure binary | `grokhunter ensure` |
| Min Grok | `0.2.93` (prefer latest) |
| Config | `~/.grok/config.toml` (NetHunter compact UX) |
| Secrets | `~/.grok/secrets.env` mode 600 |
| Skills | `~/.grok/skills/grokhunter`, `nethunter-recon` |

## Playbooks

### Fresh device bootstrap

```bash
cd ~/GrokHunter && bash install.sh
source ~/.zshrc
grokhunter doctor
# auth
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env
grokhunter
```

### Repair PATH / command not found

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
bash ~/GrokHunter/install.sh
```

### Headless automation

```bash
grokhunter -p "Audit open listeners with ss -tulpn and summarize"
```

### Optional Cinematic Studio

If `~/Grok-Imagine-Cinematic-Studio` exists:

```bash
cinematic-studio grok status
# or Method A meta installer from that repo
```

## NetHunter vs Termux

- **NetHunter chroot**: real `/etc/resolv.conf` — no DNS byte-patch.
- **Bare Termux**: use GrokTerm / grok-cli-termux-native DNS patch; GrokHunter is the wrong stack.

## Ethics

Follow `AGENTS.md` in GrokHunter: authorized testing only; no live exploit delivery against unauthorized targets.

## Response style

Short commands, mobile-friendly, show doctor output interpretation, never print secrets.

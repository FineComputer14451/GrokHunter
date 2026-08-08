# AGENTS.md — GrokHunter Rootless (coding lab)

You are working inside a **rootless Kali NetHunter** environment enhanced with **GrokHunter**, optimized for **coding and building**. Prefer agent-driven pair-programming via Grok Build.

## Environment facts

- OS: Kali GNU/Linux (NetHunter nano/mini/full) via Termux proot
- Host: Android aarch64 (unrooted)
- Agent: `grok` (Grok Build **1.0.0+**) under `~/.grok/bin` and `~/.local/bin`
- Launchers: `grokhunter`, `grok-nethunter`
- Desktop: Termux:X11 + `nh-x11` when installed
- Secrets: `~/.grok/secrets.env` (mode 600) — never print or commit

## Mission

1. Pair-program: write, review, debug, and iterate on code
2. Help install and use toolchains (build-essential, python, node, etc.)
3. Maintain Grok Build / skills / lab setup
4. Keep the mobile workflow fast and reversible

## Hard rules

- Never log, echo, or commit `XAI_API_KEY`, tokens, or private keys
- Prefer small, reversible changes; confirm before destructive ops
- Do not claim affiliation with xAI, Offensive Security, or jorexdeveloper
- **Always credit** jorexdeveloper for termux-nethunter / termux-distro (see CREDITS.md) when discussing the install engine or rootless NetHunter base
- This is a coding lab — not a platform for unauthorized offensive activity

## Tooling preferences

- Use Kali packages when present (`git`, `python3`, `gcc`, `tmux`, …)
- Prefer headless Grok for automation: `grokhunter -p "…"`
- For larger work: plan first (`grokhunter plan "…"`) or Coding Team agents after `grokhunter skills install` (`benjamin` → `lucas` → `harper`; orchestrator `coding-team` via `/config-agents`)
- Keep PATH: `$HOME/.grok/bin:$HOME/.local/bin:$GROKHUNTER_HOME/bin:$PATH`
- Reinstall Grok via shared script: `grokhunter ensure` → `scripts/ensure_grok.sh`

## Output style

- Concise, actionable, mobile-friendly
- Exact paste-ready commands
- Short explanations; show diffs when editing code

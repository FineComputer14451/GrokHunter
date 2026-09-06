---
name: shell-lab
description: >-
  Use when GrokHunter tab-complete is missing, ghd/ghsu aliases unknown, or PATH
  dies after a new shell.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/shell-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Shell lab (optional)

You fix **interactive shell** integration. Termux vs Kali is skill `host-lab`. tmux persist is skill `session-lab`. The installer does not edit `.zshrc` / `.bashrc` — the user must source the profile.

## When to activate

- `grokhunter <TAB>` does nothing
- `ghd` / `ghsu` not found after overlay-only
- New shell lost PATH

## Commands

```bash
bash ~/GrokHunter/scripts/install-completions.sh
# or:
bash ~/GrokHunter/install.sh --overlay-only --with-completions
```

Add once to rc:

```zsh
# ~/.zshrc
[[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
autoload -Uz compinit && compinit
```

```bash
# ~/.bashrc
[[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
```

`gh` is not aliased (GitHub CLI). Profile sources `~/.grok/secrets.env` when present — never print it.

## Common failures

| Symptom | First step |
|---------|------------|
| rc never sources `profile.sh` | One-line append |
| TAB / `ghd` missing | `source ~/.grok/profile.sh`; completions script |
| Wrappers not copied | agent `overlay` / overlay-only install |

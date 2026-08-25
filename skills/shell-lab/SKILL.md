---
name: shell-lab
description: >-
  GrokHunter shell integration: ~/.grok/profile.sh, zsh/bash completions,
  aliases (ghd, ghsu). Use when tab-complete is missing, aliases are unknown,
  or PATH dies after a new shell. Optional skill — not part of skills-core N/3.
---

# Shell lab (optional)

You fix **interactive shell** integration. Wrappers *install* is agent `overlay`. Termux vs Kali is skill `host-lab`. tmux persist is skill `session-lab`.

The installer **does not** edit `.zshrc` / `.bashrc`. The user must source the profile.

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

Add **once** (do not rewrite the whole rc):

```zsh
# ~/.zshrc
[[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
autoload -Uz compinit && compinit
```

```bash
# ~/.bashrc
[[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
```

Then `source ~/.zshrc` (or open a new terminal). Docs: `docs/SHELL.md`.

`gh` is **not** aliased (GitHub CLI). Profile sources `~/.grok/secrets.env` when present — never print it.

## Common failures

| Symptom | First step |
|---------|------------|
| rc never sources `profile.sh` | One-line append (installer never auto-edits rc) |
| TAB / `ghd` missing | `source ~/.grok/profile.sh`; completions script |
| Wrappers not copied | agent `overlay` |

## Verify

```bash
type ghd
```

## Cross-links

- Agent `shell`
- PATH wrappers missing: agent `overlay`
- Wrong OS: skill `host-lab`
---

# Shell integration (zsh & bash)

GrokHunter is designed to work well from **zsh** (and bash) on Termux or desktop.

> Note: `install.sh` itself is **bash** (Termux shebang). Daily use of `grokhunter` / `nh-x11` from zsh is fully supported.

## Quick setup (zsh)

```bash
cd ~/GrokHunter   # or your clone path
bash scripts/install-completions.sh
```

The installer copies `~/.grok/profile.sh` and completions; it does **not** modify `.zshrc` or `.bashrc`. Add the source line yourself:

Add to `~/.zshrc`:

```zsh
[[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
autoload -Uz compinit && compinit
```

Reload:

```zsh
source ~/.zshrc
```

Tab-complete:

```zsh
grokhunter <TAB>
grokhunter models <TAB>
grokhunter ai-smoke <TAB>
grokhunter install --de <TAB>
```

## Bash

Same installer. In `~/.bashrc`:

```bash
[[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
```

## What gets installed

| Path | Purpose |
|------|----------|
| `~/.grok/completions/zsh/_grokhunter` | zsh completion for `grokhunter` |
| `~/.grok/completions/zsh/_nh-x11` | zsh hints for `nh-x11` |
| `~/.grok/completions/bash/grokhunter.bash` | bash completion |
| `~/.grok/profile.sh` | PATH, secrets, fpath, aliases |

## Aliases (from profile)

| Alias | Expands to |
|-------|------------|
| `ghn` | `grok-nethunter` |
| `ghd` | `grokhunter doctor` |
| `ghs` | `grokhunter status` |
| `ghsu` | `grokhunter setup` |
| `ght` | `grokhunter team` |
| `ghp` | `grokhunter plan` |
| `ghm` | `grokhunter models` |
| `ghk` | `grokhunter skills` |
| `ghai` | `grokhunter ai-smoke` |
| `ghh "…"` | `grokhunter -p "…"` |

`gh` is **not** aliased (leaves GitHub CLI unshadowed).

## Termux tip

```bash
pkg install zsh
chsh -s zsh    # if available; or set terminal command to zsh
```

Keep `install.sh` runs in bash; use zsh for interactive coding sessions.

Playbook: skill `shell-lab` · `grokhunter shell`.

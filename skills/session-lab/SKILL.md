---
name: session-lab
description: >-
  Persist GrokHunter work on a phone: tmux detach/attach, grok /resume,
  Termux background kills. Use when the TUI vanished, Termux was
  backgrounded, or the user asks how to keep a coding session alive.
  Optional skill — not part of skills-core N/3.
---

# Session lab (optional)

You keep **shell and Grok conversations** alive across Android backgrounding. X11 desktop sessions are skill `x11-desktop` / agent `desktop`. Pair *content* is `pair-programming`.

## When to activate

- `grok` / `grokhunter` died after switching apps
- User wants tmux, detach, or “resume yesterday”
- Termux killed the foreground process

## Shell persist (tmux)

Inside Kali:

```bash
sudo apt install -y tmux
tmux new -s lab
# detach: Ctrl-b d
tmux attach -t lab
tmux ls
```

On the Termux **host** use `pkg install tmux` instead of apt. Prefer **one** layer (host *or* guest), not nested tmux.

Host wake-lock (Termux):

```bash
termux-wake-lock
# later: termux-wake-unlock
```

## Grok conversation resume

```bash
grok --resume              # most recent in this cwd
grok --resume '<id-or-title>'
```

In TUI: `/resume` · `/rename` · `/fork` · `/dashboard` (aliases `/sessions`).

History lives under `~/.grok/sessions/` (URL-encoded cwd). Do not dump session files into chat.

## Cross-links

- Completions / profile: `docs/SHELL.md`
- Desktop persist: skill `x11-desktop` (`nh-x11`, not tmux)
- Agent `session` for attach/resume playbooks
---

---
name: session-lab
description: >-
  Use when GrokHunter TUI vanished after app switch, Termux backgrounded the
  process, or the user needs tmux / grok --resume.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/session-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Session lab (optional)

You keep **shell and Grok conversations** alive across Android backgrounding. X11 desktop sessions are skill `x11-desktop`. Pair content is `pair-programming`.

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
```

On Termux host use `pkg install tmux`. Prefer one layer (host or guest), not nested tmux.

```bash
termux-wake-lock
# later: termux-wake-unlock
```

## Grok conversation resume

```bash
grok --resume
grok --resume '<id-or-title>'
```

TUI: `/resume` · `/rename` · `/fork` · `/dashboard`. History under `~/.grok/sessions/` — do not dump session files into chat.

## Common failures

| Symptom | First step |
|---------|------------|
| TUI vanished after app switch | `tmux attach` or `grok --resume` |
| Nested tmux | Prefer host or guest, not both |
| Desktop session died | skill `x11-desktop` |

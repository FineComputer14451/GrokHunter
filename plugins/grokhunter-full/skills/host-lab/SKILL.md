---
name: host-lab
description: >-
  Use when the user is lost between Termux host and Kali NetHunter guest —
  PREFIX, pkg vs apt, PATH, or install.sh Termux-only errors.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/host-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Host lab (optional)

You explain **which OS the user is in** and how PATH/packages differ. Installer extract and wrapper install belong to agent `overlay`.

## When to activate

- `grokhunter: command not found` in one terminal, works in another
- `pkg` vs `apt` confusion
- `install.sh` says it only works inside Termux
- User asks “am I in Kali or Termux?”

## Where am I?

```bash
echo "PREFIX=${PREFIX:-unset}"
uname -o 2>/dev/null; uname -m
command -v pkg; command -v apt
command -v nethunter; command -v grokhunter; command -v grok
echo "$PATH"
```

| Signal | Termux host | Kali guest (proot) |
|--------|-------------|---------------------|
| `PREFIX` | `…/com.termux/files/usr` | usually unset |
| Packages | `pkg` | `apt` |
| Enter guest | `nethunter` / `nh` | already inside |
| Desktop | Termux:X11 APK | `nh-x11` from guest |

`install.sh` (one-liner / rootfs) is a **Termux** script. Overlay-only from a Kali clone is OK for wrappers/skills.

## PATH (both sides)

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
source ~/.grok/profile.sh 2>/dev/null || true
```

## Common failures

| Symptom | First step |
|---------|------------|
| grokhunter in one shell only | PATH + `source ~/.grok/profile.sh` |
| `pkg` vs `apt` | PREFIX set → Termux host; apt → Kali guest |
| `install.sh` refuses Kali | One-liner is Termux; overlay-only from Kali clone is OK |

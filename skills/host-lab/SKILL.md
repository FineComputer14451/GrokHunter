---
name: host-lab
description: >-
  Termux host vs Kali NetHunter guest: PREFIX, apt vs pkg, PATH, nethunter
  entry. Use when grokhunter is missing in one shell but not the other,
  install.sh refuses Termux, or the user is lost between Android and proot.
  Optional skill — not part of skills-core N/3.
---

# Host lab (optional)

You explain **which OS the user is in** and how PATH/packages differ. Installer extract, overlay cache, and wrapper *install* belong to agent `overlay`.

**Not affiliated** with Termux, Kali, or jorexdeveloper. Credit: Termux team (host), jorexdeveloper (nethunter/distro), Kali/OffSec (rootfs), xAI (Grok).

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

| Signal | Termux **host** | Kali **guest** (proot) |
|--------|-----------------|------------------------|
| `PREFIX` | `…/com.termux/files/usr` | usually unset |
| Packages | `pkg` | `apt` |
| Enter guest | `nethunter` / `nh` | already inside |
| Desktop | Termux:X11 APK | `nh-x11` from guest |

`install.sh` (one-liner / rootfs) is a **Termux** script. Overlay-only from a Kali clone is OK for wrappers/skills.

## PATH (both sides)

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
source ~/.grok/profile.sh 2>/dev/null || true
# persist: docs/SHELL.md (do not edit rc unless asked)
```

Wrappers land in `~/.local/bin` (`grokhunter skills install` / overlay-only). New shell or `source` after install.

## Cross-links

- Wrappers / overlay-only: agent `overlay`
- X11: skill `x11-desktop`
- Apt toolchains: skill `toolchain`
- Agent `host` for diagnosis cards
---

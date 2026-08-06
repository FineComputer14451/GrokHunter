---
name: x11-desktop
description: >-
  Termux:X11 coding-desktop fix and tune for GrokHunter Rootless. Activate for
  black screen, lag/jank, compositor issues, nh-x11 recovery, NH_X11_LEGACY,
  sharedUid APK choice, and performance tuning on Android. Optional skill —
  not required for a healthy coding lab.
---

# X11 Desktop Skill (optional)

GrokHunter coding lab on **unrooted Android** + Termux:X11. This skill is for
**fix & tune** of the coding desktop — not full product install.

| Need | Use skill |
|------|-----------|
| Install, doctor, PATH, models, skills CLI | **`grokhunter`** |
| Write / debug application code | **`pair-programming`** |
| Aider | **`aider-grok`** |
| X11 black screen, lag, performance | **this skill** |

## When to activate

- Black / blank screen after `nh-x11`
- Desktop lag, jank, low FPS on phone
- XFCE compositor / sharedUid APK questions
- `NH_X11_LEGACY`, Termux:X11 preference tweaks
- "X11 slow", "desktop performance", coding desktop recovery

## Quick triage

1. Is **Termux:X11** APK installed on the Android host?
2. Are you inside the **Kali proot** where `nh-x11` is on PATH?
3. Was the lab installed with **`--with-x11`** (or overlay-only equivalent)?
4. Prefer rootfs on **internal storage**, not SD card.

```bash
command -v nh-x11 || ls -la ~/.local/bin/nh-x11
echo "DISPLAY=${DISPLAY:-unset}"
```

## Ranked wins (do in order)

| Priority | Action | Why |
|----------|--------|-----|
| 1 | **sharedUid** Termux:X11 APK (GitHub Termux) | Stops Android throttling when X11 is foreground |
| 2 | **Disable XFCE compositing** | Biggest smoothness gain under proot |
| 3 | **Light DE** (XFCE / i3) | Less CPU/RAM than GNOME/KDE |
| 4 | **Share `/tmp`** | X sockets; normally patched by `--with-x11` |
| 5 | **Avoid SD-card rootfs** | Faster apt, editors, builds |
| 6 | Optional GPU (Turnip/Zink) | Advanced; device-specific |

Deep detail: `docs/X11-PERFORMANCE.md`.

## Recovery commands

```bash
# Default launch
nh-x11

# Black screen on some devices
NH_X11_LEGACY=1 nh-x11

# Disable XFCE compositor (inside Kali session)
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true
```

APK nightlies: https://github.com/termux/termux-x11/releases/tag/nightly

| APK | Notes |
|-----|--------|
| `termux-x11-universal-debug.apk` | Works with F-Droid Termux |
| `termux-x11-universal-sharedUid-debug.apk` | Best performance if Termux is from **GitHub** |

## Safety

- Prefer reversible tweaks first (compositor, launch flags).
- Never print or commit `XAI_API_KEY` / secrets.
- Default product mission is **coding lab**, not offensive ops.
- Do not invent root/Magisk/HID capabilities for rootless GrokHunter.

## After desktop is usable

```bash
grokhunter doctor
grok
# or pair-programming skill for app work
```

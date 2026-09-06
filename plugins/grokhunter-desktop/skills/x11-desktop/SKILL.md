---
name: x11-desktop
description: >-
  Use for GrokHunter Termux:X11 black screen, lag, nh-x11 recovery, grokhunter
  binds, bwrap/glycin, or Android desktop performance tuning.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/x11-desktop` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI. Do not invent Magisk/HID/root capabilities.

# X11 Desktop Skill (optional)

Fix & tune the **Termux:X11 coding desktop** for GrokHunter Rootless — not full product install.

| Need | Use skill |
|------|-----------|
| Install, doctor, PATH, models | `grokhunter` |
| Write / debug code | `pair-programming` |
| Aider | `aider-grok` |
| X11 black screen, lag, binds | **this skill** |

## When to activate

- Black / blank screen after `nh-x11`
- Desktop lag, jank, low FPS
- XFCE compositor / sharedUid APK questions
- `NH_X11_LEGACY`, missing `/tmp` binds / X sockets
- XFCE panel dies / glycin `bwrap` abort
- `Cannot open display` or `Unrecognized option '-lc'`

## Quick triage

1. Termux:X11 APK installed on Android host?
2. Inside Kali proot where `nh-x11` is on PATH?
3. Installed with `--with-x11` (or overlay-only equivalent)?
4. Prefer rootfs on **internal storage**, not SD.

```bash
command -v nh-x11 || ls -la ~/.local/bin/nh-x11
echo "DISPLAY=${DISPLAY:-unset}"
grokhunter binds status
```

## Ranked wins

1. **sharedUid** Termux:X11 APK (GitHub Termux) — best performance
2. **Disable XFCE compositing**
3. Light DE (XFCE / i3)
4. Share `/tmp` for X sockets
5. Avoid SD-card rootfs
6. Optional GPU (Turnip/Zink) — advanced

## Recovery

```bash
nh-x11
NH_X11_LEGACY=0 nh-x11
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true
grokhunter binds status
grokhunter binds repair
```

Do **not** use `su --login` (clears DISPLAY). Session env: `XDG_RUNTIME_DIR=/tmp/runtime-kali` (mode 700).

APK nightlies: https://github.com/termux/termux-x11/releases/tag/nightly
- `termux-x11-universal-debug.apk` — F-Droid Termux
- `termux-x11-universal-sharedUid-debug.apk` — best if Termux from GitHub

## Common failures

| Symptom | First step |
|---------|------------|
| Binds missing / `/tmp` X socket | `grokhunter binds status` then repair/optimize |
| XFCE panel / glycin bwrap | `nh-x11` installs `bwrap-proot`; see docs/TROUBLESHOOTING.md |
| `Cannot open display` | `nh-x11` `--env` + non-login `su -c` |
| GPU crash | legacy drawing on; `NH_X11_LEGACY=0` to disable |

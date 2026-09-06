---
name: storage-lab
description: >-
  Use when GrokHunter install fails on disk space, df is tight, or the user asks
  what cache/sessions to delete on the phone lab.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/storage-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Storage lab (optional)

You keep the phone **from filling up**. Apt packages stay skill `toolchain`. Confirm before any delete.

## When to activate

- Installer / apt / Grok plugin clone fails on disk
- Doctor or user says storage is tight
- `df` looks full; SD-card rootfs is slow

## Look first

```bash
df -h
du -sh ~/.cache/grokhunter ~/.grok/sessions ~/.grok/installed-plugins 2>/dev/null
```

| Need | Do |
|------|----|
| New rootfs, little space | `--nano` or `--mini`, `--no-de` |
| Already have Kali | `--overlay-only` |
| Slow compiles / X11 | rootfs on **internal** storage, not SD |
| Android shared files | Termux `termux-setup-storage` |

## Safe cleanup (ask first)

```bash
# rm -rf ~/.cache/grokhunter/lib
# rm -rf ~/.grok/sessions/<encoded-cwd>
```

Do **not** delete the Kali rootfs or `~/.grok/secrets.env`. Uninstall overlay only: `bash uninstall.sh` (keeps rootfs).

## Common failures

| Symptom | First step |
|---------|------------|
| SD-card rootfs slow / full | Prefer internal |
| Overlay cache fill | `du -sh ~/.cache/grokhunter`; ask before `rm` |
| Install failed on space | `--nano` / `--mini` / `--overlay-only` |

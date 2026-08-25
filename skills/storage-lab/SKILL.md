---
name: storage-lab
description: >-
  Disk and cache on the GrokHunter Android lab: internal vs SD, --mini/--nano,
  ~/.cache/grokhunter, sessions. Use when install fails on space, df is tight,
  or the user asks what to delete. Optional skill — not part of skills-core N/3.
---

# Storage lab (optional)

You keep the phone **from filling up**. Apt packages stay skill `toolchain`. Overlay *install* stays agent `overlay`. Confirm before any delete.

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
| Already have Kali | `--overlay-only` — no rootfs download |
| Slow compiles / X11 | rootfs on **internal** storage, not SD (`docs/PROOT.md`) |
| Android shared files | Termux `termux-setup-storage` (host) |

## Safe cleanup (ask first)

```bash
# overlay module cache (re-downloads on next one-liner)
# rm -rf ~/.cache/grokhunter/lib
# old Grok sessions (loses /resume history)
# rm -rf ~/.grok/sessions/<encoded-cwd>
```

Do **not** delete the Kali rootfs or `~/.grok/secrets.env`. Uninstall overlay only: `bash uninstall.sh` (keeps rootfs).

## Common failures

| Symptom | First step |
|---------|------------|
| SD-card rootfs slow / full | Prefer internal; `docs/PROOT.md` |
| Overlay cache fill | `du -sh ~/.cache/grokhunter`; ask before `rm` |
| Install failed on space | `--nano` / `--mini` / `--overlay-only` |

## Verify

```bash
df -h
```

## Cross-links

- Agent `storage`
- Toolchain size: skill `toolchain`
- Plugins eating disk: skill `plugin-lab`
- Persist sessions instead of deleting: skill `session-lab`
---

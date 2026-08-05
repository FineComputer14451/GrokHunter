# GrokHunter Architecture

## Design goals

1. **Overlay, not fork** — never rebuild Kali rootfs or NetHunter kernels.
2. **Official Grok binary** — always install via xAI's installer; no custom forks of `grok`.
3. **Idempotent install** — safe to re-run; marker-based shell edits.
4. **Mobile-first UX** — compact TUI, always-approve permission mode, short aliases.
5. **Ethical default** — recon skill and AGENTS.md refuse unauthorized offensive work.

## Layers

```
Android host
  ├── NetHunter App / Magisk / wireless firmware
  └── chroot / proot Kali rootfs
        ├── apt packages (kali-nethunter-nano|core|full)
        └── GrokHunter overlay
              ├── ~/.grok/bin/grok          (official)
              ├── ~/.grok/config.toml       (merged NetHunter profile)
              ├── ~/.local/bin/grokhunter*
              ├── ~/.grok/skills/grokhunter
              ├── ~/.grok/skills/nethunter-recon
              └── shell markers in ~/.zshrc / ~/.bashrc
```

## Why NetHunter (not pure Termux)

| Concern | Termux | NetHunter chroot |
|---------|--------|------------------|
| Full Kali toolchains | Limited | Native apt |
| `/etc/resolv.conf` | Broken for static musl | Works — no DNS byte-patch |
| Root / HID / mana | Host only | Integrated scripts |
| Grok static musl binary | Needs GrokTerm patch | Runs as-is |

GrokHunter therefore **does not** ship the 16-byte DNS patch used by GrokTerm. If you run Grok on bare Termux, use GrokTerm / grok-cli-termux-native instead.

## Install flow

1. Detect NetHunter / Kali + arch
2. Ensure `curl`/`git`/`python3`
3. Ensure Grok Build ≥ min version
4. Install bin wrappers → `~/.local/bin`
5. Merge NetHunter UI/models keys into config (backup first)
6. Install skills → `~/.grok/skills`
7. Inject shell profile markers
8. Optional MOTD (needs root for `/etc/update-motd.d`)
9. Write `~/.grokhunter/install.meta` for doctor/uninstall

## Config merge policy

`install.sh` **does not** replace the entire `config.toml`. It:

- Backs up to `config.toml.bak.grokhunter-<timestamp>`
- Ensures key NetHunter UI keys exist (`compact_mode`, `permission_mode`, `theme`, `screen_mode`)
- Sets `[models] default = "grok-4.5"` only if missing or empty
- Leaves custom `[model.*]` agent definitions untouched

## Uninstall policy

Removes wrappers, skills, shell markers, MOTD fragment. Keeps:

- `~/.grok/bin/grok` and auth
- User projects under `$HOME`
- Config backup files

`--purge-grok` additionally removes Grok binary state (destructive; confirm).

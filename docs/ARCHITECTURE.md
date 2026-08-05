# GrokHunter Rootless — Architecture

## Design goals

1. **Rootless first** — designed exclusively for unrooted Android via Termux + proot.
2. **Overlay, not fork** — never rebuild Kali rootfs or NetHunter kernels.
3. **Official Grok binary** — always install via xAI's installer; no custom forks of `grok`.
4. **Idempotent install** — safe to re-run; marker-based shell edits.
5. **Mobile-first UX** — compact TUI, always-approve permission mode, short aliases.
6. **Ethical default** — recon skill and AGENTS.md refuse unauthorized offensive work.

## Scope

GrokHunter **only** targets the rootless path:

```
Android (stock / unrooted)
  └── Termux
        └── proot → Kali NetHunter rootfs (nano / mini / full)
              └── GrokHunter overlay
                    ├── Grok Build CLI
                    ├── nh-x11 (Termux:X11 helper)
                    ├── grokhunter CLI + doctor
                    └── skills / profile
```

It does **not**:
- Require or install Magisk / custom recovery
- Touch kernels, HID, or firmware modules
- Support or document the classic rooted NetHunter (KeX + Magisk) path

For rooted devices use official Kali NetHunter documentation instead.

## Why rootless (Termux + proot)?

| Concern | Bare Termux | GrokHunter Rootless | Rooted NetHunter |
|---------|-------------|---------------------|------------------|
| Root required | No | **No** | Yes |
| Full Kali tools | Limited | Native apt | Native apt + HID |
| Grok static binary | Needs DNS patch | Runs as-is inside proot | Runs as-is |
| Warranty | Intact | **Intact** | Often voided |
| Target audience | General | **Most Android users** | Advanced / unlocked |

## Install flow (rootless)

1. Detect Termux + architecture
2. Pull latest NetHunter rootfs from Kali `/current/` (dynamic SHA256)
3. Optional: desktop (XFCE default) + browser
4. Optional: native Grok Build CLI
5. Optional: Termux:X11 packages + `nh-x11` helper + `/tmp` bind patch
6. Write install metadata for doctor / uninstall

## Config merge policy

`install.sh` does **not** replace the entire Grok `config.toml`. It:

- Backs up first
- Ensures key mobile UI keys exist
- Sets a sensible default model only if missing
- Leaves custom agent definitions untouched

## Uninstall policy

Removes wrappers, skills, shell markers. Keeps:

- Grok binary and auth
- User projects
- Config backups

`--purge-grok` additionally removes Grok binary state (destructive).

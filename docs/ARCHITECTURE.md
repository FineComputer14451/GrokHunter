# GrokHunter Rootless — Architecture

## Design goals

1. **Rootless first** — unrooted Android via Termux + proot only.
2. **Coding & building focus** — real Linux toolchains + Grok as on-device agent.
3. **Overlay, not fork** — never rebuild Kali rootfs or kernels.
4. **Official Grok binary** — install via xAI’s installer; no custom forks.
5. **Idempotent install** — safe to re-run.
6. **Mobile-first UX** — compact TUI, short aliases, desktop via Termux:X11.

## Scope

```
Android (stock / unrooted)
  └── Termux
        └── proot → Kali NetHunter rootfs (nano / mini / full)
              └── GrokHunter overlay
                    ├── Grok Build CLI (coding agent)
                    ├── nh-x11 (desktop for editors / IDEs)
                    ├── grokhunter CLI + doctor
                    └── skills / profile
```

GrokHunter does **not** require Magisk, custom recovery, HID, or firmware modules.

## Why this stack for coding?

| Concern | Bare Termux | GrokHunter Rootless |
|---------|-------------|---------------------|
| Package ecosystem | Limited | Full Kali apt |
| Compilers / SDKs | Partial | Native apt packages |
| Grok agent | Needs extra setup | One flag (`--with-grok`) |
| Desktop editors | Limited | XFCE + Termux:X11 |
| Root required | No | **No** |

## Install flow

1. Detect Termux + architecture  
2. Pull latest NetHunter rootfs (`/current/`, live SHA256)  
3. Optional: desktop (XFCE) + browser  
4. Optional: native Grok Build CLI  
5. Optional: Termux:X11 + `nh-x11` + `/tmp` bind  
6. Write install metadata for doctor / uninstall  

## Uninstall policy

Removes wrappers, skills, shell markers. Keeps Grok binary, auth, and user projects.  
`--purge-grok` also removes Grok binary state (destructive).

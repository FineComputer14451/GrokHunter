# GrokHunter Rootless — Architecture

## Design goals

1. **Rootless first** — unrooted Android via Termux + proot only.
2. **Coding & building focus** — real Linux toolchains + Grok as on-device agent.
3. **Overlay, not fork** — never rebuild Kali rootfs or kernels.
4. **Grok binary** — shared installer (`scripts/ensure_grok.sh`): Termux-native first on Android, official xAI installer as fallback (override with `GROKHUNTER_GROK_INSTALLER`).
5. **Idempotent install** — safe to re-run; modules/engine cached under `~/.cache/grokhunter`.
6. **Mobile-first UX** — compact TUI, short aliases, desktop via Termux:X11.

## Scope

```
Android (stock / unrooted)
  └── Termux
        └── proot → Kali NetHunter rootfs (nano / mini / full)
              └── GrokHunter overlay
                    ├── Grok Build CLI (coding agent)
                    ├── nh-x11 (desktop for editors / IDEs)
                    ├── aider-grok (optional git-native pair)
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
2. Load `lib/*` (local clone or versioned cache; never leave engines in CWD)  
3. Load `termux-distro` engine (vendored file or `~/.cache/grokhunter/termux-distro.sh`)  
4. Pull latest NetHunter rootfs (`/current/`, live SHA256) + storage pre-check  
5. Optional: desktop + browser (session name saved for `nh-x11`; Chromium gets `--no-sandbox`)  
6. Optional: Grok Build via `scripts/ensure_grok.sh`  
7. Optional: Termux:X11 + `nh-x11` + `/tmp` bind  
8. Optional: Aider (`--with-aider` → `~/venv-aider` + `aider-grok`)  
9. Optional: V9 / 4.5 model pickers + shell completions  

## Historical precursor

An earlier **monolithic** script existed as *“Termux NetHunter Installer — Grok Build Powered Edition”* (`VERSION_NAME=Grok-Build-2026.2-x11`). It was a single-file enhancement of the jorexdeveloper `termux-nethunter` / `termux-distro` lineage with Grok Build + Termux:X11 hooks.

GrokHunter is the modular successor. Useful ideas carried forward from that precursor include:

- Storage free-space pre-check before rootfs download  
- Chromium desktop-entry `--no-sandbox` patch (required under proot)  
- Richer post-install quick-start messaging  

The old script’s X11 helper used `nethunter -r` (incorrect — `-r` is `--rename`); GrokHunter’s `nh-x11` is DE-aware and does not use `-r`.

## Supply chain notes

One-liner installs **download and execute** remote scripts (this repo’s modules, `termux-distro`, Grok installers). Mitigations:

| Control | How |
|---------|-----|
| Prefer clone | `git clone` + `bash install.sh` audits files first |
| Module version | `MODULES_VERSION` invalidates stale cache |
| Engine cache | `termux-distro.sh` under `~/.cache/grokhunter`, not CWD |
| Override URLs | `GROKHUNTER_DISTRO_ENGINE_URL`, `GROKHUNTER_GROK_*_URL` |
| Refresh | `GROKHUNTER_REFRESH=1 bash install.sh …` |
| Pin later | Vendor `termux-distro.sh` next to `install.sh` |

Remote `curl | bash` remains a residual risk shared with most CLI installers.

## Uninstall policy

Removes wrappers, skills, shell markers. Keeps Grok binary, auth, and user projects.  
`--purge-grok` also removes Grok binary state (destructive).

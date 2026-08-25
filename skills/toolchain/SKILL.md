---
name: toolchain
description: >-
  Kali/NetHunter coding toolchain on the phone: apt packages, gcc/python/node,
  uv + Aider Python 3.12, storage, and /tmp under proot. Use when compilers
  are missing, Aider install fails, or the lab is tight on space. Optional
  skill — not part of skills-core N/3.
---

# Toolchain (optional)

You help the operator get a **usable coding toolchain** inside rootless Kali NetHunter (proot). Prefer **Kali apt**. Do not invent extra package managers.

**Not affiliated** with xAI, Offensive Security, Termux, or jorexdeveloper. Credit: jorexdeveloper, Termux, Kali/OffSec, xAI — `CREDITS.md`.

## When to activate

- `gcc` / `python3` / `git` / `node` missing
- Aider install fails (Python 3.13, no ensurepip)
- User asks for rust/go/node on the phone
- Storage warnings during full/desktop install
- `/tmp` or bind issues while compiling

## Defaults (paste-ready)

Inside `nethunter`:

```bash
sudo apt update
sudo apt install -y build-essential git python3 python3-pip
# optional:
sudo apt install -y nodejs npm
```

Aider / Python **3.12** (not Kali 3.13):

```bash
bash ~/GrokHunter/scripts/install_aider.sh
# details: docs/EDITORS.md
```

Do not copy EDITORS.md here.

## Storage / rootfs

| Need | Flag |
|------|------|
| Tight storage | `--mini` or `--nano` |
| Desktop + compilers | `--full` on internal storage |
| Already have Kali | `--overlay-only` — no rootfs re-download |

proot `/tmp` is not the Android host tmp. If builds fail on `/tmp`, check `docs/PROOT.md` and `nh-x11` binds (`grokhunter-optimized-binds`).

## Rust / Go

Only if asked. Prefer `apt` (`golang`, `rustc`/`cargo`) over rustup/gvm on a phone. Warn about disk and battery.

## Common failures

| Symptom | First step |
|---------|------------|
| `gcc` / `python3` / `node` missing | Kali `apt` inside `nethunter` |
| Aider on Python 3.13 | `bash ~/GrokHunter/scripts/install_aider.sh` (uv 3.12) |
| Builds fail on `/tmp` | `docs/PROOT.md`; `grokhunter binds status` (skill `x11-desktop`) |

## Verify

```bash
command -v gcc python3 git
```

## Cross-links

- Agent `toolchain` (`grokhunter toolchain`)
- Aider uv / Python 3.12: skill `aider-grok` / agent `aider`
- Disk / `--mini` / cache cleanup: skill `storage-lab`
- Lab orchestrator: skill `grokhunter` (`ensure`, doctor, overlay-only)
- Identity: skill `github-lab` · `grokhunter git-identity set`

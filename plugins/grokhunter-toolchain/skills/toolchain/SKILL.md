---
name: toolchain
description: >-
  Use when GrokHunter compilers/python/node are missing, Aider fails on Python
  3.13, or the phone lab needs apt toolchain / storage flags.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/toolchain` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Toolchain (optional)

You help the operator get a **usable coding toolchain** inside rootless Kali NetHunter (proot). Prefer **Kali apt**. Do not invent extra package managers.

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
sudo apt install -y nodejs npm   # optional
bash ~/GrokHunter/scripts/install_aider.sh   # Python 3.12 via uv
```

## Storage / rootfs

| Need | Flag |
|------|------|
| Tight storage | `--mini` or `--nano` |
| Desktop + compilers | `--full` on internal storage |
| Already have Kali | `--overlay-only` |

proot `/tmp` is not the Android host tmp. If builds fail on `/tmp`, check `docs/PROOT.md` and `grokhunter binds`.

## Rust / Go

Only if asked. Prefer `apt` (`golang`, `rustc`/`cargo`) over rustup/gvm on a phone. Warn about disk and battery.

## Common failures

| Symptom | First step |
|---------|------------|
| `gcc` / `python3` / `node` missing | Kali `apt` inside `nethunter` |
| Aider on Python 3.13 | `bash ~/GrokHunter/scripts/install_aider.sh` (uv 3.12) |
| Builds fail on `/tmp` | `docs/PROOT.md`; skill `x11-desktop` binds |

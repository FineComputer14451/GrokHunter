# Changelog

## [1.0.0] — 2026-08-05 — GrokHunter Rootless

First stable release of **GrokHunter Rootless** — optimized for **coding and building** on unrooted Android.

### Highlights

- **Rootless-first** — Termux + proot only, no root required
- **Coding & building focus** — real Linux toolchains + Grok as on-device agent
- **Modular installer** — thin `install.sh` + `lib/` modules
- **Hardened one-liner** — individual module downloads + persistent cache
- **Grok Build native** — `--with-grok`
- **Termux:X11** — low-latency desktop + `nh-x11` via `--with-x11`
- **CLI** — `grokhunter` (status, doctor, ensure, install, plan, headless)
- **Dynamic rootfs** — latest Kali NetHunter from `/current/` with live SHA256

### Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh) \
  --full --de xfce --browser chromium --with-grok --with-x11
```

### Notes

- No root required
- Aimed at coding, building, and AI-assisted development — not penetration testing
- Termux:X11 APK still required from official nightly releases
- Not affiliated with xAI or Offensive Security

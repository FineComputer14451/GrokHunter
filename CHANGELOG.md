# Changelog

## [1.0.0] — 2026-08-05 — GrokHunter Rootless

First stable release of **GrokHunter Rootless**.

### Highlights

- **Rootless-first identity** — designed exclusively for unrooted Android (Termux + proot)
- **Modular installer** — thin `install.sh` + `lib/` modules
- **Hardened one-liner** — individual module downloads, persistent cache (`~/.cache/grokhunter`), tarball fallback
- **Grok Build native** — optional install via `--with-grok`
- **Termux:X11** — low-latency desktop + `nh-x11` helper via `--with-x11`
- **CLI** — `grokhunter` (status, doctor, ensure, install, plan, headless)
- **Dynamic rootfs** — always pulls latest Kali NetHunter from `/current/` with live SHA256

### Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh) \
  --full --de xfce --browser chromium --with-grok --with-x11
```

### Notes

- No root required
- Termux:X11 APK must still be installed from the official nightly releases
- Not affiliated with xAI or Offensive Security

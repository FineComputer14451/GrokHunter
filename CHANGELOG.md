# Changelog

## [1.0.1] — 2026-08-05 — Harden / fix patch

Code-review follow-ups for supply-chain hygiene, install reliability, and DE-aware desktop.

### Fixes

- **Website deploy** — GitHub Actions workflow deploys `website/` to GitHub Pages

- **termux-distro engine** — download to `~/.cache/grokhunter/termux-distro.sh` (never pollute CWD); basic HTML/empty validation; `GROKHUNTER_DISTRO_ENGINE_URL` override
- **Grok install path unified** — `scripts/ensure_grok.sh` shared by `install --with-grok` and `grokhunter ensure` (`auto|official|termux-native`, primary + fallback)
- **nh-x11 DE-aware** — uses `NH_X11_SESSION`, `~/.config/grokhunter/x11-session`, or auto-detect (not XFCE-only)
- **Doctor** — resolves CLI from `GROKHUNTER_HOME/bin` when not on PATH; reports session + cache
- **`bin/grokhunter`** — executable bit; `PATH` includes repo `bin/`
- **Uninstall** — clears module cache, restores launcher backups, removes `nh-x11`
- **Chromium** — explicit warning that `--no-sandbox` is required under proot

### Versioning

- `VERSION` / profile / `VERSION_NAME` aligned to **1.0.1**
- `MODULES_VERSION` → `2026.2.2` (forces one-liner cache refresh)

---

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

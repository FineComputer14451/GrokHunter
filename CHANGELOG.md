# Changelog

## [1.0.2] — 2026-08-06 — Complete Aider integration

The Aider path was previously surface-only (flags + docs). This release implements the missing installer logic and the promised helper.

### Aider

- **`lib/grok.sh`** — real implementation (was `PLACEHOLDER`)
  - `install_aider()` — creates `~/venv-aider` inside NetHunter, installs `aider-chat`, drops helpers
  - `install_grok_build()` — wraps shared `scripts/ensure_grok.sh`
  - `install_v9_models()` / `install_shell_completions()` — call the existing scripts
- **`bin/aider-grok`** — first-class wrapper
  - Sources `~/.grok/secrets.env`
  - Sets `OPENAI_API_BASE=https://api.x.ai/v1`
  - Defaults to **`grok-4.5`** (`AIDER_MODEL` overridable)
  - Auto-activates `~/venv-aider` when present
- **Docs / skill** — aligned to `grok-4.5` and the real `aider-grok` command

### From Grok-Build-2026.2-x11 precursor

Useful bits extracted from the earlier monolithic “Grok Build Powered” installer:

- **Storage pre-check** before rootfs download (warn + optional abort)
- **Chromium `--no-sandbox`** patch on the `.desktop` Exec line (required under proot)
- **Richer post-complete** quick-start lines (incl. `aider-grok`)
- **Expanded offline SHA fallbacks** (arm64/armhf × nano/mini/full)
- **ARCHITECTURE.md** — historical precursor section

### Versioning

- `VERSION` → **1.0.2**
- `MODULES_VERSION` → `2026.2.10` (install skills + site refresh)

### Code quality (review blockers)

- **`termux-distro` engine** — resolve via vendored → `~/.cache/grokhunter/termux-distro.sh` → download into cache (never CWD); `GROKHUNTER_DISTRO_ENGINE_URL` override; HTML/empty validation
- **Optional features** — `FEATURE_*=yes|no|auto` + single `maybe_install` / `run_optional_features` (replaces copy-pasted SKIP/INSTALL blocks)
- **`grokhunter models`** — real `install|status|force` (dispatches to `scripts/install_v9_grok_models.sh`)
- **`bin/grokhunter`** — shared `_grok_launcher`; VERSION fallback 1.0.2; doctor resolves non-executable clone bins
- **File-based helpers** — canonical `bin/nh-x11` + `bin/aider-grok` installed via copy (no heredoc snapshots)
- **`--overlay-only`** — install optional overlays without rootfs / termux-distro
- **Atomic proot bind patch** — pure bash rewrite of launcher binds (no multi-line `sed -i`)
- **`install_cli_bins`** — copies `grokhunter` / doctor / launchers into `~/.local/bin` (and Termux `PREFIX/bin` when present)
- **Skills** — `grokhunter` / `pair-programming` / `aider-grok` / `nethunter-recon` updated for overlay-only, models CLI, file-based helpers, SpaceXAI smoke, and Grok 4.5 defaults
- **`grokhunter ai-smoke` / `smoke`** — wired to `scripts/spacexai_smoke.sh`; profile alias `ghai`; completions include `--overlay-only` and completions flags
- **`scripts/ci-unit.sh`** — local/CI unit checks (bash -n, parse_cli, maybe_install, bind patch, ai-smoke missing-key) without requiring workflow-token updates
- **`install_skills`** — copies `skills/*` into `~/.grok/skills` during overlay/complete (matches uninstall)
- **Website** — badge v1.0.2; CLI/flags for models, ai-smoke, overlay-only
- **status / doctor** — models, skills count, PATH wrappers; doctor warns when skills only in repo
- **FAQ** — overlay-only + models / ai-smoke / ci-unit

---

## [1.0.1] — 2026-08-05 — Harden / fix patch

Code-review follow-ups for supply-chain hygiene, install reliability, and DE-aware desktop.

### SpaceXAI alignment

- **Aider default model** — `aider-grok` and docs pin **`grok-4.5`** (was `grok-4`)
- **`scripts/spacexai_smoke.sh`** — Responses API smoke test (`XAI_API_KEY` + `api.x.ai`)
- **`templates/spacexai_hello.py`** — minimal OpenAI-compatible client snippet
- **Docs / skills** — SpaceXAI anchors (`XAI_API_KEY`, base URL, console, docs.x.ai)
- **`grokhunter ai-smoke`** — CLI entry for SpaceXAI smoke (`smoke` alias)
- **`grokhunter models`** — implemented `install|status` (was documented but missing)
- **`ghai` alias** — `grokhunter ai-smoke` (profile + docs)

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

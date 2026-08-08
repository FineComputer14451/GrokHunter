# Changelog

## Unreleased

### Roles (Grok Build 1.0.0 capability defaults)

- **`roles/*.toml`** — `architect`, `builder`, `reliability`, `mapper`, `code-review`, `surgical`, `x11-desktop`
- **`lib/roles-discover.sh`** + **`install_roles`** → `~/.grok/roles/`
- Doctor + uninstall scan-based; pairs with agents + personas

### Personas (Grok Build 1.0.0 subagent overlays)

- **`personas/*.toml`** — `mobile`, `concise`, `shell-first`, `pair`, `security-lab`, `design-card`, `build-card`, `harden-card`
- **`lib/personas-discover.sh`** + **`install_personas`** → `~/.grok/personas/` (via `grokhunter skills install`)
- Doctor + uninstall scan-based; user-only personas preserved
- Docs: `personas/README.md`, `docs/CODING-TEAM.md`

### Agents expanded (Coding Team + lab specialists)

- **Core deepened** for Grok Build 1.0.0: `benjamin`, `lucas`, `harper`, `coding-team` (tools posture, required cards, handoff tables)
- **New agents:** `scout` (read-only map), `review` (read-only review), `fix` (surgical patches), `desktop` (Termux:X11 / nh-x11)
- **Docs:** `docs/CODING-TEAM.md`, `agents/README.md` roster + CLI examples
- Install: `grokhunter skills install` → `~/.grok/agents/`

### Grok Build 1.0.0 compatibility (GrokHunter 1.0.3)

- **Min version** raised to **1.0.0** (`GROKHUNTER_MIN_GROK`, doctor, ensure)
- **`config/grok-build.nethunter.toml`** — stable channel, `default`/`web_search`/`fork_secondary_model` = `grok-4.5`, subagents on, 1.0.0 UI keys
- **`scripts/install_grok_profile.sh`** — merges NetHunter profile into `~/.grok/config.toml` without wiping `[model.*]`
- **`scripts/ensure_grok.sh`** — upgrades when &lt; 1.0.0, prefers `grok update`, applies profile after install
- **`grokhunter plan`** — uses `grok --agent plan --permission-mode plan -p` (1.0.0 built-in plan agent)
- **Doctor** — channel/profile/models checks for 1.0.0
- **Docs:** `docs/GROK-BUILD-1.0.md`

### Aider install fix (Python 3.13 / Kali)

- **Root cause:** `aider-chat` requires Python `>=3.10,<3.13`; Kali ships 3.13, and plain `python3 -m venv` often lacks `ensurepip`. Old installer silently failed.
- **`scripts/install_aider.sh`** — shared installer: **uv tool install + managed Python 3.12** (primary), then official `aider.chat/install.sh`, then `aider-install` package, then classic venv only on 3.10–3.12.
- **`lib/grok.sh` `install_aider()`** — runs the shared script inside NetHunter (copies into rootfs `/tmp` so host binds are not required); host fallback; always installs `aider-grok` helper.
- **`bin/aider-grok`** — discovers uv-tool and venv installs under `~/.local/bin` and `/home/kali`.
- Docs/skill/troubleshooting updated. Repair: `GROKHUNTER_FORCE_AIDER=1 bash scripts/install_aider.sh`.

### Skills discovery

- **`lib/skills-discover.sh`** — single source for skill list + core set (`GH_CORE_SKILLS`)
- **status / doctor / uninstall / install** all use the same discover helpers
- Uninstall no longer guesses historical skill names when `skills/` is missing
- `cmd_skills_status` drops dead `missing:` branch; ci-unit asserts full scan + user-only preserve

### Coding Team agents (runtime multi-agent)

- **`agents/`** — Grok Build agent defs: `benjamin` (plan), `lucas`, `harper`, `coding-team`
- **`lib/agents-discover.sh`** + **`install_agents`** → `~/.grok/agents/` (loaded by Grok at runtime)
- Doctor optional Agents section; uninstall removes product agent files only
- Docs: `docs/CODING-TEAM.md`

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
- **`grokhunter skills`** — status|install for `~/.grok/skills`; alias `ghk`
- **install-completions** — also refreshes CLI wrappers + skills
- **Skills expanded** — grokhunter / pair-programming / aider-grok / nethunter-recon cover full CLI (skills, ai-smoke, status fields), decision trees, doctor matrix, SpaceXAI anchors

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

# Changelog

## Unreleased

### Lab specialists

- Optional skills **`toolchain`** (apt / Aider Python 3.12 / storage) and **`github-lab`** (`git-identity` playbook)
- Agents **`overlay`**, **`ship`**, **`docs`** plus roles/personas and Coding Team routing
- `grokhunter overlay|ship|docs` launchers + completions
- `grokhunter` skill refreshed for 1.0.9 (identity, doctor, PATH)
- Wave 2: skills **`grok-models`**, **`ci-lab`**, **`secrets-lab`**; agents **`models`**, **`ci`**, **`aider`** (`grokhunter modeler` so it does not collide with `grokhunter models`)
- Wave 3: skills **`session-lab`**, **`host-lab`**, **`mcp-lab`**; agents **`session`**, **`host`**, **`mcp`** (`grokhunter mcp` launches the agent; CLI is `grok mcp`)
- Wave 4: skills **`plugin-lab`**, **`flow-lab`**, **`storage-lab`**; agents **`plugin`**, **`flow`**, **`storage`** (`grokhunter plugin` launches the agent; CLI is `grok plugin`)
- Wave 5: skills **`editor-lab`**, **`hooks-lab`**, **`shell-lab`**; agents **`editor`**, **`hook`**, **`shell`**
- Overlay cache **2026.2.18**

## [1.0.9] — 2026-08-22 — Doctor truth + GitHub identity

Doctor stops treating a working lab as offline or incomplete. Git commits attach to GitHub instead of `invalid-email-address`. Overlay cache **2026.2.13**.

### Status / doctor follow-ups

- `grokhunter status` treats current **and** legacy V9 config markers as `models=yes`
- Clone-only installer cache is informational (`ok`), not a yellow warning

### Doctor environment

- Missing `/etc/os-release` is a warning, not a hard fail (Termux host / incomplete rootfs)
- OS probe also reads `/usr/lib/os-release` and `$PREFIX/etc/os-release`

### Doctor network probe

- HTTPS check no longer uses `curl -f` against `https://x.ai` (Cloudflare 403 looked “offline” on a working lab)
- Probe `https://api.x.ai/v1/models` first; any HTTP 1xx–5xx counts as reachable (401 unauthenticated is OK)

### GitHub identity

- History rewrite: `root <root@localhost.localdomain>` commits and tags now attribute to **Fine_Computer_4451** (`119702188+FineComputer14451@users.noreply.github.com`)
- **`grokhunter git-identity`** — `show` / `set` (from `gh api user`, `--name/--email`, or `GROKHUNTER_GIT_NAME` / `GROKHUNTER_GIT_EMAIL`)
- `git-identity set` also resolves from `GH_TOKEN` / `GITHUB_TOKEN` or the GitHub `origin` owner (no `gh` CLI required)
- `grokhunter setup` auto-sets a placeholder identity when one of those sources works
- Doctor warns on placeholder identity (`root`, `@localhost`, empty) so GitHub stops showing `invalid-email-address`
- `.mailmap` maps leftover `root@localhost` locally

### Overlay cache

- `MODULES_VERSION` / banner → `2026.2.13` (one-liner overlay refresh)

## [1.0.8] — 2026-08-22 — Overlay extract, Grok 4.6, install hardening

One-liner now installs the full overlay. Default model is **grok-4.6**; min Grok Build is **1.0.5**. Install/uninstall edges from the 1.0.7 review are closed.

### Install hardening

- Pin Termux-native Grok installer to a GitHub commit (`TERMUX_NATIVE_PIN`), not floating `main`
- Proot extra binds skip missing host paths (`/sdcard`, `storage/downloads`) so `nethunter` still starts before `termux-setup-storage`
- Overlay dest requires a complete tree or a git clone — a stray `install.sh` in `~/GrokHunter` no longer claims the overlay
- Storage pre-check uses POSIX `df -Pk` and integer GiB only (skip if unreadable; no `df -BG` / decimal `-lt`)

### Grok 4.6 + Grok Build 1.0.5

- Default catalog model **`grok-4.6`** (profile, Aider, SpaceXAI smoke, V9 pickers)
- Min Grok Build **`1.0.5`** (`GROKHUNTER_MIN_GROK`, doctor, ensure)
- V9 pickers add 4p6 aliases; former 4.5 picker IDs remain as compat wrappers → `grok-4.6`
- Docs: `docs/GROK-46.md` ( `docs/GROK-45.md` points here)

### One-liner overlay extract

- Advertised `bash <(curl …/install.sh)` now extracts the **full** overlay (`bin/`, `scripts/`, `skills/`, …) to `~/GrokHunter` (or `~/.cache/grokhunter/src` if that directory is already occupied)
- Process-substitution `/dev/fd` is never used as `SCRIPT_DIR` / `GROKHUNTER_HOME`
- Git clones are never overwritten; local `lib/` always wins (including `GROKHUNTER_REFRESH=1`)
- Tarball is the only network source for modules+overlay (no 4-file lib fetch)
- `MODULES_VERSION` / banner → `2026.2.12`

### `--full --de` / `--browser`

- Explicit `--de` / `--browser` run even on `--full` (Chromium + proot `--no-sandbox` patch)
- `--full` alone still skips DE/browser (rootfs already ships a desktop)

### Uninstall / profile

- `uninstall.sh` removes shortcut bins (`ghsu`, `ght`, `ghd`, `ghs`, `ghp`, `ghm`, `ghk`, `ghai`, `ghn`)
- `strip_shell` uses awk (no python3); unclosed markers leave the rc file unchanged; later uninstall steps always run
- Profile no longer aliases `gh` (GitHub CLI stays unshadowed)

### Engine pin vs cache

- `GROKHUNTER_DISTRO_ENGINE_URL` is stamped in `~/.cache/grokhunter/termux-distro.url`; a new pin fetches without `GROKHUNTER_REFRESH=1`
- Unsetting a pin no longer reuses a foreign stamped cache (legacy unstamped cache still counts as the default engine)
- `GROKHUNTER_REFRESH=1` re-extracts a non-git overlay; incomplete non-git trees self-repair; git clones still never receive a tarball

### Docs

- Completions do **not** edit `.zshrc`/`.bashrc`; FAQ/update path uses `--overlay-only`

## [1.0.7] — 2026-08-08 — Credits, Kali menu, mobile site

Desktop polish, full upstream attribution, product-site mobile layout, and greener CI.

### Kali menu integration

- **Applications → GrokHunter** submenu (XFCE / freedesktop): Grok Build, Coding Team, Scout, Aider, Doctor, Setup, Credits
- `config/desktop/*.desktop` + `grokhunter.menu` / `grokhunter.directory`
- `scripts/install_kali_menu.sh` · `grokhunter menu [install|remove]`
- Wired into `skills install` / X11 setup; doctor checks menu presence

### Credits — full upstream recognition

- **[CREDITS.md](CREDITS.md)** expanded for four pillars:
  - **jorexdeveloper** — termux-nethunter / termux-distro
  - **Termux team** — host + Termux:X11
  - **Kali / Offensive Security** — NetHunter rootfs
  - **xAI** — Grok Build + models
- `grokhunter credits`, doctor Credits section, post-install, MOTD, Kali menu, website, README, FAQ, ARCHITECTURE, agents/skills

### Product site

- **Mobile layout** — compact sticky header, hamburger until 1100px, scrollable tables, full-width CTAs, safe-area insets
- No horizontal overflow on narrow phones

### CI

- Smoke: capture help/credits before `grep` (avoid pipefail + SIGPIPE false fails)
- Smoke `find` expression aligned with `ci-unit.sh`

## [1.0.6] — 2026-08-08 — Doctor & desktop polish

### CLI shortcuts as real binaries

- **`install_cli_shortcuts`** drops `ghsu`, `ght`, `ghd`, … into `~/.local/bin` (not shell aliases only)
- Works in non-interactive shells / Termux where bash aliases are disabled
- Does **not** install `gh` (avoids clobbering GitHub CLI)

### X11 session preference auto-heal

- **`ensure_x11_session`** probes DE binaries and writes `~/.config/grokhunter/x11-session` when missing
- Doctor auto-creates it; `setup` / `setup_termux_x11` also ensure it (default often `startxfce4`)

### Doctor: nethunter PATH

- Inside Kali proot, launcher on Termux host is **OK** (not required on guest PATH)
- Clearer messaging when launcher is missing vs host-only

## [1.0.5] — 2026-08-08 — Lab ops CLI (setup · team · agents)

### CLI features

- **`grokhunter setup`** (`sync` / `boot`) — one-shot: ensure → skills install → optional models/Aider → doctor
  - Flags: `--force-grok`, `--with-models`, `--with-aider`, `--no-doctor`
- **Agent launchers:** `team` / `coding-team`, `scout`, `benjamin`, `lucas`, `harper`, `review`, `fix`, `desktop`
  - Interactive TUI when no prompt; headless `-p` when a prompt is given
- **`grokhunter agents status`** — installed vs repo agent list
- **Richer `status` line:** `agents=N | personas=N | roles=N`
- Completions + profile aliases: **`ghsu`** (setup), **`ght`** (team)

## [1.0.4] — 2026-08-08 — Full product site + CI unit

Polish release after the 1.0.3 lab stack.

### Site

- **Full product landing page** — stats, stack layers, Coding Team agents, personas/roles, overlay install, CLI, upgrade, FAQ
- GitHub Pages live: https://finecomputer14451.github.io/GrokHunter/
- Terminal demo covers Grok 1.0.0, Aider uv, skills install
- README badges (release / smoke / site) + repo homepage metadata

### CI

- Smoke workflow runs full **`scripts/ci-unit.sh`** after bash -n (skills/agents/personas/roles install, engine guards)

## [1.0.3] — 2026-08-08 — Grok Build 1.0.0 lab stack

Full alignment with **Grok Build 1.0.0** (stable), plus Aider reliability, expanded Coding Team, personas, and roles.

### Grok Build 1.0.0 compatibility

- **Min version** raised to **1.0.0** (`GROKHUNTER_MIN_GROK`, doctor, ensure)
- **`config/grok-build.nethunter.toml`** — stable channel, `default`/`web_search`/`fork_secondary_model` = `grok-4.5`, subagents on, 1.0.0 UI keys
- **`scripts/install_grok_profile.sh`** — merges NetHunter profile into `~/.grok/config.toml` without wiping `[model.*]`
- **`scripts/ensure_grok.sh`** — upgrades when < 1.0.0, prefers `grok update`, applies profile after install
- **`grokhunter plan`** — uses `grok --agent plan --permission-mode plan -p` (1.0.0 built-in plan agent)
- **Doctor** — channel/profile/models checks for 1.0.0
- **Docs:** `docs/GROK-BUILD-1.0.md`

### Aider install fix (Python 3.13 / Kali)

- **Root cause:** `aider-chat` requires Python `>=3.10,<3.13`; Kali ships 3.13; plain venv often lacks `ensurepip`
- **`scripts/install_aider.sh`** — **uv + managed Python 3.12** primary path; official installer / venv fallbacks
- **`lib/grok.sh` `install_aider()`** — runs shared script in NetHunter (rootfs `/tmp` copy); host fallback; `aider-grok` helper
- Repair: `GROKHUNTER_FORCE_AIDER=1 bash scripts/install_aider.sh`

### Agents expanded

- Core deepened: `benjamin`, `lucas`, `harper`, `coding-team`
- New: `scout`, `review`, `fix`, `desktop`
- Install: `grokhunter skills install` → `~/.grok/agents/`

### Personas

- `mobile`, `concise`, `shell-first`, `pair`, `security-lab`, `design-card`, `build-card`, `harden-card`
- → `~/.grok/personas/` via skills install

### Roles

- `architect`, `builder`, `reliability`, `mapper`, `code-review`, `surgical`, `x11-desktop`
- → `~/.grok/roles/` via skills install

### Also included

- Skills discovery single-source (`lib/skills-discover.sh`) from earlier unreleased work
- Coding Team agent runtime wiring from earlier unreleased work

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

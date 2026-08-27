# GrokHunter first-run installer TUI

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** On Termux, bare `install.sh` (TTY, no size/feature flags) opens a numbered checklist wizard, then `exec`s the existing installer with explicit flags. Default is a coding-only nano lab.

**Architecture:** New `lib/install-tui.sh` is sourced after `lib/cli.sh`. It only builds argv and talks to the user. Confirm `exec`s `${OVERLAY_ROOT}/install.sh` with those flags so `NON_INTERACTIVE=1` and today’s termux-distro hooks run unchanged. No live download UI. No overlay-only wizard. No `grokhunter tui` changes.

**Tech Stack:** Bash 4.3+, Termux `read`/TTY, existing `install.sh` + `lib/cli.sh` + `lib/actions.sh`, `scripts/ci-unit.sh` (no `expect`, no live TTY, no new packages).

**Spec (write in Task 1):** `docs/superpowers/specs/2026-08-27-grokhunter-install-tui-design.md`

## Global Constraints

- First-run **Termux host** only (`install.sh` already dies outside Termux).
- Default argv: `--nano --no-de --with-grok --with-completions`.
- Desktop toggle **promotes** to `--full --de xfce --browser chromium --with-x11` and keeps Grok/completions/extras. Desktop off restores coding-only size/DE/X11/browser; extras stay.
- v1 DE is **Xfce only**; v1 browser is **Chromium only**. No Mini row. Flags still support `--mini` and other DEs.
- Numbered `read` skin only. No whiptail, fzf, gum, dialog, curses, python3, apt/pkg/pip.
- Flags skip the wizard (`NON_INTERACTIVE=1`). `--yes` applies the coding-only default without a TUI.
- Non-TTY + no flags: **die** with paste-ready examples (do not run `choose`/`ask`).
- One-liner: overlay is already extracted before `parse_cli`. `exec` `${OVERLAY_ROOT}/install.sh`, never `/dev/fd`.
- Loop guard: `GROKHUNTER_INSTALL_TUI_RAN=1` on exec. `GROKHUNTER_INSTALL_TUI=0` restores old `choose`/`ask`.
- Never prompt for an API key. Never print tokens. No `set -x`. No `secrets.env`.
- Do not rewrite termux-distro. Do not touch `bin/grokhunter-tui` / dashboard spec.
- `bin/grokhunter` stays under **1000** lines; `usage()` has **no backticks**. v1 adds **no** new grokhunter subcommand.
- Bump overlay cache `MODULES_VERSION` / `VERSION_NAME` to **2026.8.27** so one-liner cache misses pick up `lib/install-tui.sh`.
- Credits unchanged (jorexdeveloper, Termux, Kali/OffSec, xAI). Not affiliated.

## Locked decisions

| Topic | Decision |
|-------|----------|
| Job | First-run wizard on Termux when TTY and no size/feature flags |
| Default | Coding-only nano, no DE, Grok + completions on |
| Desktop on | Promote to full + Xfce + Chromium + X11; keep Grok/completions/Aider/V9 |
| Desktop off | Restore nano `--no-de`, drop X11/browser; extras unchanged |
| Skin | Numbered `read`. Quit is a menu item |
| Confirm | Print exact argv + disk hint (nano ~2G, full ~6G+), then exec |
| `--yes` | Non-interactive coding-only default |
| Overlay-only | Unchanged (still requires `--with-*`, no wizard) |
| Lab dashboard | Out of scope |

Rejected: polish-only `choose`/`ask` (B); live progress TUI around rootfs fetch (C); overlay-only wizard; dual whiptail skin.

## Home screen (copy)

```
GrokHunter install

  Lab:          coding-only (nano, no desktop)
  Grok:         yes
  Completions:  yes
  Aider:        no
  V9 pickers:   no

  1) Install
  2) Switch to desktop lab (full + Xfce + X11)
  3) Toggle Grok
  4) Toggle completions
  5) Toggle Aider
  6) Toggle V9 pickers
  7) Show command
  8) Quit
```

When lab is desktop, line 2 is `Switch to coding-only (nano, no desktop)` and the Lab line reads `desktop (full, Xfce, Chromium, X11)`.

`7` prints argv, waits for Enter, returns Home. `8` exits 0. `1` goes to confirm.

Confirm copy (no key prompt):

```
About to run:
  bash <OVERLAY_ROOT>/install.sh --nano --no-de --with-grok --with-completions

Downloads a Kali NetHunter rootfs. nano needs ~2G free, full ~6G+.
This can take a long time. Keep Termux open (wake-lock is already held).

  1) Confirm
  2) Back
  3) Quit
```

If `_gh_df_avail_gb` is below the threshold, add one warn line; still allow Confirm (same as today’s non-interactive continue).

## Argv builder (test table)

State: `INSTALL_TUI_PRESET=coding|desktop`, `INSTALL_TUI_GROK`, `INSTALL_TUI_COMPLETIONS`, `INSTALL_TUI_AIDER`, `INSTALL_TUI_V9` each `yes|no`.

`install_tui_argv` prints one line to stdout (flags only).

| preset | grok | comp | aider | v9 | argv |
|--------|------|------|-------|----|------|
| coding | yes | yes | no | no | `--nano --no-de --with-grok --with-completions` |
| coding | no | no | no | no | `--nano --no-de --no-grok --no-completions` |
| coding | yes | yes | yes | yes | `--nano --no-de --with-grok --with-completions --with-aider --with-v9-models` |
| desktop | yes | yes | no | no | `--full --de xfce --browser chromium --with-x11 --with-grok --with-completions` |
| desktop | no | yes | no | no | `--full --de xfce --browser chromium --with-x11 --no-grok --with-completions` |

Always emit explicit `--with-grok`/`--no-grok` and `--with-completions`/`--no-completions`. Coding never emits `--de` / `--browser` / `--with-x11`. Desktop always emits `--with-x11 --de xfce --browser chromium`. Aider/V9 only when `yes`.

## File map

| File | Role |
|------|------|
| `docs/superpowers/specs/2026-08-27-grokhunter-install-tui-design.md` | Locked spec (this plan’s decisions) |
| `lib/install-tui.sh` | Wizard: state, argv, should_run, home, confirm, dump, main |
| `install.sh` | `MODULES+=(install-tui.sh)`, bump `MODULES_VERSION`/`VERSION_NAME` to 2026.8.27, source module, gate + exec |
| `lib/cli.sh` | `--yes` in help + `parse_cli` |
| `scripts/ci-unit.sh` | argv table, `--yes`, should_run, non-TTY copy, `bash -n` picks up new lib via find |
| `docs/INSTALL.md` | Bare install = wizard; `--yes`; flags skip |
| `docs/FAQ.md` | One FAQ: wizard vs flags vs overlay-only vs `grokhunter tui` |
| `CHANGELOG.md` | Unreleased Installer TUI |
| `README.md` | One-liner note: no flags → wizard |
| `skills/grokhunter/SKILL.md` | Decision-tree row |
| `agents/REFERENCES.md` / `skills/REFERENCES.md` | Overlay cache 2026.8.27 |
| `website/index.html` | One-liner blurb only if it currently says flags are required |

Do **not** modify: `bin/grokhunter` (unless usage is already over a line that must mention `--yes` — skip), dashboard spec/plan, `lib/actions.sh` `choose`/`ask` paths (they stay as `GROKHUNTER_INSTALL_TUI=0` fallback).

Locked function names in `lib/install-tui.sh`:

- `install_tui_defaults` `install_tui_argv` `install_tui_should_run`
- `install_tui_help` `install_tui_dump` `install_tui_show_cmd`
- `install_tui_toggle` `install_tui_set_preset`
- `install_tui_home` `install_tui_confirm` `install_tui_main`

## Gate in `install.sh` (after `parse_cli`, before overlay-only / engine)

```bash
source "${LIB_DIR}/install-tui.sh" || die "failed to source install-tui.sh"

if [[ ${NON_INTERACTIVE} -eq 0 ]]; then
  if [[ ! -t 0 || ! -t 1 ]]; then
    die_with_help "Not a TTY. Pass flags or run in a Termux terminal." \
      "Coding-only:  bash install.sh --nano --no-de --with-grok --with-completions" \
      "Desktop:      bash install.sh --full --de xfce --browser chromium --with-grok --with-x11 --with-completions" \
      "Default:      bash install.sh --yes"
  fi
  if [[ "${GROKHUNTER_INSTALL_TUI:-1}" != "0" && "${GROKHUNTER_INSTALL_TUI_RAN:-0}" != "1" ]]; then
    install_tui_main
    # main execs on confirm or exits 0 on quit — not reached
  fi
fi
```

`--yes` in `parse_cli` sets `NON_INTERACTIVE=1`, `SELECTED_INSTALLATION=nano`, `SKIP_DE=1`, grok/completions yes, x11/aider/v9 no. Help text one line: `--yes  Coding-only default (nano, no DE, Grok + completions); no wizard`.

## Tests (add to `scripts/ci-unit.sh`)

No live TTY. Source `lib/cli.sh` + `lib/install-tui.sh`.

1. **argv table** — five rows above; `[[ "$(install_tui_argv)" == "..." ]]`.
2. **`--yes`** — `parse_cli --yes`; assert nano, SKIP_DE, FEATURE_GROK=yes, FEATURE_COMPLETIONS=yes, FEATURE_X11=no, NON_INTERACTIVE=1.
3. **should_run** — NON_INTERACTIVE=1 → false; OVERLAY_ONLY=1 → false; GROKHUNTER_INSTALL_TUI=0 → false; GROKHUNTER_INSTALL_TUI_RAN=1 → false.
4. **preset toggle** — coding + `install_tui_set_preset desktop` → argv contains `--full --de xfce --with-x11`; then `coding` → `--nano --no-de` and no `--with-x11`. Aider stays if it was yes.
5. **dump** — `install_tui_dump` prints argv only (no `XAI`, no `secrets`).
6. **help grep** — `lib/cli.sh` help contains `--yes`; `install.sh` contains `install-tui.sh` and `2026.8.27`.
7. **secrets** — `grep -R XAI_API_KEY lib/install-tui.sh` must be empty.

`install_tui_should_run` does not need a real TTY in tests: it checks the other gates; TTY is enforced by the `install.sh` wrapper (`[[ -t 0 ]]`), not inside the function (so tests stay deterministic).

## Tasks

### Task 1: Spec file

**Files:** Create `docs/superpowers/specs/2026-08-27-grokhunter-install-tui-design.md`

- [ ] Copy locked decisions, home copy, argv table, non-goals, credits from this plan. Status: Approved (user signed off in this session).
- [ ] Commit: `docs: spec for Termux first-run installer TUI`

### Task 2: Argv + `--yes` (TDD)

**Files:** Create `lib/install-tui.sh` (functions only, no UI loop yet). Modify `lib/cli.sh` (`--yes`). Modify `scripts/ci-unit.sh` (tests 1–4).

- [ ] Write ci-unit blocks for argv table, `--yes`, should_run, preset toggle. Run: **fail** (missing functions).
- [ ] Implement `install_tui_defaults`, `install_tui_argv`, `install_tui_should_run`, `install_tui_set_preset`, `install_tui_toggle`. Implement `parse_cli --yes`.
- [ ] Run `bash scripts/ci-unit.sh` — pass including new blocks.
- [ ] Commit: `feat(install): argv builder and --yes default recipe`

### Task 3: Wire install.sh + numbered UI

**Files:** Modify `install.sh` (MODULES, version stamp, source, gate). Complete `lib/install-tui.sh` (`install_tui_home`, `install_tui_confirm`, `install_tui_main`, `install_tui_show_cmd`, `install_tui_dump`, `install_tui_help`). Tests 5–7.

- [ ] Add failing greps for `MODULES_VERSION=2026.8.27`, `install-tui.sh` in MODULES, `install_tui_main`, dump/secrets.
- [ ] Implement gate + UI. Confirm uses `exec bash "${OVERLAY_ROOT}/install.sh" ${argv}` after `export GROKHUNTER_INSTALL_TUI_RAN=1`. Missing OVERLAY_ROOT → die. Quit → `exit 0`.
- [ ] `bash -n lib/install-tui.sh install.sh` and full `ci-unit.sh`.
- [ ] Commit: `feat(install): Termux first-run numbered installer TUI`

### Task 4: Docs

**Files:** `docs/INSTALL.md`, `docs/FAQ.md`, `CHANGELOG.md`, `README.md`, `skills/grokhunter/SKILL.md`, both REFERENCES overlay-cache lines, website only if the one-liner currently implies flags are required.

- [ ] INSTALL: bare `bash install.sh` → wizard; table for `--yes`; flags skip; `GROKHUNTER_INSTALL_TUI=0` escape hatch.
- [ ] FAQ: distinguish wizard vs `grokhunter tui` vs `grokhunter menu` vs overlay-only.
- [ ] CHANGELOG Unreleased **Installer TUI** bullet.
- [ ] Commit: `docs: first-run installer TUI`

## Verify

```bash
bash scripts/ci-unit.sh
bash -n lib/install-tui.sh install.sh lib/cli.sh
# Manual on Termux TTY:
#   bash install.sh                 # wizard, default coding-only
#   bash install.sh --yes           # no wizard, nano+grok
#   bash install.sh --full --de xfce --with-grok --with-x11   # no wizard
#   GROKHUNTER_INSTALL_TUI=0 bash install.sh   # old choose/ask
```

Do not run a real rootfs install from CI. Confirm path is exec-with-flags; existing engine tests stay the source of truth.

## Out of scope (v1)

- Overlay-only wizard
- `grokhunter tui` Install action
- DE/browser pickers beyond Xfce/Chromium
- Mini size row
- Live fetch progress
- API key / secrets.env editor
- New Coding Team agent or `*-lab` skill

# Design: Termux first-run installer TUI

**Date:** 2026-08-27  
**Status:** Approved  
**Product:** GrokHunter Rootless (coding lab)  
**Version context:** 1.0.10+ (Unreleased)

## Problem

`install.sh` with no flags is already “interactive”, but the UI is a gauntlet of termux-distro `choose` / `ask` prompts (size, then later DE, then each overlay). Phone users cannot see the full recipe before a multi-gigabyte rootfs download. Flags skip prompts entirely. Overlay-only cannot prompt at all.

This is **not** the lab dashboard (`grokhunter tui` / `ghtui`). That spec stays a post-install health hub.

## Goals

- Bare `install.sh` on a Termux **TTY** with no size/feature flags opens a numbered checklist wizard.
- Default recipe is a **coding-only** nano lab: `--nano --no-de --with-grok --with-completions`.
- Confirm prints the exact argv, then `exec`s the existing installer with those flags (`NON_INTERACTIVE=1`).
- Desktop is a preset promotion, not a free-form size+DE matrix.
- Never prompt for an API key. Never print tokens.

## Non-goals (v1)

- Overlay-only wizard (`--overlay-only` still requires `--with-*`).
- `grokhunter tui` Install action, or any change to the dashboard spec/plan.
- New `grokhunter` subcommand. `bin/grokhunter` stays under 1000 lines; `usage()` has no backticks.
- DE/browser pickers beyond Xfce / Chromium. `--mini` row. Other DEs remain flag-only.
- Live rootfs-download progress TUI.
- whiptail, fzf, gum, dialog, curses, python3 UI, apt/pkg/pip.
- Secrets editor / `ai-smoke`.
- Rewriting jorexdeveloper/termux-distro.

## Approach (selected)

**A. Preflight wizard → existing flags.**

`lib/install-tui.sh` builds argv from checklist state. Confirm `exec`s `${OVERLAY_ROOT}/install.sh` with that argv. The one-liner already extracts a real overlay before `parse_cli`, so exec never re-runs `/dev/fd`.

Rejected:

- **B. Polish `choose`/`ask` in place.** Still a sequential gauntlet; no recipe preview.
- **C. Live TUI around the download.** Needs a PTY/log pane; fights the distro engine. Out of v1.

## Locked decisions

| Topic | Decision |
|-------|----------|
| Job | First-run wizard on Termux when TTY and no size/feature flags |
| Default | `--nano --no-de --with-grok --with-completions` |
| Desktop on | `--full --de xfce --browser chromium --with-x11`; keep Grok/completions/Aider/V9 |
| Desktop off | Restore nano `--no-de`, drop X11/browser; extras unchanged |
| Skin | Numbered `read`. Quit is a menu item |
| `--yes` | Non-interactive coding-only default; no wizard |
| Flags | Any size/feature/`--overlay-only` sets `NON_INTERACTIVE=1` and skips the wizard |
| Non-TTY + no flags | Die with paste-ready examples. Do not run `choose`/`ask` |
| Escape hatch | `GROKHUNTER_INSTALL_TUI=0` keeps old `choose`/`ask` |
| Loop guard | `GROKHUNTER_INSTALL_TUI_RAN=1` on exec |
| Overlay cache | `MODULES_VERSION` / `VERSION_NAME` **2026.8.27** |

## Architecture

```
bash install.sh          (TTY, no size/feature flags)
        │
        ▼
ensure_overlay_tree      (real OVERLAY_ROOT, never /dev/fd)
parse_cli
        │
        ├─ NON_INTERACTIVE=1  → existing engine (unchanged)
        ├─ not a TTY          → die + example flags
        ├─ GROKHUNTER_INSTALL_TUI=0 → old choose/ask
        └─ install_tui_main
                ├─ numbered Home
                ├─ Confirm → exec ${OVERLAY_ROOT}/install.sh <argv>
                └─ Quit → exit 0
```

### `--yes`

`parse_cli --yes` sets:

- `NON_INTERACTIVE=1`
- `SELECTED_INSTALLATION=nano`
- `SKIP_DE=1`
- grok + completions **yes**
- x11 + aider + v9 **no**

Help line: `--yes  Coding-only default (nano, no DE, Grok + completions); no wizard`.

### State

| Variable | Values | Default |
|----------|--------|---------|
| `INSTALL_TUI_PRESET` | `coding` \| `desktop` | `coding` |
| `INSTALL_TUI_GROK` | `yes` \| `no` | `yes` |
| `INSTALL_TUI_COMPLETIONS` | `yes` \| `no` | `yes` |
| `INSTALL_TUI_AIDER` | `yes` \| `no` | `no` |
| `INSTALL_TUI_V9` | `yes` \| `no` | `no` |

`install_tui_set_preset desktop` / `coding` rewrites size/DE/X11/browser only. Extras (Aider, V9, Grok, completions) stay.

### Argv (`install_tui_argv`)

Prints one line of flags (no script path).

| preset | grok | comp | aider | v9 | argv |
|--------|------|------|-------|----|------|
| coding | yes | yes | no | no | `--nano --no-de --with-grok --with-completions` |
| coding | no | no | no | no | `--nano --no-de --no-grok --no-completions` |
| coding | yes | yes | yes | yes | `--nano --no-de --with-grok --with-completions --with-aider --with-v9-models` |
| desktop | yes | yes | no | no | `--full --de xfce --browser chromium --with-x11 --with-grok --with-completions` |
| desktop | no | yes | no | no | `--full --de xfce --browser chromium --with-x11 --no-grok --with-completions` |

Always emit explicit grok and completions flags. Coding never emits `--de` / `--browser` / `--with-x11`. Desktop always emits `--with-x11 --de xfce --browser chromium`. Aider/V9 only when `yes`.

### Functions (`lib/install-tui.sh`)

`install_tui_defaults` `install_tui_argv` `install_tui_should_run`  
`install_tui_help` `install_tui_dump` `install_tui_show_cmd`  
`install_tui_toggle` `install_tui_set_preset`  
`install_tui_home` `install_tui_confirm` `install_tui_main`

`install_tui_should_run` returns false when `NON_INTERACTIVE=1`, `OVERLAY_ONLY=1`, `GROKHUNTER_INSTALL_TUI=0`, or `GROKHUNTER_INSTALL_TUI_RAN=1`. TTY is enforced by `install.sh` (`[[ -t 0 && -t 1 ]]`), not inside the function.

`install_tui_dump` prints argv only (no `XAI`, no `secrets`).

Confirm `exec`s `bash "${OVERLAY_ROOT}/install.sh"` with the argv after `export GROKHUNTER_INSTALL_TUI_RAN=1`. Missing `OVERLAY_ROOT` → die. Low disk (`_gh_df_avail_gb`: nano 2, full 6) warns and still allows Confirm.

### Home copy

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

Desktop lab line: `desktop (full, Xfce, Chromium, X11)`. Item 2 then: `Switch to coding-only (nano, no desktop)`.

### Confirm copy

```
About to run:
  bash <OVERLAY_ROOT>/install.sh --nano --no-de --with-grok --with-completions

Downloads a Kali NetHunter rootfs. nano needs ~2G free, full ~6G+.
This can take a long time. Keep Termux open (wake-lock is already held).

  1) Confirm
  2) Back
  3) Quit
```

Never mention API keys.

### `install.sh` gate (after `parse_cli`, before overlay-only / engine)

Source `lib/install-tui.sh`. If `NON_INTERACTIVE=0`: not a TTY → `die_with_help` with coding-only, desktop, and `--yes` examples; else if TUI not disabled and not already ran → `install_tui_main`.

Add `install-tui.sh` to `MODULES`. Bump `MODULES_VERSION` and `VERSION_NAME` to **2026.8.27**.

## Tests

`scripts/ci-unit.sh` only (no `expect` / live TTY):

1. Argv table (five rows).
2. `parse_cli --yes` → nano, `SKIP_DE`, grok/completions yes, x11 no, `NON_INTERACTIVE=1`.
3. `install_tui_should_run` false for NON_INTERACTIVE, OVERLAY_ONLY, `GROKHUNTER_INSTALL_TUI=0`, `GROKHUNTER_INSTALL_TUI_RAN=1`.
4. Preset toggle keeps Aider if it was yes.
5. Dump has no `XAI` / `secrets`.
6. Help contains `--yes`; `install.sh` contains `install-tui.sh` and `2026.8.27`.
7. `lib/install-tui.sh` has no `XAI_API_KEY`.

## Credits

jorexdeveloper (termux-nethunter / termux-distro), Termux team, Kali / Offensive Security, xAI (Grok Build). Not affiliated.

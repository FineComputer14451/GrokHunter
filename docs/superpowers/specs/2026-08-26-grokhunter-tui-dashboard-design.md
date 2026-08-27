# Design: Native GrokHunter dashboard (`grokhunter tui`)

**Date:** 2026-08-26  
**Status:** Draft pending user review of this file  
**Product:** GrokHunter Rootless (coding lab)  
**Version context:** 1.0.10+ (Unreleased)

## Problem

GrokHunter's pair TUI is Grok Build. Bare `grokhunter` already `exec`s `grok-nethunter`. Lab health and repairs (`status`, `doctor`, `setup`, `skills`, `models`, `binds`, `git-identity`) are subcommands you have to remember on a phone.

There is no in-repo keyboard hub that wraps those commands. `grokhunter menu` is the XFCE Applications submenu, not a shell dashboard. Grok Build themes and keybindings are upstream and out of scope.

## Goals

- Ship a **native lab dashboard** at `grokhunter tui` (alias `ghtui`).
- v1 is a hub: status chips plus safe repairs. Actions call existing CLI. No new apt packages.
- Keep bare `grokhunter` as Grok Build. Keep `grokhunter menu` as XFCE.
- Keep `bin/grokhunter` under **1000** lines (`usage()` has **no backticks**). Hub logic lives in `bin/grokhunter-tui`.
- Keyboard-only. Works on Termux host and Kali guest. Offline for home-screen paint.
- Never prompt for an API key. Never print tokens.

## Non-goals (v1)

- Stealing bare `grokhunter` or `grokhunter menu`.
- Changing `bin/grokhunter-desktop-run`'s `grok|tui)` arm (that still launches Grok Build). Comment only, so nobody "fixes" it to the dashboard.
- New XFCE `.desktop` entry.
- Grok Build chrome, statusline, or `/theme`.
- Secrets editor, key prompt, or `ai-smoke` (needs a key).
- Agent launcher grid (`team`, `scout`, …).
- fzf, gum, dialog, curses, or pip.
- Moving `cmd_status` into `lib/`.
- Live-TTY / `expect` tests.
- Mouse, custom colors, JSON API.

## Approach (selected)

**A. Bash hub: whiptail plus numbered fallback.**

`bin/grokhunter-tui` owns the loop. If stdin and stdout are a TTY, `whiptail` exists, and `COLUMNS >= 48`, use a dialog menu. Otherwise print chips and a numbered list, then `read`. Every action runs existing `grokhunter` / `grok-nethunter` commands.

Rejected:

- **B. python3 curses.** python3 is already used for the statusline, but curses is weak on Termux and `TERM=dumb`, and ci-unit has no live TTY.
- **C. Extract `cmd_status` into `lib/` plus a plugin UI.** Cleaner later. It risks the 1000-line cap during the move and is not needed to reuse fields. Parse `grokhunter status`.

## Locked decisions

| Topic | Decision |
|-------|----------|
| Entry | `grokhunter tui`. Shortcut `ghtui`. |
| Bare `grokhunter` | Still Grok Build via `grok-nethunter`. |
| `grokhunter menu` | XFCE submenu. Untouched. |
| UI | Approach A. |
| Launch Grok | **Child process.** When Grok exits, return to the hub (pause, then Home). Do **not** `exec` Grok. |
| v1 actions | Doctor, Setup, Skills, Models, Binds, Git identity, Launch Grok, Credits, Quit. |
| Non-TTY | `--dump` behavior plus a one-line "not a TTY" note. Exit **0**. |
| Secrets | Auth chip only (`no-key` / `env-key` / `secrets.env` / `auth.json`). |

## Architecture

```
grokhunter tui / ghtui
        │  thin case in bin/grokhunter
        ▼
bin/grokhunter-tui
        ├─ grokhunter status     → chips (no network)
        ├─ TTY / whiptail / COLUMNS → skin
        └─ action → existing CLI (foreground) → pause → Home
             Launch Grok is a child, then pause → Home
             Quit exits 0
```

### Dispatcher (`bin/grokhunter`)

`usage()` is an unquoted `<<EOF` (needs `${VERSION}`). Rewrite the first help line and add `tui` **without** backticks:

```
  grokhunter                  Grok Build fullscreen (via grok-nethunter)
  grokhunter tui              Lab dashboard (alias ghtui)
```

Aliases block: plain text `ghtui → tui`.

`main()` next to `doctor)` (about 8 lines). File must stay under 1000 lines:

```
    tui|ghtui)
      shift || true
      tui="${GROKHUNTER_HOME}/bin/grokhunter-tui"
      [[ -f "$tui" ]] || tui="${HOME}/.local/bin/grokhunter-tui"
      [[ -f "$tui" ]] || { echo "grokhunter-tui not found" >&2; exit 1; }
      exec bash "$tui" "$@"
      ;;
```

Keep `""` → `_grok_launcher`. Keep `menu)` → Kali menu. Do not add `tui` to `*)` passthrough (that would launch Grok Build).

### Files

**Add**

- `bin/grokhunter-tui` is the dashboard. `bash -n` already covers `bin/*`.

**Touch**

| File | Change |
|------|--------|
| `bin/grokhunter` | Help line + `tui\|ghtui)` `exec`. No hub logic. |
| `bin/grokhunter-desktop-run` | Comment on `grok\|tui)`: Grok Build, not the lab dashboard. |
| `lib/grok.sh` | `install_cli_bins` copies `grokhunter-tui`. PREFIX copy next to `grokhunter-doctor`. `install_cli_shortcuts` adds `"ghtui:tui"`. |
| `config/completions/bash/grokhunter.bash` | `tui` in `cmds`. |
| `config/completions/zsh/_grokhunter` | `'tui:Lab dashboard (hub + health + repairs)'`. |
| `config/profile.d/grokhunter.sh` | `alias ghtui='grokhunter tui'` (zsh + bash). Still no `gh` alias. |
| `uninstall.sh` | `remove_bins` adds `grokhunter-tui` and `ghtui`. PREFIX list adds `grokhunter-tui`. |
| `scripts/ci-unit.sh` | Tests below. Update shortcut / uninstall regexes. |
| `docs/SHELL.md` | Alias table: `ghtui`. |
| `docs/FAQ.md` | How to open the lab dashboard vs Grok Build. |
| `skills/grokhunter/SKILL.md` | CLI map: bare = Grok Build; `tui` = dashboard. |
| `README.md` | After-install line. |
| `CHANGELOG.md` | Unreleased. |

No new skill or agent. This is a CLI surface, not a Coding Team specialist.

## Home screen

Title: `GrokHunter dashboard`.

**Chips.** One call per Home paint:

```bash
st="$(grokhunter status)"   # always exit 0 today
```

Parse `key=value` tokens from that line. Do not reimplement doctor probes. Do not source `secrets.env`. Do not hit the network.

Chip order (drop from the right when visible length exceeds `COLUMNS`):

1. `auth` 2. `models` 3. `skills-core` 4. `wrappers` 5. `x11` 6. grok version 7. `agents` 8. `session` 9. personas/roles 10. `home`

At most **two** rows. `NO_COLOR=1` skips ANSI. Empty or `COLUMNS=0` means **40**.

**Menu**

| Key | Label | Runs | Confirm | After |
|-----|-------|------|---------|-------|
| 1 | Launch Grok | `grok-nethunter` if executable, else `grok --fullscreen` | No | Child; on exit, pause, Home |
| 2 | Doctor | `grokhunter doctor` | No. Label: may probe x.ai | Pause, Home |
| 3 | Setup | `grokhunter setup --yes` | Yes (may download Grok) | Pause, Home |
| 4 | Skills | submenu: `skills status` / `skills install` | install: yes (local copy) | Pause, Home |
| 5 | Models | submenu: `models status` / `models install` | install: yes (writes `config.toml`) | Pause, Home |
| 6 | Binds | submenu: `binds status` / `binds repair` | repair: yes (host launcher patch) | Pause, Home |
| 7 | Git identity | submenu: `git-identity` (show) / `git-identity set` with **no flags** | set: yes (may hit GitHub, not xAI) | Pause, Home |
| 8 | Credits | `grokhunter credits` | No | Pause, Home |
| q | Quit | exit 0 | No | exit |

Submenus: Status, Repair-or-Install, Back. No free-text forms.

`git-identity set` uses the existing resolver (`gh`, token, origin). If it cannot resolve, print the CLI hint (`--name` / `--email`). That is not an API-key prompt. Do not add TUI fields for name or email in v1.

`binds optimize` is out of v1 (it fails closed if the patch does not apply). Status and repair are enough.

Pager: doctor only, if TTY and `less` exists (`less -R`). Else raw stdout plus `Press Enter`.

Confirm copy: `This may use the network or write lab files.` Never `paste API key`.

Force skin: `GROKHUNTER_TUI=whiptail|plain`.

ESC / Cancel / empty read / `q` goes Back or Quit.

Never `apt` / `pkg` / `pip` from the TUI.

## Flags (always text, no widgets)

| Flag | Behavior | Exit |
|------|----------|------|
| `-h` / `--help` | Help text | 0 |
| `--dump` | Chips + menu labels. No widgets | 0 |
| `--map` | `id<TAB>argv` rows. No exec | 0 |

`--map` ids and argv (string match in ci-unit, no exec):

```
launch-grok	grok-nethunter
doctor	grokhunter doctor
setup	grokhunter setup --yes
skills-status	grokhunter skills status
skills-install	grokhunter skills install
models-status	grokhunter models status
models-install	grokhunter models install
binds-status	grokhunter binds status
binds-repair	grokhunter binds repair
git-identity-show	grokhunter git-identity
git-identity-set	grokhunter git-identity set
credits	grokhunter credits
```

If `grok-nethunter` is missing, `--map` may list `grok --fullscreen` for `launch-grok`. Tests should accept either string.

## TTY rules

| Condition | Behavior |
|-----------|----------|
| `--help` / `--dump` / `--map` | Text, exit 0 |
| stdin **or** stdout not a TTY | Same as `--dump`, plus `not a TTY. Re-run in a terminal`, exit 0 |
| TTY + whiptail + `COLUMNS>=48` + not `GROKHUNTER_TUI=plain` | whiptail `--menu` / `--yesno` |
| TTY otherwise | Numbered list + `read -r` (no `select`, no `eval`) |

Do not fall through to `grok-nethunter` on `tui`.

## Secrets

- Chip values only. Never print the key, `session_id`, or `XAI_API_KEY=`.
- Do not `cat` `secrets.env` in the TUI. Presence comes from `grokhunter status`.
- Do not add a Secrets screen. Do not launch the `secrets` **agent**.
- No `set -x`. Do not dump the environment.
- ci-unit: `XAI_API_KEY=xai-secret-should-not-appear` plus a fake `secrets.env` containing that token. `--dump` / `--map` / `--help` must not contain the token or `XAI_API_KEY=`.

## Completions and shortcuts

- Bash/zsh: complete `tui` at word 1. Optional flags `--help` `--dump` `--map`.
- `~/.local/bin/ghtui` from `install_cli_shortcuts` (`ghtui:tui`).
- `install_cli_bins` copies `bin/grokhunter-tui` to `~/.local/bin` and, when `PREFIX/bin` exists, to PREFIX next to `grokhunter-doctor`.
- Uninstall removes `ghtui` and `grokhunter-tui`.
- Profile alias `ghtui`. Still no `gh`.

## Risks

| Risk | Mitigation |
|------|------------|
| Dispatcher grows past 1000 lines | Only usage + `tui)` arm. ci-unit already dies at ≥1000. |
| Backticks in `usage()` execute | Plain `alias ghtui`. Existing grep stays. |
| `tui` confused with Grok Build | Help reword. desktop-run comment. FAQ + skill map. |
| Whiptail missing on Termux | Numbered `read` is the host default. |
| `COLUMNS=0` | Coerce to 40. |
| Setup/doctor surprise network | Confirm setup. Label doctor. Chips stay offline. |
| `git-identity set` looks like a key form | No TUI fields. Flags-less CLI or print the hint. |
| Binds repair in Kali guest | Exec CLI. Show its output. No Magisk/HID. |
| Launch Grok vs Quit | Only Quit exits the hub. Grok is a child. |
| `grokhunter-desktop-run tui` | Remains Grok Build in v1. |

## Acceptance criteria

1. `grokhunter tui` and `ghtui` open the hub on a TTY. Numbered fallback without whiptail.
2. Bare `grokhunter` still launches Grok Build. `grokhunter menu` still XFCE.
3. Home chips match `grokhunter status` fields. No network on paint.
4. Actions match the table. Setup / install / repair / set confirm. Launch Grok is a child and returns.
5. Auth is present/missing only. No key prompt. No token in output.
6. `bin/grokhunter` < 1000 lines. `usage()` has no backticks. Help lists `grokhunter tui`.
7. Completions include `tui`. Uninstall removes `ghtui` and `grokhunter-tui`.
8. Host (Termux) and guest (Kali) work overlay-only. Hub + chips work offline.
9. `bash scripts/ci-unit.sh` passes with no live TTY.
10. `COLUMNS=40` dump is at most two chip rows. No wrap explosion.

## Test plan (ci-unit only)

No `script`, `expect`, or `unbuffer`.

1. `bash -n bin/grokhunter-tui` (covered by existing `bin/*` syntax loop).
2. Keep `wc -l bin/grokhunter` < 1000.
3. Keep `usage()` backtick grep.
4. Help contains `grokhunter tui` and `ghtui`, still documents bare fullscreen / grok-nethunter and `menu`, and does not call the dashboard the default command.
5. `bash bin/grokhunter tui --help` / `--dump` / `--map` never spawn `grok`. Missing `grokhunter-tui` → exit 1, not grok.
6. `--map` includes the id/argv rows above.
7. `--dump` contains `auth=` `models=` `skills-core=` `wrappers=` (same tokens as `grokhunter status`).
8. `COLUMNS=0` and `COLUMNS=40` `--dump` succeed. `home=` may be omitted. After ANSI strip, no line longer than the effective column width (40 when COLUMNS=0).
9. `grokhunter tui </dev/null | cat` exits 0, prints dump, does not invoke whiptail.
10. Fake `XAI_API_KEY` + `secrets.env`: `--dump` / `--help` / `--map` must not match the token or `XAI_API_KEY=`.
11. `grep ghtui:tui lib/grok.sh`. Uninstall list includes `ghtui` and `grokhunter-tui`. Update the existing shortcut regex (`ghsu ght ghd …`).
12. Bash `cmds` and zsh `commands` include `tui`.
13. TUI script does not call `apt` / `pkg` / `pip`. `--dump` does not require `python3`.
14. `bin/grokhunter-desktop-run` `grok|tui)` still launches grok-nethunter. `main()` `""` still `_grok_launcher`.

## Security notes

Coding-lab hub only. Chips are local. Confirm before writes or network. Never prompt for or echo `XAI_API_KEY`. `git-identity` may show `user.email` (GitHub attribution, not API). Binds repair patches the Termux `nethunter` launcher through existing CLI. Overlay, not a fork.

## Handoff

**Lucas.** Implement Approach A in the file list. Dispatcher is usage plus `exec` only. Ship ci-unit cases in the same change.

**Harper.** Secrets dump, non-TTY exit 0, `COLUMNS=0`, dispatcher identity (bare vs `tui` vs `menu`), uninstall regex. No live TTY harness.

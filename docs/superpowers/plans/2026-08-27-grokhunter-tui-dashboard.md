# Native GrokHunter dashboard (`grokhunter tui`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a keyboard lab dashboard at `grokhunter tui` (alias `ghtui`) that paints `grokhunter status` chips and runs existing repair commands, without stealing bare `grokhunter` (Grok Build) or `grokhunter menu` (XFCE).

**Architecture:** Thin `tui|ghtui)` arm in `bin/grokhunter` `exec`s `bin/grokhunter-tui`. The hub parses `grokhunter status` (no network, no `secrets.env`). TTY + `whiptail` + `COLUMNS>=48` uses a dialog menu; otherwise numbered `read`. Launch Grok is a child process, then pause, then Home. Text flags `--help` / `--dump` / `--map` never open widgets.

**Tech Stack:** Bash 4.3+ (`unset 'arr[-1]'`), optional `whiptail` (already on Kali; Termux host uses numbered fallback), existing `grokhunter` / `grok-nethunter` CLIs, `scripts/ci-unit.sh` (no `expect` / live TTY).

**Spec:** `docs/superpowers/specs/2026-08-26-grokhunter-tui-dashboard-design.md`

## Global Constraints

- Entry is `grokhunter tui`. Shortcut / alias `ghtui`. Do not add a `gh` alias.
- Bare `grokhunter` still `exec`s `_grok_launcher` (Grok Build via `grok-nethunter`).
- `grokhunter menu` stays the XFCE submenu. Do not add a new `.desktop` entry.
- `bin/grokhunter-desktop-run` `grok|tui)` stays Grok Build. Comment only.
- `bin/grokhunter` stays under **1000** lines. `usage()` heredoc has **no backticks**.
- Hub logic lives in `bin/grokhunter-tui`. Dispatcher is usage + `exec` only.
- v1 actions only: Launch Grok, Doctor, Setup, Skills, Models, Binds, Git identity, Credits, Quit. No agent grid, no `ai-smoke`, no secrets editor, no `binds optimize`.
- Launch Grok is a **child** (no `exec`). On exit: pause, Home. Only Quit leaves the hub.
- Setup / skills install / models install / binds repair / `git-identity set` confirm with exactly: `This may use the network or write lab files.`
- Doctor label includes `may probe x.ai`. Pager is doctor only (`less -R` when TTY and `less` exists).
- `git-identity set` runs with **no flags**. No TUI name/email fields. CLI already prints `--name` / `--email` if it cannot resolve.
- Non-TTY: same as `--dump`, plus `not a TTY. Re-run in a terminal`, exit **0**.
- `COLUMNS=0` or empty / non-numeric → **40**. At most **two** chip rows. Drop chips from the right. `home=` may be omitted.
- `NO_COLOR=1` skips ANSI. `--dump` must not require `python3`.
- Never prompt for an API key. Never print tokens, `session_id`, or `XAI_API_KEY=`. Do not `cat` / source `secrets.env`. No `set -x`.
- Never `apt` / `pkg` / `pip` from the TUI. No fzf, gum, dialog, curses, or new packages.
- Do not extract `cmd_status` into `lib/`. Parse `grokhunter status`.
- No new skill or Coding Team agent.
- Overlay-only install copies the hub next to `grokhunter-doctor` (`~/.local/bin` and `PREFIX/bin` when present).
- **Dirty tree:** other Unreleased work (tls/net/statusline) may already be modified. Commit **only** paths in this plan’s file map (plus the spec). Do not revert unrelated diffs; when editing CHANGELOG/README/FAQ/skill, add the TUI lines and leave the rest.

## File map

| File | Role |
|------|------|
| `docs/superpowers/specs/2026-08-26-grokhunter-tui-dashboard-design.md` | Approved spec (already written; mark Approved) |
| `bin/grokhunter-tui` | **Create** — dashboard loop, flags, chips, actions |
| `bin/grokhunter` | Help rewrite + `tui\|ghtui)` `exec`. No hub logic |
| `bin/grokhunter-desktop-run` | Comment on `grok\|tui)` |
| `lib/grok.sh` | `install_cli_bins` copies `grokhunter-tui`; PREFIX next to doctor; `ghtui:tui` shortcut |
| `uninstall.sh` | Remove `grokhunter-tui` and `ghtui` (local + PREFIX) |
| `config/completions/bash/grokhunter.bash` | `tui` in `cmds`; flags `--help --dump --map` |
| `config/completions/zsh/_grokhunter` | `'tui:Lab dashboard (hub + health + repairs)'` + flags |
| `config/profile.d/grokhunter.sh` | `alias ghtui='grokhunter tui'` (zsh + bash) |
| `scripts/ci-unit.sh` | Tests below |
| `docs/SHELL.md` | Alias table `ghtui` |
| `docs/FAQ.md` | Lab dashboard vs Grok Build vs XFCE menu |
| `skills/grokhunter/SKILL.md` | CLI map: bare = Grok; `tui` = dashboard |
| `README.md` | After-install line |
| `CHANGELOG.md` | Unreleased CLI bullet |

Locked function names in `bin/grokhunter-tui` (later tasks grep these):

- `tui_cols` `tui_strip` `tui_status` `tui_parse_chips` `tui_fit_chips` `tui_dump` `tui_map` `tui_help`
- `tui_skin` `tui_pause` `tui_confirm` `tui_run` `tui_run_doctor` `tui_launch_grok`
- `tui_home_loop` `tui_skills_menu` `tui_models_menu` `tui_binds_menu` `tui_git_menu` `tui_main`

`--map` rows (TAB between id and argv; `launch-grok` may be `grok --fullscreen` if `grok-nethunter` is missing):

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

Chip order (drop from the right): `auth` `models` `skills-core` `wrappers` `x11` `grok` (second `|` field from status) `agents` `session` `personas/roles` (one chip) `home`.

---

### Task 1: Failing CI for help + missing hub

**Files:**
- Modify: `docs/superpowers/specs/2026-08-26-grokhunter-tui-dashboard-design.md` (status line only)
- Modify: `scripts/ci-unit.sh` (CLI help surfaces ~233–272, plus a new missing-hub block immediately after those help greps)
- Test: `scripts/ci-unit.sh`

**Interfaces:**
- Consumes: current `bin/grokhunter` `usage()` / `main()` (no `tui` yet)
- Produces: assertions that fail until Task 2 rewrites help and adds `tui|ghtui)`

- [ ] **Step 1: Mark the spec approved**

In `docs/superpowers/specs/2026-08-26-grokhunter-tui-dashboard-design.md`, replace:

```markdown
**Status:** Draft pending user review of this file
```

with:

```markdown
**Status:** Approved 2026-08-27
```

- [ ] **Step 2: Extend CLI help assertions**

Immediately after `_help="$(bash bin/grokhunter help)"` in `scripts/ci-unit.sh`, add:

```bash
echo "${_help}" | grep -q 'grokhunter tui' || die "help missing grokhunter tui"
echo "${_help}" | grep -q ghtui || die "help missing ghtui"
echo "${_help}" | grep -q grok-nethunter || die "help missing grok-nethunter"
# First usage line is still Grok Build, not the lab dashboard
_bare="$(echo "${_help}" | grep -E '^  grokhunter[[:space:]]{2,}' | head -1 || true)"
echo "${_bare}" | grep -qi dashboard && die "bare grokhunter must remain Grok Build, not dashboard: ${_bare}"
echo "${_help}" | grep -qE 'ghtui → tui|ghtui -> tui' || die "help aliases must list ghtui → tui (no backticks)"
```

Keep the existing backtick grep on `usage()` unchanged.

- [ ] **Step 3: Add missing-hub dispatcher test**

Immediately after the help/credits/models/skills/setup help block (after `setup --help` grep, before the next `info` or the next section), insert:

```bash
# ---------- grokhunter tui dispatcher (missing hub must not launch Grok) ----------
bash -c '
  set -euo pipefail
  ROOT="$(pwd)"
  d=$(mktemp -d)
  mkdir -p "$d/bin" "$d/home/.local/bin"
  cp "$ROOT/bin/grokhunter" "$d/bin/grokhunter"
  : > "$d/install.sh"
  printf "%s\n" "1.0.10" > "$d/VERSION"
  printf "%s\n" "#!/bin/sh" "echo launched >> \"\$HOME/grok.stamp\"" "exit 0" \
    > "$d/bin/grok-nethunter"
  chmod +x "$d/bin/grok-nethunter"
  # No grokhunter-tui in GROKHUNTER_HOME or ~/.local/bin
  ec=0
  HOME="$d/home" PATH="$d/bin:$PATH" bash "$d/bin/grokhunter" tui \
    >"$d/out" 2>"$d/err" || ec=$?
  [[ "$ec" -eq 1 ]] || { echo "missing hub exit=$ec (want 1)"; exit 1; }
  grep -q "grokhunter-tui not found" "$d/err"
  [[ ! -f "$d/home/grok.stamp" ]] || { echo "tui fell through to grok-nethunter"; exit 1; }
  # ghtui alias of the same arm
  ec=0
  HOME="$d/home" PATH="$d/bin:$PATH" bash "$d/bin/grokhunter" ghtui \
    >"$d/out" 2>"$d/err" || ec=$?
  [[ "$ec" -eq 1 ]]
  [[ ! -f "$d/home/grok.stamp" ]]
  rm -rf "$d"
'
info "tui missing-hub dispatcher OK"
```

Today this fails because `tui` falls through to `*)` → `_grok_launcher`.

- [ ] **Step 4: Run tests — expect FAIL**

Run: `bash scripts/ci-unit.sh`

Expected: FAIL with `help missing grokhunter tui` (or the missing-hub stamp if help were already patched).

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/specs/2026-08-26-grokhunter-tui-dashboard-design.md scripts/ci-unit.sh
git commit -m "$(cat <<'EOF'
test(tui): require grokhunter tui help and missing-hub exit 1

EOF
)"
```

---

### Task 2: Dispatcher + usage() only

**Files:**
- Modify: `bin/grokhunter` `usage()` (~152–240) and `main()` next to `doctor)` (~902–906)
- Test: `scripts/ci-unit.sh` (Task 1 assertions + existing `wc -l` / backtick greps)

**Interfaces:**
- Consumes: Task 1 tests; `GROKHUNTER_HOME/bin/grokhunter-tui` then `~/.local/bin/grokhunter-tui`
- Produces: `tui|ghtui)` `exec bash "$tui" "$@"`; help lines below. Hub file still absent → exit 1.

- [ ] **Step 1: Rewrite the first usage lines and alias row**

In `usage()`, replace:

```
  grokhunter                  Interactive fullscreen TUI
  grokhunter status           Short status line (always exit 0)
```

with (plain text, **no backticks**):

```
  grokhunter                  Grok Build fullscreen (via grok-nethunter)
  grokhunter tui              Lab dashboard (alias ghtui)
  grokhunter status           Short status line (always exit 0)
```

In the Aliases block, add this line (plain arrow, no backticks):

```
  ghtui → tui
```

Keep `menu` documented. Do not call the dashboard the default command.

- [ ] **Step 2: Add the dispatcher arm next to `doctor)`**

Inside `main()`, immediately after the `doctor)` arm (before `binds|proot-binds)`), insert exactly:

```bash
    tui|ghtui)
      shift || true
      tui="${GROKHUNTER_HOME}/bin/grokhunter-tui"
      [[ -f "$tui" ]] || tui="${HOME}/.local/bin/grokhunter-tui"
      [[ -f "$tui" ]] || { echo "grokhunter-tui not found" >&2; exit 1; }
      exec bash "$tui" "$@"
      ;;
```

Do **not** add `tui` to `*)`. Keep `""` → `_grok_launcher`. Keep `menu|kali-menu|desktop-menu)` unchanged.

- [ ] **Step 3: Guard the 1000-line cap**

Run: `wc -l < bin/grokhunter`

Expected: still `< 1000` (file is 979 today; this change is about +10). If ≥1000, delete a blank line inside `usage()` or shrink a comment — do not move hub logic into `bin/grokhunter`.

- [ ] **Step 4: Run tests — expect PASS for Task 1 + existing suite**

Run: `bash scripts/ci-unit.sh`

Expected: PASS. `help missing grokhunter tui` is gone. Missing-hub test exits 1 with `grokhunter-tui not found` and no `grok.stamp`. Backtick grep still clean.

- [ ] **Step 5: Commit**

```bash
git add bin/grokhunter
git commit -m "$(cat <<'EOF'
feat(cli): dispatch grokhunter tui to grokhunter-tui

EOF
)"
```

---

### Task 3: Hub text surfaces + keyboard loop

**Files:**
- Create: `bin/grokhunter-tui` (mode 755)
- Modify: `scripts/ci-unit.sh` (new block after the missing-hub test)
- Test: `scripts/ci-unit.sh`

**Interfaces:**
- Consumes: dispatcher `exec bash "$tui" "$@"`; `grokhunter status` line with `auth=` `models=` `skills-core=` `wrappers=` (and the other fields)
- Produces: `--help` / `--dump` / `--map`; non-TTY dump; Home loop functions listed in the file map

- [ ] **Step 1: Write the failing hub tests**

Insert after `info "tui missing-hub dispatcher OK"`:

```bash
# ---------- grokhunter tui hub (text flags; no live TTY) ----------
[[ -f bin/grokhunter-tui ]] || die "missing bin/grokhunter-tui"
if grep -vE '^[[:space:]]*#' bin/grokhunter-tui | grep -qE '(^|[[:space:]])(apt-get|apt|pkg|pip3|pip)([[:space:]]|$)'; then
  die "TUI must not call apt/pkg/pip"
fi
if grep -qE '(^|[[:space:]])set[[:space:]]+(-[^-]*x|--verbose)' bin/grokhunter-tui; then
  die "TUI must not set -x"
fi
if grep -vE '^[[:space:]]*#' bin/grokhunter-tui | grep -q 'secrets.env'; then
  die "TUI must not open secrets.env"
fi
if grep -vE '^[[:space:]]*#' bin/grokhunter-tui | grep -qE 'python3|eval '; then
  die "TUI must not call python3 or eval"
fi
if grep -qE 'binds optimize|ai-smoke' bin/grokhunter-tui; then
  die "v1 TUI must not expose binds optimize or ai-smoke"
fi
grep -q '^tui_launch_grok()' bin/grokhunter-tui || die "missing tui_launch_grok"
if grep -A30 '^tui_launch_grok()' bin/grokhunter-tui | grep -qE '(^|[[:space:]])exec[[:space:]]'; then
  die "Launch Grok must be a child, not exec"
fi
grep -q 'This may use the network or write lab files.' bin/grokhunter-tui \
  || die "TUI confirm copy missing"
grep -q 'less -R' bin/grokhunter-tui || die "doctor pager must use less -R"
grep -q 'GROKHUNTER_TUI' bin/grokhunter-tui || die "TUI must honor GROKHUNTER_TUI"
grep -q 'not a TTY. Re-run in a terminal' bin/grokhunter-tui \
  || die "non-TTY copy missing"

_tui_help="$(bash bin/grokhunter tui --help)"
echo "${_tui_help}" | grep -q 'Lab dashboard' || die "tui --help missing Lab dashboard"
echo "${_tui_help}" | grep -q -- '--dump' || die "tui --help missing --dump"
echo "${_tui_help}" | grep -q -- '--map' || die "tui --help missing --map"
echo "${_tui_help}" | grep -qi 'XAI_API_KEY' && die "tui --help must not mention XAI_API_KEY"

_tui_map="$(bash bin/grokhunter tui --map)"
echo "${_tui_map}" | grep -q $'doctor\tgrokhunter doctor' || die "map missing doctor"
echo "${_tui_map}" | grep -q $'setup\tgrokhunter setup --yes' || die "map missing setup"
echo "${_tui_map}" | grep -q $'skills-status\tgrokhunter skills status' || die "map missing skills-status"
echo "${_tui_map}" | grep -q $'skills-install\tgrokhunter skills install' || die "map missing skills-install"
echo "${_tui_map}" | grep -q $'models-status\tgrokhunter models status' || die "map missing models-status"
echo "${_tui_map}" | grep -q $'models-install\tgrokhunter models install' || die "map missing models-install"
echo "${_tui_map}" | grep -q $'binds-status\tgrokhunter binds status' || die "map missing binds-status"
echo "${_tui_map}" | grep -q $'binds-repair\tgrokhunter binds repair' || die "map missing binds-repair"
echo "${_tui_map}" | grep -q $'git-identity-show\tgrokhunter git-identity' || die "map missing git-identity-show"
echo "${_tui_map}" | grep -q $'git-identity-set\tgrokhunter git-identity set' || die "map missing git-identity-set"
echo "${_tui_map}" | grep -q $'credits\tgrokhunter credits' || die "map missing credits"
echo "${_tui_map}" | grep -qE $'launch-grok\t(grok-nethunter|grok --fullscreen)' \
  || die "map launch-grok must be grok-nethunter or grok --fullscreen"
echo "${_tui_map}" | grep -q optimize && die "map must not include optimize"
echo "${_tui_map}" | grep -q ai-smoke && die "map must not include ai-smoke"

_tui_dump="$(bash bin/grokhunter tui --dump)"
echo "${_tui_dump}" | grep -q 'GrokHunter dashboard' || die "dump missing title"
echo "${_tui_dump}" | grep -q 'auth=' || die "dump missing auth="
echo "${_tui_dump}" | grep -q 'models=' || die "dump missing models="
echo "${_tui_dump}" | grep -q 'skills-core=' || die "dump missing skills-core="
echo "${_tui_dump}" | grep -q 'wrappers=' || die "dump missing wrappers="
echo "${_tui_dump}" | grep -q 'Launch Grok' || die "dump missing Launch Grok"
echo "${_tui_dump}" | grep -q 'may probe x.ai' || die "dump missing doctor network label"
echo "${_tui_dump}" | grep -q 'Quit' || die "dump missing Quit"

_tui_strip() { sed $'s/\033\\[[0-9;]*m//g'; }
_tui_check_width() {
  local width="$1" line vis
  while IFS= read -r line; do
    vis="$(printf '%s' "${line}" | _tui_strip)"
    if [[ "${#vis}" -gt "${width}" ]]; then
      echo "chip line longer than ${width}: ${#vis} [${vis}]" >&2
      return 1
    fi
  done
}
# Title + at most two chip rows (menu labels are checked separately)
_dump40="$(COLUMNS=40 bash bin/grokhunter tui --dump)"
echo "${_dump40}" | grep -q 'auth=' || die "COLUMNS=40 dump missing auth="
_chip40="$(echo "${_dump40}" | awk 'BEGIN{p=0} /^GrokHunter dashboard$/{p=1; next} p && /^[0-9]/{exit} p')"
echo "${_chip40}" | _tui_check_width 40 || die "COLUMNS=40 chip row overflow"
_chip_rows="$(echo "${_chip40}" | grep -c . || true)"
[[ "${_chip_rows}" -le 2 ]] || die "chips must be at most two rows, got ${_chip_rows}"
_dump0="$(COLUMNS=0 bash bin/grokhunter tui --dump)"
_chip0="$(echo "${_dump0}" | awk 'BEGIN{p=0} /^GrokHunter dashboard$/{p=1; next} p && /^[0-9]/{exit} p')"
echo "${_chip0}" | _tui_check_width 40 || die "COLUMNS=0 must behave as width 40"

# Non-TTY: dump + note, exit 0, never whiptail
_whip="$(mktemp -d)"
printf '%s\n' '#!/bin/sh' 'echo WHIPTAIL >> "$WHIP_LOG"' 'exit 1' > "${_whip}/whiptail"
chmod +x "${_whip}/whiptail"
WHIP_LOG="${_whip}/log"
export WHIP_LOG
_nontty="$(PATH="${_whip}:$PATH" bash bin/grokhunter tui </dev/null | cat)"
echo "${_nontty}" | grep -q 'auth=' || die "non-TTY must dump chips"
echo "${_nontty}" | grep -q 'not a TTY. Re-run in a terminal' || die "non-TTY note missing"
[[ ! -f "${WHIP_LOG}" ]] || die "non-TTY invoked whiptail"
unset WHIP_LOG
rm -rf "${_whip}"

# Secrets: chip presence only
_sec_home="$(mktemp -d)"
mkdir -p "${_sec_home}/.grok"
printf '%s\n' 'export XAI_API_KEY=xai-secret-should-not-appear' > "${_sec_home}/.grok/secrets.env"
chmod 600 "${_sec_home}/.grok/secrets.env"
_sec_env="XAI_API_KEY=xai-secret-should-not-appear HOME=${_sec_home}"
for _flag in --help --dump --map; do
  _sec_out="$(env ${_sec_env} bash bin/grokhunter tui ${_flag})"
  echo "${_sec_out}" | grep -q 'xai-secret-should-not-appear' \
    && die "tui ${_flag} leaked secret token"
  echo "${_sec_out}" | grep -q 'XAI_API_KEY=' \
    && die "tui ${_flag} leaked XAI_API_KEY="
done
rm -rf "${_sec_home}"
info "tui hub text surfaces OK"
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `bash scripts/ci-unit.sh`

Expected: FAIL with `missing bin/grokhunter-tui`.

- [ ] **Step 3: Create `bin/grokhunter-tui`**

Write this exact file and `chmod 755 bin/grokhunter-tui`. Do not source `profile.sh` or `secrets.env`.

```bash
#!/usr/bin/env bash
# GrokHunter lab dashboard — keyboard hub for status + repairs.
# Not Grok Build. Bare grokhunter still launches grok-nethunter.
set -euo pipefail

export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${HERE}/../install.sh" ]]; then
  GROKHUNTER_HOME="$(cd "${HERE}/.." && pwd)"
elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/install.sh" ]]; then
  :
elif [[ -d "${HOME}/GrokHunter" ]]; then
  GROKHUNTER_HOME="${HOME}/GrokHunter"
else
  GROKHUNTER_HOME="${HERE}"
fi
export GROKHUNTER_HOME
export PATH="${GROKHUNTER_HOME}/bin:${PATH}"

C_KEY=""
C_RST=""
if [[ -z "${NO_COLOR:-}" && -t 1 ]]; then
  C_KEY=$'\033[36m'
  C_RST=$'\033[0m'
fi

tui_cols() {
  local c="${COLUMNS:-40}"
  if ! [[ "${c}" =~ ^[0-9]+$ ]]; then
    c=40
  fi
  if [[ "${c}" -eq 0 ]]; then
    c=40
  fi
  printf '%s\n' "${c}"
}

tui_strip() {
  printf '%s' "$1" | sed $'s/\033\\[[0-9;]*m//g'
}

tui_join() {
  local s="" x
  for x in "$@"; do
    [[ -n "${x}" ]] || continue
    if [[ -z "${s}" ]]; then
      s="${x}"
    else
      s="${s} ${x}"
    fi
  done
  printf '%s' "${s}"
}

_gh() {
  if command -v grokhunter >/dev/null 2>&1; then
    grokhunter "$@"
    return
  fi
  if [[ -f "${GROKHUNTER_HOME}/bin/grokhunter" ]]; then
    bash "${GROKHUNTER_HOME}/bin/grokhunter" "$@"
    return
  fi
  echo "grokhunter not found" >&2
  return 127
}

tui_status() {
  _gh status || true
}

tui_kv() {
  local hay="$1" key="$2" tok
  while IFS= read -r tok; do
    tok="${tok#"${tok%%[![:space:]]*}"}"
    tok="${tok%"${tok##*[![:space:]]}"}"
    case "${tok}" in
      "${key}"=*)
        printf '%s\n' "${tok#${key}=}"
        return 0
        ;;
    esac
  done < <(printf '%s' "${hay}" | tr '|' '\n')
  return 0
}

tui_parse_chips() {
  local st="$1"
  local auth models skills wrappers x11 agents session home personas roles gver
  auth="$(tui_kv "${st}" auth)"
  models="$(tui_kv "${st}" models)"
  skills="$(tui_kv "${st}" skills-core)"
  wrappers="$(tui_kv "${st}" wrappers)"
  x11="$(tui_kv "${st}" x11)"
  agents="$(tui_kv "${st}" agents)"
  session="$(tui_kv "${st}" session)"
  home="$(tui_kv "${st}" home)"
  personas="$(tui_kv "${st}" personas)"
  roles="$(tui_kv "${st}" roles)"
  gver="$(printf '%s' "${st}" | awk -F'|' '{print $2}')"
  gver="${gver#"${gver%%[![:space:]]*}"}"
  gver="${gver%"${gver##*[![:space:]]}"}"
  TUI_CHIPS=(
    "auth=${auth:-?}"
    "models=${models:-?}"
    "skills-core=${skills:-?}"
    "wrappers=${wrappers:-?}"
    "x11=${x11:-?}"
    "grok=${gver:-?}"
    "agents=${agents:-?}"
    "session=${session:-?}"
    "personas=${personas:-?} roles=${roles:-?}"
    "home=${home:-?}"
  )
}

tui_color_chip() {
  local chip="$1" k v
  k="${chip%%=*}"
  v="${chip#*=}"
  if [[ -n "${C_KEY}" ]]; then
    printf '%s%s%s=%s' "${C_KEY}" "${k}" "${C_RST}" "${v}"
  else
    printf '%s' "${chip}"
  fi
}

tui_layout() {
  local width="$1"
  shift
  local -a chips=("$@")
  local -a row1=() row2=()
  local c try vis rest
  for c in "${chips[@]}"; do
    try="$(tui_join "${row1[@]}" "$(tui_color_chip "${c}")")"
    vis="$(tui_strip "${try}")"
    if (( ${#vis} <= width )); then
      row1+=("$(tui_color_chip "${c}")")
    else
      row2+=("$(tui_color_chip "${c}")")
    fi
  done
  rest="$(tui_join "${row2[@]}")"
  if (( ${#row2[@]} > 0 )); then
    vis="$(tui_strip "${rest}")"
    if (( ${#vis} > width )); then
      return 1
    fi
  fi
  tui_join "${row1[@]}"
  printf '\n'
  if (( ${#row2[@]} > 0 )); then
    tui_join "${row2[@]}"
    printf '\n'
  fi
  return 0
}

tui_fit_chips() {
  local width="$1"
  shift
  local -a chips=("$@")
  local out
  while (( ${#chips[@]} > 0 )); do
    if out="$(tui_layout "${width}" "${chips[@]}")"; then
      printf '%s' "${out}"
      return 0
    fi
    unset 'chips[-1]'
  done
  printf '%s\n' ""
}

tui_menu_labels() {
  cat <<'EOF'
1  Launch Grok
2  Doctor (may probe x.ai)
3  Setup
4  Skills
5  Models
6  Binds
7  Git identity
8  Credits
q  Quit
EOF
}

tui_dump() {
  local st
  st="$(tui_status)"
  tui_parse_chips "${st}"
  printf '%s\n' "GrokHunter dashboard"
  tui_fit_chips "$(tui_cols)" "${TUI_CHIPS[@]}"
  tui_menu_labels
}

tui_launch_bin() {
  if command -v grok-nethunter >/dev/null 2>&1; then
    printf '%s\n' "grok-nethunter"
    return 0
  fi
  if [[ -x "${GROKHUNTER_HOME}/bin/grok-nethunter" ]]; then
    printf '%s\n' "grok-nethunter"
    return 0
  fi
  printf '%s\n' "grok --fullscreen"
}

tui_map() {
  local launch
  launch="$(tui_launch_bin)"
  printf '%s\t%s\n' "launch-grok" "${launch}"
  printf '%s\t%s\n' "doctor" "grokhunter doctor"
  printf '%s\t%s\n' "setup" "grokhunter setup --yes"
  printf '%s\t%s\n' "skills-status" "grokhunter skills status"
  printf '%s\t%s\n' "skills-install" "grokhunter skills install"
  printf '%s\t%s\n' "models-status" "grokhunter models status"
  printf '%s\t%s\n' "models-install" "grokhunter models install"
  printf '%s\t%s\n' "binds-status" "grokhunter binds status"
  printf '%s\t%s\n' "binds-repair" "grokhunter binds repair"
  printf '%s\t%s\n' "git-identity-show" "grokhunter git-identity"
  printf '%s\t%s\n' "git-identity-set" "grokhunter git-identity set"
  printf '%s\t%s\n' "credits" "grokhunter credits"
}

tui_help() {
  cat <<'EOF'
Usage: grokhunter tui [--help|--dump|--map]

Lab dashboard (status chips + repairs). Not Grok Build.
Bare grokhunter still launches Grok. grokhunter menu is XFCE.

  --help   This help
  --dump   Chips + menu labels (no widgets)
  --map    Action id and argv (no exec)

Alias: ghtui
Env: GROKHUNTER_TUI=whiptail|plain
EOF
}

tui_skin() {
  if [[ "${GROKHUNTER_TUI:-}" == "plain" ]]; then
    printf '%s\n' "plain"
    return 0
  fi
  if ! command -v whiptail >/dev/null 2>&1; then
    printf '%s\n' "plain"
    return 0
  fi
  if [[ "${GROKHUNTER_TUI:-}" == "whiptail" ]]; then
    printf '%s\n' "whiptail"
    return 0
  fi
  local cols
  cols="$(tui_cols)"
  if [[ -t 0 && -t 1 ]] && [[ "${cols}" -ge 48 ]]; then
    printf '%s\n' "whiptail"
  else
    printf '%s\n' "plain"
  fi
}

tui_pause() {
  if [[ -t 0 && -t 1 ]]; then
    echo
    read -r -p "Press Enter" _ || true
  fi
}

tui_confirm() {
  if [[ "$(tui_skin)" == "whiptail" ]]; then
    whiptail --yesno "This may use the network or write lab files." 8 60
    return $?
  fi
  echo "This may use the network or write lab files."
  local a=""
  read -r -p "Continue? [y/N] " a || return 1
  case "${a}" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

tui_run() {
  "$@" || true
  tui_pause
}

tui_run_doctor() {
  if [[ -t 0 && -t 1 ]] && command -v less >/dev/null 2>&1; then
    _gh doctor | less -R || true
  else
    _gh doctor || true
  fi
  tui_pause
}

tui_launch_grok() {
  if command -v grok-nethunter >/dev/null 2>&1; then
    grok-nethunter || true
  elif [[ -x "${GROKHUNTER_HOME}/bin/grok-nethunter" ]]; then
    "${GROKHUNTER_HOME}/bin/grok-nethunter" || true
  elif command -v grok >/dev/null 2>&1; then
    grok --fullscreen || true
  else
    echo "grok-nethunter not found — try: grokhunter ensure" >&2
  fi
  tui_pause
}

tui_whiptail_choice() {
  local title="$1" text="$2"
  shift 2
  local choice=""
  choice="$(whiptail --title "${title}" --menu "${text}" 22 70 10 "$@" 3>&1 1>&2 2>&3)" || return 1
  printf '%s\n' "${choice}"
}

tui_plain_choice() {
  local title="$1"
  shift
  local line
  [[ -z "${title}" ]] || printf '%s\n' "${title}"
  for line in "$@"; do
    printf '%s\n' "${line}"
  done
  local a=""
  read -r -p "> " a || return 1
  printf '%s\n' "${a}"
}

tui_home_choice() {
  local st chips
  st="$(tui_status)"
  tui_parse_chips "${st}"
  chips="$(tui_fit_chips "$(tui_cols)" "${TUI_CHIPS[@]}")"
  if [[ "$(tui_skin)" == "whiptail" ]]; then
    tui_whiptail_choice "GrokHunter dashboard" "${chips}" \
      1 "Launch Grok" \
      2 "Doctor (may probe x.ai)" \
      3 "Setup" \
      4 "Skills" \
      5 "Models" \
      6 "Binds" \
      7 "Git identity" \
      8 "Credits" \
      q "Quit"
    return
  fi
  printf '%s\n' "GrokHunter dashboard"
  printf '%s' "${chips}"
  tui_plain_choice "" \
    "1) Launch Grok" \
    "2) Doctor (may probe x.ai)" \
    "3) Setup" \
    "4) Skills" \
    "5) Models" \
    "6) Binds" \
    "7) Git identity" \
    "8) Credits" \
    "q) Quit"
}

tui_sub_choice() {
  local title="$1" status_label="$2" repair_label="$3"
  if [[ "$(tui_skin)" == "whiptail" ]]; then
    tui_whiptail_choice "${title}" "" \
      1 "${status_label}" \
      2 "${repair_label}" \
      3 "Back"
    return
  fi
  tui_plain_choice "${title}" \
    "1) ${status_label}" \
    "2) ${repair_label}" \
    "3) Back"
}

tui_skills_menu() {
  local c
  while true; do
    c="$(tui_sub_choice "Skills" "Status" "Install")" || return 0
    case "${c}" in
      1) tui_run _gh skills status ;;
      2) tui_confirm && tui_run _gh skills install ;;
      3|q|Q|"") return 0 ;;
    esac
  done
}

tui_models_menu() {
  local c
  while true; do
    c="$(tui_sub_choice "Models" "Status" "Install")" || return 0
    case "${c}" in
      1) tui_run _gh models status ;;
      2) tui_confirm && tui_run _gh models install ;;
      3|q|Q|"") return 0 ;;
    esac
  done
}

tui_binds_menu() {
  local c
  while true; do
    c="$(tui_sub_choice "Binds" "Status" "Repair")" || return 0
    case "${c}" in
      1) tui_run _gh binds status ;;
      2) tui_confirm && tui_run _gh binds repair ;;
      3|q|Q|"") return 0 ;;
    esac
  done
}

tui_git_menu() {
  local c
  while true; do
    c="$(tui_sub_choice "Git identity" "Show" "Set")" || return 0
    case "${c}" in
      1) tui_run _gh git-identity ;;
      2) tui_confirm && tui_run _gh git-identity set ;;
      3|q|Q|"") return 0 ;;
    esac
  done
}

tui_home_loop() {
  local c
  while true; do
    c="$(tui_home_choice)" || c=q
    case "${c}" in
      1) tui_launch_grok ;;
      2) tui_run_doctor ;;
      3) tui_confirm && tui_run _gh setup --yes ;;
      4) tui_skills_menu ;;
      5) tui_models_menu ;;
      6) tui_binds_menu ;;
      7) tui_git_menu ;;
      8) tui_run _gh credits ;;
      q|Q|"") break ;;
    esac
  done
  exit 0
}

tui_main() {
  case "${1:-}" in
    -h|--help)
      tui_help
      exit 0
      ;;
    --dump)
      tui_dump
      exit 0
      ;;
    --map)
      tui_map
      exit 0
      ;;
  esac
  if [[ ! -t 0 || ! -t 1 ]]; then
    tui_dump
    printf '%s\n' "not a TTY. Re-run in a terminal"
    exit 0
  fi
  tui_home_loop
}

tui_main "$@"
```

Notes for the implementer:

- `tui_confirm && tui_run` is intentional: a “no” skips the action and returns to the menu (`set -e` does not abort on a failed `&&` left-hand side in this form).
- `git-identity set` has no `--name` / `--email`. If the CLI cannot resolve, its own stderr hint is enough.
- `tui_launch_grok` must never `exec`.
- Menu keys `q` / empty / whiptail Cancel: Home → Quit; submenu → Back.

- [ ] **Step 4: Run tests — expect PASS**

Run: `bash scripts/ci-unit.sh`

Expected: PASS, including `tui hub text surfaces OK`. If a chip row is `>40` under `COLUMNS=40`, drop-from-the-right is wrong — fix `tui_fit_chips`, do not raise the limit. If `--dump` prints the fake token, you sourced `secrets.env` or echoed `XAI_API_KEY`; remove that.

- [ ] **Step 5: Commit**

```bash
git add bin/grokhunter-tui scripts/ci-unit.sh
git commit -m "$(cat <<'EOF'
feat(tui): add lab dashboard hub (chips, map, keyboard loop)

EOF
)"
```

---

### Task 4: Install, uninstall, shortcuts, completions, profile

**Files:**
- Modify: `lib/grok.sh` `install_cli_bins` (~126–149) and `install_cli_shortcuts` pairs (~198–208)
- Modify: `uninstall.sh` `remove_bins` (~44–62)
- Modify: `config/completions/bash/grokhunter.bash` (`cmds` ~10, `case` ~24)
- Modify: `config/completions/zsh/_grokhunter` (`commands` array ~9–58, `args` case ~143)
- Modify: `config/profile.d/grokhunter.sh` (zsh aliases ~53–61, bash aliases ~76–84)
- Modify: `scripts/ci-unit.sh` (uninstall regex ~1044–1063)
- Test: `scripts/ci-unit.sh`

**Interfaces:**
- Consumes: `bin/grokhunter-tui` from Task 3; dispatcher from Task 2
- Produces: `~/.local/bin/grokhunter-tui`, PREFIX copy, `ghtui` → `grokhunter tui`, completions for `tui` + `--help --dump --map`, profile alias `ghtui`

- [ ] **Step 1: Write the failing install/uninstall/completion tests**

Replace the uninstall shortcut grep:

```bash
grep -qE 'ghsu ght ghd ghs ghp ghm ghk ghai ghn' uninstall.sh \
  || die "uninstall.sh remove_bins must list shortcut bins"
```

with:

```bash
grep -qE 'ghsu ght ghd ghs ghp ghm ghk ghai ghn' uninstall.sh \
  || die "uninstall.sh remove_bins must list shortcut bins"
grep -q 'ghtui' uninstall.sh || die "uninstall.sh must remove ghtui"
grep -q 'grokhunter-tui' uninstall.sh || die "uninstall.sh must remove grokhunter-tui"
grep -q 'ghtui:tui' lib/grok.sh || die "install_cli_shortcuts must add ghtui:tui"
grep -q 'grokhunter-tui' lib/grok.sh || die "install_cli_bins must copy grokhunter-tui"
if grep -qE 'alias gh=' config/profile.d/grokhunter.sh; then
  die "profile must not alias gh (GitHub CLI)"
fi
grep -q "alias ghtui='grokhunter tui'" config/profile.d/grokhunter.sh \
  || die "profile must alias ghtui"
# both zsh and bash blocks
[[ "$(grep -c "alias ghtui='grokhunter tui'" config/profile.d/grokhunter.sh)" -ge 2 ]] \
  || die "ghtui alias needed in zsh and bash blocks"
grep -qE 'local cmds=.*\btui\b' config/completions/bash/grokhunter.bash \
  || die "bash completion must include tui"
grep -q -- '--dump' config/completions/bash/grokhunter.bash \
  || die "bash completion must offer tui flags"
grep -qF "tui:Lab dashboard (hub + health + repairs)" config/completions/zsh/_grokhunter \
  || die "zsh completion missing tui description"
```

Keep the existing `alias gh=` die (do not duplicate if you merged it).

In the isolated uninstall `for b in ...` loop (~1060), add `ghtui` and `grokhunter-tui`:

```bash
  for b in grokhunter grokhunter-tui ghsu ght ghd ghs ghp ghm ghk ghai ghn ghtui; do
```

After creating those fake bins, also create PREFIX copies so PREFIX removal is exercised:

```bash
  PREFIX="$HOME/prefix"
  mkdir -p "$PREFIX/bin"
  export PREFIX
  printf "#!/bin/sh\n" > "$PREFIX/bin/grokhunter-tui"
  chmod +x "$PREFIX/bin/grokhunter-tui"
```

After `PATH="$fake:$PATH" bash "$ROOT/uninstall.sh" >/dev/null`, add:

```bash
  [[ ! -f "$HOME/.local/bin/ghtui" ]]
  [[ ! -f "$HOME/.local/bin/grokhunter-tui" ]]
  [[ ! -f "$PREFIX/bin/grokhunter-tui" ]]
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `bash scripts/ci-unit.sh`

Expected: FAIL with `install_cli_shortcuts must add ghtui:tui` (or the first new grep that is missing).

- [ ] **Step 3: Wire install / uninstall / completions / profile**

`lib/grok.sh` `install_cli_bins` — add `grokhunter-tui` to both loops:

```bash
  for name in grokhunter grokhunter-doctor grokhunter-tui grok-nethunter aider-grok nh-x11; do
```

```bash
    for name in grokhunter grokhunter-doctor grokhunter-tui grok-nethunter; do
```

`install_cli_shortcuts` pairs — add (do not add `gh`):

```bash
    "ghtui:tui"
```

`uninstall.sh` `remove_bins`:

```bash
  for b in grokhunter grok-nethunter grokhunter-doctor grokhunter-tui aider-grok nh-x11 \
           ghsu ght ghd ghs ghp ghm ghk ghai ghn ghtui; do
```

```bash
    for b in grokhunter grok-nethunter grokhunter-doctor grokhunter-tui; do
```

Bash completion `cmds` — insert `tui` after `status`:

```bash
  local cmds="status tui doctor binds proot-binds setup sync boot ensure models skills agents team coding-team scout benjamin lucas harper review fix desktop overlay ship docs modeler ci aider session host mcp plugin flow storage editor hook shell github secrets toolchain tls net menu git-identity credits ai-smoke smoke install plan help version"
```

In the `case "${COMP_WORDS[1]}"` block add:

```bash
    tui|ghtui)
      COMPREPLY=( $(compgen -W "--help --dump --map" -- "${cur}") )
      ;;
```

Zsh `commands=(` — add this entry (spec string, exact):

```zsh
    'tui:Lab dashboard (hub + health + repairs)'
```

Zsh `args` case, next to `ensure)`:

```zsh
        tui)
          _arguments \
            '--help[Show help]' \
            '--dump[Print chips and menu labels]' \
            '--map[Print action map]'
          ;;
```

`config/profile.d/grokhunter.sh` zsh block, with the other aliases:

```bash
  (( ${+aliases[ghtui]} )) || alias ghtui='grokhunter tui'
```

Bash block:

```bash
  alias ghtui='grokhunter tui' 2>/dev/null || true
```

Still no `alias gh=`.

- [ ] **Step 4: Run tests — expect PASS**

Run: `bash scripts/ci-unit.sh`

Expected: PASS (`uninstall shortcuts + no gh alias OK` and the new greps).

- [ ] **Step 5: Commit**

```bash
git add lib/grok.sh uninstall.sh \
  config/completions/bash/grokhunter.bash \
  config/completions/zsh/_grokhunter \
  config/profile.d/grokhunter.sh \
  scripts/ci-unit.sh
git commit -m "$(cat <<'EOF'
feat(tui): install ghtui shortcut, completions, and uninstall

EOF
)"
```

---

### Task 5: desktop-run comment + docs + CHANGELOG

**Files:**
- Modify: `bin/grokhunter-desktop-run` `grok|tui)` (~40)
- Modify: `README.md` After install (~107–108)
- Modify: `docs/FAQ.md` (new section after “What is the default AI agent?”)
- Modify: `docs/SHELL.md` alias table (~56–68)
- Modify: `skills/grokhunter/SKILL.md` (facts, CLI map, aliases, decision tree)
- Modify: `CHANGELOG.md` Unreleased
- Modify: `scripts/ci-unit.sh` (desktop-run / `main ""` identity greps)
- Test: `scripts/ci-unit.sh`

**Interfaces:**
- Consumes: shipped hub + dispatcher
- Produces: comments/docs that stop people from “fixing” desktop-run or bare `grokhunter` to the dashboard

- [ ] **Step 1: Write the failing identity tests**

Add after the hub text-surface `info` line (or at the end of the tui tests):

```bash
# desktop-run grok|tui) is Grok Build, not the lab dashboard
_dr="$(awk '/grok\|tui\)/,/;;/' bin/grokhunter-desktop-run)"
echo "${_dr}" | grep -q grok-nethunter || die "desktop-run grok|tui must launch grok-nethunter"
echo "${_dr}" | grep -q grokhunter-tui && die "desktop-run grok|tui must not exec grokhunter-tui"
grep -q 'not the lab dashboard' bin/grokhunter-desktop-run \
  || die "desktop-run grok|tui needs a comment: Grok Build, not the lab dashboard"
# bare grokhunter still launches Grok
awk '/^main\(\)/,/^}/' bin/grokhunter | grep -A6 '""' | grep -q '_grok_launcher' \
  || die 'main "" must still call _grok_launcher'
info "tui vs grok identity OK"
```

- [ ] **Step 2: Run tests — expect FAIL**

Run: `bash scripts/ci-unit.sh`

Expected: FAIL with `desktop-run grok|tui needs a comment`.

- [ ] **Step 3: Comment + docs**

`bin/grokhunter-desktop-run` — do not change the arm body:

```bash
  grok|tui)
    # Grok Build fullscreen — not the lab dashboard (`grokhunter tui` / ghtui).
    if command -v grok-nethunter >/dev/null 2>&1; then
      exec grok-nethunter "$@"
    fi
    exec grok --fullscreen "$@"
    ;;
```

`README.md` After install, immediately after `grokhunter             # Primary CLI / TUI`, add:

```bash
grokhunter tui         # Lab dashboard (alias ghtui). Bare grokhunter is Grok Build.
```

Optionally reword the `grokhunter` comment to `Grok Build fullscreen` so it does not collide with “TUI” meaning the dashboard.

`docs/FAQ.md` — new section after **What is the default AI agent?**:

```markdown
## How do I open the lab dashboard vs Grok Build?

They are three different surfaces:

| Command | What it is |
|---------|------------|
| `grokhunter` / `grok` | Grok Build fullscreen (via `grok-nethunter`) |
| `grokhunter tui` / `ghtui` | Lab dashboard: status chips + doctor/setup/skills/models/binds/git-identity |
| `grokhunter menu` | XFCE Applications → GrokHunter submenu |

The Grok TUI status line (`~/.grok/statusline.sh`) is separate; see “How do I get a lab status line in the Grok TUI?”.
```

`docs/SHELL.md` alias table — add:

```markdown
| `ghtui` | `grokhunter tui` |
```

`skills/grokhunter/SKILL.md`:

- Facts table Launch row: keep `grokhunter` / `grok` as Grok Build; add `| Lab dashboard | `grokhunter tui` / alias `ghtui` |`
- CLI map first lines:

```text
grokhunter                     # Grok Build fullscreen (via grok-nethunter)
grokhunter tui                 # lab dashboard (alias ghtui)
```

- Aliases table: `| \`ghtui\` | \`tui\` |`
- Decision tree, next to `TUI died / resume?`:

```
Lab dashboard (status + repairs)? → grokhunter tui   # alias ghtui; not Grok Build
```

`CHANGELOG.md` Unreleased — new `### CLI` bullet (keep the existing `### TUI` statusline bullet as-is):

```markdown
### CLI

- `grokhunter tui` (alias `ghtui`): native lab dashboard (whiptail or numbered fallback). Bare `grokhunter` remains Grok Build; `grokhunter menu` remains XFCE.
```

If `### CLI` already exists under Unreleased, append the bullet there instead of duplicating the heading.

Do **not** add a skill, agent, role, persona, or website page.

- [ ] **Step 4: Run the full suite — expect PASS**

Run: `bash scripts/ci-unit.sh`

Expected: `ALL OK`. Also:

```bash
wc -l < bin/grokhunter   # still < 1000
sed -n '/^usage()/,/^}/p' bin/grokhunter | grep '`' && echo FAIL
bash bin/grokhunter tui --dump >/dev/null
bash bin/grokhunter tui --map
bash bin/grokhunter tui --help
```

- [ ] **Step 5: Commit**

```bash
git add bin/grokhunter-desktop-run README.md docs/FAQ.md docs/SHELL.md \
  skills/grokhunter/SKILL.md CHANGELOG.md scripts/ci-unit.sh
git commit -m "$(cat <<'EOF'
docs(tui): distinguish lab dashboard from Grok Build

EOF
)"
```

---

## Spec coverage (self-review)

| Spec item | Task |
|-----------|------|
| `grokhunter tui` / `ghtui` entry | 2, 4 |
| Bare `grokhunter` = Grok Build | 2, 5 |
| `grokhunter menu` = XFCE, untouched | 2 (help), 5 (FAQ) |
| Approach A: whiptail + numbered `read` | 3 |
| Launch Grok child, pause, Home | 3 (`tui_launch_grok`, no `exec`) |
| v1 action table + submenus + confirm copy | 3 |
| Non-TTY dump + note, exit 0 | 3 |
| Secrets: chip only; fake token test | 3 |
| Dispatcher `exec` + missing file exit 1 | 1–2 |
| `bin/grokhunter` < 1000; no usage backticks | 2 |
| `--help` / `--dump` / `--map` + id/argv rows | 3 |
| Chips from `grokhunter status`; drop from right; 2 rows; `COLUMNS=0`→40 | 3 |
| `GROKHUNTER_TUI=whiptail\|plain` | 3 |
| Doctor pager `less -R` only | 3 |
| No `binds optimize`, no `ai-smoke`, no apt/pkg/pip, no python3, no eval | 3 |
| Completions `tui` + flags | 4 |
| `ghtui:tui` shortcut, PREFIX copy, uninstall | 4 |
| Profile alias `ghtui`; no `gh` | 4 |
| desktop-run comment; `main ""` still `_grok_launcher` | 5 |
| README / FAQ / SHELL / skill / CHANGELOG | 5 |
| No new skill/agent | 5 (explicit skip) |
| ci-unit only; no expect / live TTY | all |

No remaining spec items without a task.

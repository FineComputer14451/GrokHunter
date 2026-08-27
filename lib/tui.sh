#!/usr/bin/env bash
# GrokHunter lab TUI — thin menu over existing CLI.
# Not Grok Build. Bare `grokhunter` still launches grok-nethunter.
# Picker fallback: whiptail → dialog → fzf → numbered printf + read.

# shellcheck disable=SC2034

_gh_tui_self() {
  if [[ -n "${GH_TUI_SELF:-}" && -e "${GH_TUI_SELF}" ]]; then
    printf '%s\n' "${GH_TUI_SELF}"
    return 0
  fi
  if [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/bin/grokhunter" ]]; then
    printf '%s\n' "${GROKHUNTER_HOME}/bin/grokhunter"
    return 0
  fi
  printf '%s\n' "grokhunter"
}

_gh_tui_is_tty() {
  [[ -t 0 && -t 1 ]]
}

_gh_tui_usage() {
  cat <<'EOF'
GrokHunter lab TUI

Usage:
  grokhunter tui              Lab operations menu
  grokhunter lab              Alias for tui
  grokhunter tui help         This help

This is the lab menu (status / doctor / setup / skills / …).
It is not Grok Build. Bare `grokhunter` still opens the Grok TUI.
`grokhunter menu` is the XFCE Applications submenu, not this screen.

Needs a tty. Non-interactive:
  grokhunter status
  grokhunter doctor
  grokhunter help

Picker: whiptail → dialog → fzf → numbered prompt.
Never prints XAI_API_KEY or secrets.env contents.
EOF
}

_gh_tui_picker_name() {
  if command -v whiptail >/dev/null 2>&1; then
    printf '%s\n' "whiptail"
    return 0
  fi
  if command -v dialog >/dev/null 2>&1; then
    printf '%s\n' "dialog"
    return 0
  fi
  if command -v fzf >/dev/null 2>&1; then
    printf '%s\n' "fzf"
    return 0
  fi
  printf '%s\n' "numbered"
}

_gh_tui_main_items() {
  cat <<'EOF'
1|status
2|doctor
3|setup
4|skills
5|models
6|binds
7|git-identity
8|XFCE menu
9|credits
a|agents
0|Grok TUI
q|quit
EOF
}

_gh_tui_agent_items() {
  cat <<'EOF'
t|team
s|scout
r|review
f|fix
d|desktop
b|back
q|quit
EOF
}

_gh_tui_skills_items() {
  cat <<'EOF'
s|status
i|install
b|back
EOF
}

_gh_tui_models_items() {
  cat <<'EOF'
s|status
i|install
b|back
EOF
}

_gh_tui_binds_items() {
  cat <<'EOF'
s|status
r|repair
b|back
EOF
}

_gh_tui_ident_items() {
  cat <<'EOF'
s|show
t|set
b|back
EOF
}

_gh_tui_xfce_items() {
  cat <<'EOF'
i|install
r|remove
b|back
EOF
}

_gh_tui_pause() {
  local _ans
  if ! _gh_tui_is_tty; then
    return 0
  fi
  printf '\n[lab] Enter to continue · q quit: '
  if ! IFS= read -r _ans; then
    return 2
  fi
  case "${_ans}" in
    q|Q|quit|QUIT) return 99 ;;
  esac
  return 0
}

_gh_tui_confirm() {
  local prompt="${1:-Proceed?}"
  local _ans
  if ! _gh_tui_is_tty; then
    return 1
  fi
  printf '%s [y/N]: ' "${prompt}"
  if ! IFS= read -r _ans; then
    return 1
  fi
  case "${_ans}" in
    y|Y|yes|YES) return 0 ;;
  esac
  return 1
}

# Menu chrome goes to stderr. Selected key is printed on stdout.
# Returns 2 on EOF / cancel.
_gh_tui_pick() {
  local title="$1"
  local items_fn="$2"
  local picker key label
  local -a tags=() labels=()
  picker="$(_gh_tui_picker_name)"

  local item_blob
  item_blob="$("${items_fn}")"
  while IFS='|' read -r key label; do
    [[ -n "${key}" ]] || continue
    tags+=("${key}")
    labels+=("${label}")
  done <<< "${item_blob}"

  case "${picker}" in
    whiptail)
      local -a args=()
      local i
      for i in "${!tags[@]}"; do
        args+=("${tags[$i]}" "${labels[$i]}")
      done
      key="$(whiptail --title "GrokHunter lab" --menu "${title}" 20 60 12 "${args[@]}" 3>&1 1>&2 2>&3)" || return 2
      printf '%s\n' "${key}"
      return 0
      ;;
    dialog)
      local -a args=()
      local i
      for i in "${!tags[@]}"; do
        args+=("${tags[$i]}" "${labels[$i]}")
      done
      key="$(dialog --title "GrokHunter lab" --menu "${title}" 20 60 12 "${args[@]}" 3>&1 1>&2 2>&3)" || return 2
      printf '%s\n' "${key}"
      return 0
      ;;
    fzf)
      local choice
      choice="$("${items_fn}" | sed 's/|/  /' | fzf --prompt="lab> " --height=16 --reverse)" || return 2
      key="${choice%%  *}"
      key="${key%% *}"
      printf '%s\n' "${key}"
      return 0
      ;;
  esac

  echo >&2
  echo "GrokHunter lab  v${VERSION:-?}  picker=${picker}" >&2
  echo "${title}" >&2
  echo >&2
  while IFS='|' read -r key label; do
    [[ -n "${key}" ]] || continue
    printf '  %s  %s\n' "${key}" "${label}" >&2
  done <<< "${item_blob}"
  echo >&2
  printf '> ' >&2
  if ! IFS= read -r key; then
    return 2
  fi
  key="${key#"${key%%[![:space:]]*}"}"
  key="${key%"${key##*[![:space:]]}"}"
  [[ -n "${key}" ]] || return 2
  printf '%s\n' "${key}"
}

_gh_tui_run_cli() {
  local self rc
  self="$(_gh_tui_self)"
  echo
  set +e
  bash "${self}" "$@"
  rc=$?
  set -e
  echo
  echo "[lab] exit ${rc}"
  return 0
}

_gh_tui_open_grok() {
  local self launcher
  self="$(_gh_tui_self)"
  echo
  echo "[lab] opening Grok Build TUI…"
  if declare -F _grok_launcher >/dev/null 2>&1; then
    launcher="$(_grok_launcher)"
    exec "${launcher}"
  fi
  exec bash "${self}"
}

_gh_tui_open_grok_agent() {
  local agent="$1"
  local self
  self="$(_gh_tui_self)"
  echo
  echo "[lab] launching agent ${agent}…"
  exec bash "${self}" "${agent}"
}

cmd_tui() {
  local sub="${1:-}"
  case "${sub}" in
    help|-h|--help)
      _gh_tui_usage
      return 0
      ;;
  esac

  if [[ "${NON_INTERACTIVE:-0}" == "1" || -n "${CI:-}" ]]; then
    echo "grokhunter tui needs a tty (NON_INTERACTIVE/CI set)." >&2
    _gh_tui_usage >&2
    return 2
  fi
  if ! _gh_tui_is_tty; then
    echo "grokhunter tui needs a tty." >&2
    _gh_tui_usage >&2
    return 2
  fi

  trap 'echo; echo "[lab] interrupted"; exit 130' INT

  local key pause_rc
  while true; do
    key="$(_gh_tui_pick "Lab operations" _gh_tui_main_items)" || {
      echo
      echo "[lab] bye"
      return 0
    }
    case "${key}" in
      q|Q|quit)
        echo "[lab] bye"
        return 0
        ;;
      1|status)
        _gh_tui_run_cli status
        ;;
      2|doctor)
        _gh_tui_run_cli doctor
        ;;
      3|setup)
        if _gh_tui_confirm "Run grokhunter setup?"; then
          _gh_tui_run_cli setup
        else
          echo "[lab] skipped setup"
        fi
        ;;
      4|skills)
        key="$(_gh_tui_pick "skills" _gh_tui_skills_items)" || continue
        case "${key}" in
          i|I|install)
            if _gh_tui_confirm "Install skills + agents + personas + roles?"; then
              _gh_tui_run_cli skills install
            else
              echo "[lab] skipped skills install"
            fi
            ;;
          q|Q|quit) echo "[lab] bye"; return 0 ;;
          b|B|back) continue ;;
          *) _gh_tui_run_cli skills status ;;
        esac
        ;;
      5|models)
        key="$(_gh_tui_pick "models" _gh_tui_models_items)" || continue
        case "${key}" in
          i|I|install)
            if _gh_tui_confirm "Install V9 / 4.6 model pickers?"; then
              _gh_tui_run_cli models install
            else
              echo "[lab] skipped models install"
            fi
            ;;
          q|Q|quit) echo "[lab] bye"; return 0 ;;
          b|B|back) continue ;;
          *) _gh_tui_run_cli models status ;;
        esac
        ;;
      6|binds)
        key="$(_gh_tui_pick "binds" _gh_tui_binds_items)" || continue
        case "${key}" in
          r|R|repair)
            if _gh_tui_confirm "Repair proot binds?"; then
              _gh_tui_run_cli binds repair
            else
              echo "[lab] skipped binds repair"
            fi
            ;;
          q|Q|quit) echo "[lab] bye"; return 0 ;;
          b|B|back) continue ;;
          *) _gh_tui_run_cli binds status ;;
        esac
        ;;
      7|git-identity|identity)
        key="$(_gh_tui_pick "git-identity" _gh_tui_ident_items)" || continue
        case "${key}" in
          t|T|set)
            if _gh_tui_confirm "Set git identity from gh / token / origin?"; then
              _gh_tui_run_cli git-identity set
            else
              echo "[lab] skipped git-identity set"
            fi
            ;;
          q|Q|quit) echo "[lab] bye"; return 0 ;;
          b|B|back) continue ;;
          *) _gh_tui_run_cli git-identity show ;;
        esac
        ;;
      8|menu|xfce)
        key="$(_gh_tui_pick "XFCE menu (not this TUI)" _gh_tui_xfce_items)" || continue
        case "${key}" in
          i|I|install)
            if _gh_tui_confirm "Install Applications → GrokHunter submenu?"; then
              _gh_tui_run_cli menu install
            else
              echo "[lab] skipped menu install"
            fi
            ;;
          r|R|remove)
            if _gh_tui_confirm "Remove XFCE GrokHunter menu entries?"; then
              _gh_tui_run_cli menu remove
            else
              echo "[lab] skipped menu remove"
            fi
            ;;
          q|Q|quit) echo "[lab] bye"; return 0 ;;
          *) continue ;;
        esac
        ;;
      9|credits)
        _gh_tui_run_cli credits
        ;;
      a|A|agents)
        key="$(_gh_tui_pick "agents (opens Grok TUI if no prompt)" _gh_tui_agent_items)" || continue
        case "${key}" in
          t|T|team) _gh_tui_open_grok_agent coding-team ;;
          s|S|scout) _gh_tui_open_grok_agent scout ;;
          r|R|review) _gh_tui_open_grok_agent review ;;
          f|F|fix) _gh_tui_open_grok_agent fix ;;
          d|D|desktop) _gh_tui_open_grok_agent desktop ;;
          q|Q|quit) echo "[lab] bye"; return 0 ;;
          *) continue ;;
        esac
        ;;
      0|grok|tui-grok)
        _gh_tui_open_grok
        ;;
      *)
        echo "[lab] unknown: ${key}"
        ;;
    esac
    pause_rc=0
    _gh_tui_pause || pause_rc=$?
    if [[ "${pause_rc}" -eq 99 ]]; then
      echo "[lab] bye"
      return 0
    fi
    if [[ "${pause_rc}" -eq 2 ]]; then
      echo "[lab] bye"
      return 0
    fi
  done
}

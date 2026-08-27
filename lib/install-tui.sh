#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter first-run installer TUI (Termux host).
# Builds argv only. Confirm execs install.sh with flags. Never prints secrets.

install_tui_defaults() {
  INSTALL_TUI_PRESET=coding
  INSTALL_TUI_GROK=yes
  INSTALL_TUI_COMPLETIONS=yes
  INSTALL_TUI_AIDER=no
  INSTALL_TUI_V9=no
}

install_tui_set_preset() {
  case "${1:-}" in
    coding|desktop) INSTALL_TUI_PRESET="$1" ;;
    *) return 1 ;;
  esac
}

install_tui_toggle() {
  local var
  case "${1:-}" in
    grok) var=INSTALL_TUI_GROK ;;
    completions) var=INSTALL_TUI_COMPLETIONS ;;
    aider) var=INSTALL_TUI_AIDER ;;
    v9) var=INSTALL_TUI_V9 ;;
    *) return 1 ;;
  esac
  if [[ "${!var}" == yes ]]; then
    printf -v "$var" '%s' no
  else
    printf -v "$var" '%s' yes
  fi
}

install_tui_argv() {
  local g c
  local -a args=()
  if [[ "${INSTALL_TUI_GROK:-yes}" == yes ]]; then
    g=--with-grok
  else
    g=--no-grok
  fi
  if [[ "${INSTALL_TUI_COMPLETIONS:-yes}" == yes ]]; then
    c=--with-completions
  else
    c=--no-completions
  fi
  if [[ "${INSTALL_TUI_PRESET:-coding}" == desktop ]]; then
    args=(--full --de xfce --browser chromium --with-x11 "$g" "$c")
  else
    args=(--nano --no-de "$g" "$c")
  fi
  [[ "${INSTALL_TUI_AIDER:-no}" == yes ]] && args+=(--with-aider)
  [[ "${INSTALL_TUI_V9:-no}" == yes ]] && args+=(--with-v9-models)
  printf '%s\n' "${args[*]}"
}

install_tui_should_run() {
  [[ ${NON_INTERACTIVE:-0} -eq 1 ]] && return 1
  [[ ${OVERLAY_ONLY:-0} -eq 1 ]] && return 1
  [[ "${GROKHUNTER_INSTALL_TUI:-1}" == "0" ]] && return 1
  [[ "${GROKHUNTER_INSTALL_TUI_RAN:-0}" == "1" ]] && return 1
  return 0
}

install_tui_dump() {
  install_tui_argv
}

install_tui_help() {
  cat <<'EOF'
GrokHunter first-run installer TUI (Termux)

  bash install.sh          TTY wizard; default coding-only nano
  bash install.sh --yes    Same default, no wizard
  Flags skip the wizard. Overlay-only is unchanged.

  GROKHUNTER_INSTALL_TUI=0    Old choose/ask prompts
EOF
}

_install_tui_die() {
  if declare -F die >/dev/null 2>&1; then
    die "$@"
  fi
  echo "[GrokHunter] ERROR: $*" >&2
  exit 1
}

install_tui_home() {
  local lab item2
  if [[ "${INSTALL_TUI_PRESET}" == desktop ]]; then
    lab="desktop (full, Xfce, Chromium, X11)"
    item2="Switch to coding-only (nano, no desktop)"
  else
    lab="coding-only (nano, no desktop)"
    item2="Switch to desktop lab (full + Xfce + X11)"
  fi
  cat <<EOF

GrokHunter install

  Lab:          ${lab}
  Grok:         ${INSTALL_TUI_GROK}
  Completions:  ${INSTALL_TUI_COMPLETIONS}
  Aider:        ${INSTALL_TUI_AIDER}
  V9 pickers:   ${INSTALL_TUI_V9}

  1) Install
  2) ${item2}
  3) Toggle Grok
  4) Toggle completions
  5) Toggle Aider
  6) Toggle V9 pickers
  7) Show command
  8) Quit
EOF
}

install_tui_show_cmd() {
  local cmd="bash install.sh $(install_tui_argv)"
  [[ -n "${OVERLAY_ROOT:-}" ]] && cmd="bash ${OVERLAY_ROOT}/install.sh $(install_tui_argv)"
  echo
  echo "  ${cmd}"
  echo
  printf 'Press Enter to return. '
  IFS= read -r _ || true
}

install_tui_confirm() {
  local argv root avail need
  local -a args=()
  argv="$(install_tui_argv)"
  root="${OVERLAY_ROOT:-}"
  [[ -n "${root}" && -f "${root}/install.sh" ]] || _install_tui_die "OVERLAY_ROOT missing; cannot exec installer"
  need=2
  [[ "${INSTALL_TUI_PRESET}" == desktop ]] && need=6
  cat <<EOF

About to run:
  bash ${root}/install.sh ${argv}

Downloads a Kali NetHunter rootfs. nano needs ~2G free, full ~6G+.
This can take a long time. Keep Termux open (wake-lock is already held).
EOF
  if declare -F _gh_df_avail_gb >/dev/null 2>&1; then
    avail="$(_gh_df_avail_gb "${TERMUX_FILES_DIR:-${HOME}}" || true)"
    if [[ "${avail}" =~ ^[0-9]+$ ]] && (( avail < need )); then
      echo
      echo "WARN: ${avail}GB free (need ~${need}G+). Confirm anyway to continue."
    fi
  fi
  cat <<'EOF'

  1) Confirm
  2) Back
  3) Quit
EOF
  local choice
  printf 'Select: '
  IFS= read -r choice || exit 0
  case "${choice}" in
    1)
      export GROKHUNTER_INSTALL_TUI_RAN=1
      read -r -a args <<< "${argv}"
      exec bash "${root}/install.sh" "${args[@]}"
      ;;
    3|q|Q) exit 0 ;;
    *) return 0 ;;
  esac
}

install_tui_main() {
  install_tui_defaults
  local choice
  while true; do
    install_tui_home
    printf 'Select: '
    IFS= read -r choice || exit 0
    case "${choice}" in
      1) install_tui_confirm ;;
      2)
        if [[ "${INSTALL_TUI_PRESET}" == desktop ]]; then
          install_tui_set_preset coding
        else
          install_tui_set_preset desktop
        fi
        ;;
      3) install_tui_toggle grok ;;
      4) install_tui_toggle completions ;;
      5) install_tui_toggle aider ;;
      6) install_tui_toggle v9 ;;
      7) install_tui_show_cmd ;;
      8|q|Q) exit 0 ;;
    esac
  done
}

install_tui_defaults

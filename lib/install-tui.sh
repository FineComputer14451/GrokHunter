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

install_tui_defaults

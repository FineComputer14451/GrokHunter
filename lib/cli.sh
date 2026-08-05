#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter CLI parsing & help
# shellcheck disable=SC2034

NON_INTERACTIVE=0
SELECTED_INSTALLATION=""
SELECTED_DE=""
SELECTED_BROWSER=""
SKIP_DE=0
INSTALL_GROK=0
SKIP_GROK=0
INSTALL_X11=0
SKIP_X11=0
INSTALL_AIDER=0
SKIP_AIDER=0
INSTALL_V9=0
SKIP_V9=0

show_help() {
  local ec="${1:-0}"
  cat <<'HELP'
GrokHunter Rootless (coding lab) for Termux

Usage: install.sh [OPTIONS]

Options:
  -f, --full              Full installation (includes desktop environment)
  -m, --mini              Mini installation (essential packages only)
  -n, --nano              Nano installation (minimal footprint)
  --de <desktop>          Desktop environment (e17|gnome|i3|kde|lxde|mate|xfce)
  --browser <browser>     Browser: chromium | firefox | both
  --no-de                 Skip desktop environment installation completely
  --with-grok             Also install native Grok Build CLI (Termux aarch64)
  --no-grok               Skip Grok Build installation
  --with-x11              Install & configure Termux:X11 (low-latency desktop)
  --no-x11                Skip Termux:X11 setup
  --with-aider            Install Aider pair-programmer (venv + xAI-ready)
  --no-aider              Skip Aider installation
  --with-v9-models        Install Grok V9 / 4.5 model pickers into config.toml
  --no-v9-models          Skip V9 model pickers
  -h, --help              Show this help and exit

Examples:
  install.sh --full --de xfce --with-grok --with-x11 --with-aider
  install.sh -m
  install.sh --nano --no-de --with-grok

Grok Build:  https://x.ai/cli
Termux:X11:  https://github.com/termux/termux-x11
Aider:       https://aider.chat
Repo:        https://github.com/FineComputer14451/GrokHunter
HELP
  exit "${ec}"
}

parse_cli() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--full)     SELECTED_INSTALLATION=full; NON_INTERACTIVE=1; shift ;;
      -m|--mini)     SELECTED_INSTALLATION=mini; NON_INTERACTIVE=1; shift ;;
      -n|--nano)     SELECTED_INSTALLATION=nano; NON_INTERACTIVE=1; shift ;;
      --de)
        if [[ $# -lt 2 || "$2" == -* ]]; then
          echo "Error: --de requires a desktop value (e.g. xfce)" >&2
          show_help 2
        fi
        SELECTED_DE="$2"; NON_INTERACTIVE=1; shift 2 ;;
      --browser)
        if [[ $# -lt 2 || "$2" == -* ]]; then
          echo "Error: --browser requires a value (chromium|firefox|both)" >&2
          show_help 2
        fi
        SELECTED_BROWSER="$2"; NON_INTERACTIVE=1; shift 2 ;;
      --no-de)       SKIP_DE=1; NON_INTERACTIVE=1; shift ;;
      --with-grok)   INSTALL_GROK=1; NON_INTERACTIVE=1; shift ;;
      --no-grok)     SKIP_GROK=1; NON_INTERACTIVE=1; shift ;;
      --with-x11)    INSTALL_X11=1; NON_INTERACTIVE=1; shift ;;
      --no-x11)      SKIP_X11=1; NON_INTERACTIVE=1; shift ;;
      --with-aider)  INSTALL_AIDER=1; NON_INTERACTIVE=1; shift ;;
      --no-aider)    SKIP_AIDER=1; NON_INTERACTIVE=1; shift ;;
      --with-v9-models) INSTALL_V9=1; NON_INTERACTIVE=1; shift ;;
      --no-v9-models)   SKIP_V9=1; NON_INTERACTIVE=1; shift ;;
      -h|--help)     show_help 0 ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        show_help 2
        ;;
    esac
  done
}

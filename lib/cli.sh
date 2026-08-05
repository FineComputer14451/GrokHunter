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

show_help() {
  cat <<EOF
${PROGRAM_NAME:-install.sh} — GrokHunter Rootless (coding lab) for Termux

Usage: ${PROGRAM_NAME:-install.sh} [OPTIONS]

Options:
  -f, --full              Full installation (includes desktop environment)
  -m, --mini              Mini installation (essential packages only)
  -n, --nano              Nano installation (minimal footprint)
  --de <desktop>          Desktop environment (e17|gnome|i3|kde|lxde|mate|xfce)
                          Default: Xfce (recommended for Android)
  --browser <browser>     Browser: chromium | firefox | both
  --no-de                 Skip desktop environment installation completely
  --with-grok             Also install native Grok Build CLI (Termux aarch64)
  --no-grok               Skip Grok Build installation
  --with-x11              Install & configure Termux:X11 (low-latency desktop)
  --no-x11                Skip Termux:X11 setup
  --with-aider            Install Aider pair-programmer (venv + xAI-ready)
  --no-aider              Skip Aider installation
  -h, --help              Show this help and exit

Examples:
  # Full coding lab + Grok + X11 + Aider
  ${PROGRAM_NAME:-install.sh} --full --de xfce --with-grok --with-x11 --with-aider

  # Quick mini install (no prompts)
  ${PROGRAM_NAME:-install.sh} -m

  # Nano + no desktop + Grok Build
  ${PROGRAM_NAME:-install.sh} --nano --no-de --with-grok

Non-interactive mode activates automatically when any option is provided.

Grok Build:  https://x.ai/cli
Termux:X11:  https://github.com/termux/termux-x11
Aider:       https://aider.chat
Repo:        https://github.com/FineComputer14451/GrokHunter
EOF
  exit 0
}

parse_cli() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--full)     SELECTED_INSTALLATION=full; NON_INTERACTIVE=1; shift ;;
      -m|--mini)     SELECTED_INSTALLATION=mini; NON_INTERACTIVE=1; shift ;;
      -n|--nano)     SELECTED_INSTALLATION=nano; NON_INTERACTIVE=1; shift ;;
      --de)          SELECTED_DE="$2"; shift 2 ;;
      --browser)     SELECTED_BROWSER="$2"; shift 2 ;;
      --no-de)       SKIP_DE=1; NON_INTERACTIVE=1; shift ;;
      --with-grok)   INSTALL_GROK=1; NON_INTERACTIVE=1; shift ;;
      --no-grok)     SKIP_GROK=1; NON_INTERACTIVE=1; shift ;;
      --with-x11)    INSTALL_X11=1; NON_INTERACTIVE=1; shift ;;
      --no-x11)      SKIP_X11=1; NON_INTERACTIVE=1; shift ;;
      --with-aider)  INSTALL_AIDER=1; NON_INTERACTIVE=1; shift ;;
      --no-aider)    SKIP_AIDER=1; NON_INTERACTIVE=1; shift ;;
      -h|--help)     show_help ;;
      *) echo "Error: Unknown option '$1'"; show_help ;;
    esac
  done
}

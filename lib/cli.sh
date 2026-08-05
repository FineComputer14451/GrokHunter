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

show_help() {
  cat <<EOF
${PROGRAM_NAME:-install.sh} — Grok Build Powered Kali NetHunter Rootless Installer for Termux

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
  -h, --help              Show this help and exit

Examples:
  # Fully automated full install + XFCE + Chromium + Grok Build + Termux:X11
  ${PROGRAM_NAME:-install.sh} --full --de xfce --browser chromium --with-grok --with-x11

  # Quick mini install (no prompts)
  ${PROGRAM_NAME:-install.sh} -m

  # Nano + no desktop + Grok Build + X11
  ${PROGRAM_NAME:-install.sh} --nano --no-de --with-grok --with-x11

Non-interactive mode activates automatically when any option is provided.
All prompts are skipped where possible; invalid values fall back to safe defaults.

Grok Build docs: https://x.ai/cli
Termux:X11:      https://github.com/termux/termux-x11
NetHunter issues: https://github.com/jorexdeveloper/termux-nethunter/issues
Repo:            https://github.com/FineComputer14451/GrokHunter
EOF
  exit 0
}

parse_cli() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--full)   SELECTED_INSTALLATION=full; NON_INTERACTIVE=1; shift ;;
      -m|--mini)   SELECTED_INSTALLATION=mini; NON_INTERACTIVE=1; shift ;;
      -n|--nano)   SELECTED_INSTALLATION=nano; NON_INTERACTIVE=1; shift ;;
      --de)        SELECTED_DE="$2"; shift 2 ;;
      --browser)   SELECTED_BROWSER="$2"; shift 2 ;;
      --no-de)     SKIP_DE=1; NON_INTERACTIVE=1; shift ;;
      --with-grok) INSTALL_GROK=1; NON_INTERACTIVE=1; shift ;;
      --no-grok)   SKIP_GROK=1; NON_INTERACTIVE=1; shift ;;
      --with-x11)  INSTALL_X11=1; NON_INTERACTIVE=1; shift ;;
      --no-x11)    SKIP_X11=1; NON_INTERACTIVE=1; shift ;;
      -h|--help)   show_help ;;
      *) echo "Error: Unknown option '$1'"; show_help ;;
    esac
  done
}

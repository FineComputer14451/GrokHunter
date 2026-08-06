#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter CLI parsing & help
# shellcheck disable=SC2034

NON_INTERACTIVE=0
OVERLAY_ONLY=0
SELECTED_INSTALLATION=""
SELECTED_DE=""
SELECTED_BROWSER=""
SKIP_DE=0

# Optional overlay features: yes | no | auto
#   yes  — install
#   no   — skip
#   auto — interactive: ask; non-interactive: skip (completions has sibling policy)
FEATURE_GROK=auto
FEATURE_X11=auto
FEATURE_AIDER=auto
FEATURE_V9=auto
FEATURE_COMPLETIONS=auto

# Legacy aliases (read by older docs/snippets; kept in sync by parse_cli)
INSTALL_GROK=0
SKIP_GROK=0
INSTALL_X11=0
SKIP_X11=0
INSTALL_AIDER=0
SKIP_AIDER=0
INSTALL_V9=0
SKIP_V9=0
INSTALL_COMPLETIONS=0
SKIP_COMPLETIONS=0

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
  --with-completions      Install zsh/bash completions + profile snippet
  --no-completions        Skip shell completions
  --overlay-only          Skip rootfs / termux-distro; only run optional overlays
                          (use with --with-grok / --with-x11 / --with-aider / …)
  -h, --help              Show this help and exit

Examples:
  install.sh --full --de xfce --with-grok --with-x11 --with-aider --with-completions
  install.sh -m
  install.sh --nano --no-de --with-grok
  install.sh --overlay-only --with-x11 --with-aider --with-v9-models

Env:
  GROKHUNTER_REFRESH=1              Bypass module + engine cache
  GROKHUNTER_DISTRO_ENGINE_URL=…    Pin/fork of termux-distro.sh

Grok Build:  https://x.ai/cli
Termux:X11:  https://github.com/termux/termux-x11
Aider:       https://aider.chat
Shell:       docs/SHELL.md
Repo:        https://github.com/FineComputer14451/GrokHunter
HELP
  exit "${ec}"
}

# Set FEATURE_* + keep legacy INSTALL_*/SKIP_* mirrors for any external hooks.
_feature_yes() {
  local name="$1"
  case "${name}" in
    grok) FEATURE_GROK=yes; INSTALL_GROK=1; SKIP_GROK=0 ;;
    x11) FEATURE_X11=yes; INSTALL_X11=1; SKIP_X11=0 ;;
    aider) FEATURE_AIDER=yes; INSTALL_AIDER=1; SKIP_AIDER=0 ;;
    v9) FEATURE_V9=yes; INSTALL_V9=1; SKIP_V9=0 ;;
    completions) FEATURE_COMPLETIONS=yes; INSTALL_COMPLETIONS=1; SKIP_COMPLETIONS=0 ;;
  esac
}

_feature_no() {
  local name="$1"
  case "${name}" in
    grok) FEATURE_GROK=no; INSTALL_GROK=0; SKIP_GROK=1 ;;
    x11) FEATURE_X11=no; INSTALL_X11=0; SKIP_X11=1 ;;
    aider) FEATURE_AIDER=no; INSTALL_AIDER=0; SKIP_AIDER=1 ;;
    v9) FEATURE_V9=no; INSTALL_V9=0; SKIP_V9=1 ;;
    completions) FEATURE_COMPLETIONS=no; INSTALL_COMPLETIONS=0; SKIP_COMPLETIONS=1 ;;
  esac
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
        case "${2,,}" in
          e17|enlightenment|gnome|i3|kde|plasma|lxde|mate|xfce|xfce4) ;;
          *) echo "Error: unknown desktop '$2' (e17|gnome|i3|kde|lxde|mate|xfce)" >&2; show_help 2 ;;
        esac
        SELECTED_DE="$2"; NON_INTERACTIVE=1; shift 2 ;;
      --browser)
        if [[ $# -lt 2 || "$2" == -* ]]; then
          echo "Error: --browser requires a value (chromium|firefox|both)" >&2
          show_help 2
        fi
        case "${2,,}" in
          chromium|chrome|firefox|firefox-esr|both) ;;
          *) echo "Error: unknown browser '$2' (chromium|firefox|both)" >&2; show_help 2 ;;
        esac
        SELECTED_BROWSER="$2"; NON_INTERACTIVE=1; shift 2 ;;
      --no-de)       SKIP_DE=1; NON_INTERACTIVE=1; shift ;;
      --with-grok)   _feature_yes grok; NON_INTERACTIVE=1; shift ;;
      --no-grok)     _feature_no grok; NON_INTERACTIVE=1; shift ;;
      --with-x11)    _feature_yes x11; NON_INTERACTIVE=1; shift ;;
      --no-x11)      _feature_no x11; NON_INTERACTIVE=1; shift ;;
      --with-aider)  _feature_yes aider; NON_INTERACTIVE=1; shift ;;
      --no-aider)    _feature_no aider; NON_INTERACTIVE=1; shift ;;
      --with-v9-models) _feature_yes v9; NON_INTERACTIVE=1; shift ;;
      --no-v9-models)   _feature_no v9; NON_INTERACTIVE=1; shift ;;
      --with-completions) _feature_yes completions; NON_INTERACTIVE=1; shift ;;
      --no-completions)   _feature_no completions; NON_INTERACTIVE=1; shift ;;
      --overlay-only) OVERLAY_ONLY=1; NON_INTERACTIVE=1; shift ;;
      -h|--help)     show_help 0 ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        show_help 2
        ;;
    esac
  done
}

# >>> grokhunter >>>
# GrokHunter shell integration — source from ~/.zshrc or ~/.bashrc
# Safe to re-source.

export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"

export COLORTERM="${COLORTERM:-truecolor}"
if [[ -z "${TERM:-}" || "${TERM}" == "dumb" ]]; then
  export TERM="xterm-256color"
fi

if [[ -r "${HOME}/.grok/secrets.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${HOME}/.grok/secrets.env"
  set +a
fi

export GROKHUNTER_HOME="${GROKHUNTER_HOME:-${HOME}/GrokHunter}"
export GROKHUNTER_VERSION="${GROKHUNTER_VERSION:-1.0.6}"
if [[ -d "${GROKHUNTER_HOME}/bin" ]]; then
  export PATH="${GROKHUNTER_HOME}/bin:${PATH}"
fi

# --- zsh ---
if [[ -n "${ZSH_VERSION:-}" ]]; then
  if [[ -d "${HOME}/.grok/completions/zsh" ]]; then
    fpath=("${HOME}/.grok/completions/zsh" ${fpath[@]})
  fi
  if [[ -d "${GROKHUNTER_HOME}/config/completions/zsh" ]]; then
    fpath=("${GROKHUNTER_HOME}/config/completions/zsh" ${fpath[@]})
  fi
  (( ${+aliases[gh]} ))  || alias gh='grokhunter'
  (( ${+aliases[ghn]} )) || alias ghn='grok-nethunter'
  (( ${+aliases[ghd]} )) || alias ghd='grokhunter doctor'
  (( ${+aliases[ghs]} )) || alias ghs='grokhunter status'
  (( ${+aliases[ghsu]} )) || alias ghsu='grokhunter setup'
  (( ${+aliases[ght]} )) || alias ght='grokhunter team'
  (( ${+aliases[ghp]} )) || alias ghp='grokhunter plan'
  (( ${+aliases[ghm]} )) || alias ghm='grokhunter models'
  (( ${+aliases[ghk]} )) || alias ghk='grokhunter skills'
  (( ${+aliases[ghai]} )) || alias ghai='grokhunter ai-smoke'
  if ! typeset -f ghh >/dev/null 2>&1; then
    ghh() { grokhunter -p "$*"; }
  fi
fi

# --- bash ---
if [[ -n "${BASH_VERSION:-}" ]]; then
  if [[ -r "${HOME}/.grok/completions/bash/grokhunter.bash" ]]; then
    # shellcheck disable=SC1091
    source "${HOME}/.grok/completions/bash/grokhunter.bash"
  elif [[ -r "${GROKHUNTER_HOME}/config/completions/bash/grokhunter.bash" ]]; then
    # shellcheck disable=SC1091
    source "${GROKHUNTER_HOME}/config/completions/bash/grokhunter.bash"
  fi
  alias gh='grokhunter' 2>/dev/null || true
  alias ghn='grok-nethunter' 2>/dev/null || true
  alias ghd='grokhunter doctor' 2>/dev/null || true
  alias ghs='grokhunter status' 2>/dev/null || true
  alias ghsu='grokhunter setup' 2>/dev/null || true
  alias ght='grokhunter team' 2>/dev/null || true
  alias ghp='grokhunter plan' 2>/dev/null || true
  alias ghm='grokhunter models' 2>/dev/null || true
  alias ghk='grokhunter skills' 2>/dev/null || true
  alias ghai='grokhunter ai-smoke' 2>/dev/null || true
  ghh() { grokhunter -p "$*"; }
fi

if [[ -d "${HOME}/Grok-Imagine-Cinematic-Studio" ]]; then
  alias studio='cd "${HOME}/Grok-Imagine-Cinematic-Studio"'
fi
# <<< grokhunter <<<

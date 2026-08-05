# >>> grokhunter >>>
# GrokHunter shell integration — sourced from ~/.zshrc / ~/.bashrc
# Safe to re-source; keep markers if you hand-edit.

export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"

# Mobile / NetHunter terminal defaults
export COLORTERM="${COLORTERM:-truecolor}"
if [[ -z "${TERM:-}" || "${TERM}" == "dumb" ]]; then
  export TERM="xterm-256color"
fi

# Durable secrets (never commit this file)
if [[ -r "${HOME}/.grok/secrets.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${HOME}/.grok/secrets.env"
  set +a
fi

# Completions (zsh)
if [[ -n "${ZSH_VERSION:-}" && -d "${HOME}/.grok/completions/zsh" ]]; then
  fpath=("${HOME}/.grok/completions/zsh" $fpath)
fi
# Completions (bash)
if [[ -n "${BASH_VERSION:-}" && -r "${HOME}/.grok/completions/bash/grok.bash" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/.grok/completions/bash/grok.bash"
fi

# Aliases — short paths for chroot operators
alias gh='grokhunter'
alias ghn='grok-nethunter'
alias ghd='grokhunter doctor'
alias ghs='grokhunter status'
alias ghp='grokhunter plan'
# headless: ghh "prompt"
ghh() { grokhunter -p "$*"; }

# Project shortcut when Cinematic Studio is present
if [[ -d "${HOME}/Grok-Imagine-Cinematic-Studio" ]]; then
  alias studio='cd "${HOME}/Grok-Imagine-Cinematic-Studio"'
fi

export GROKHUNTER_HOME="${GROKHUNTER_HOME:-${HOME}/GrokHunter}"
export GROKHUNTER_VERSION="${GROKHUNTER_VERSION:-1.0.1}"
# Prefer clone bin/ when wrappers are not installed to ~/.local/bin yet
if [[ -d "${GROKHUNTER_HOME}/bin" ]]; then
  export PATH="${GROKHUNTER_HOME}/bin:${PATH}"
fi
# <<< grokhunter <<<

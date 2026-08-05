#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — native Grok Build CLI + optional Aider

install_grok_build() {
  msg -t "Installing native Grok Build CLI (Termux)"

  if command -v grok &>/dev/null; then
    msg -ts "Grok Build already present — skipping"
    return 0
  fi

  local installer_url="https://raw.githubusercontent.com/Thr45hx/grok-cli-termux-native/main/install.sh"

  msg -tn "Downloading & running Grok Build Termux-native installer..."
  if curl -fsSL "${installer_url}" | bash; then
    cursor -u1
    if command -v grok &>/dev/null; then
      msg -ts "Grok Build installed successfully"
      msg -a "  Run ${P}grok${S} or ${P}grok -p \"hello from coding lab\"${S}"
      msg -a "  Auth: export XAI_API_KEY=xai-...   or browser sign-in on first launch"
    else
      msg -tw "Installer finished but 'grok' not found in PATH — check ~/agents/grok or restart Termux"
    fi
  else
    cursor -u1
    msg -te "Failed to install Grok Build via Termux-native script"
    msg -a "  Manual: curl -fsSL ${installer_url} | bash"
    msg -a "  Or official: curl -fsSL https://x.ai/cli/install.sh | bash"
    return 1
  fi
}

install_aider() {
  msg -t "Installing Aider (pair-programmer, xAI-ready)"

  if command -v aider &>/dev/null || [[ -x "${HOME}/venv-aider/bin/aider" ]]; then
    msg -ts "Aider already present — skipping"
    return 0
  fi

  msg -tn "Creating venv and installing aider-chat..."
  if ! command -v python3 &>/dev/null; then
    cursor -u1
    msg -te "python3 required for Aider"
    msg -a "  Inside nethunter: sudo apt install -y python3 python3-venv python3-pip"
    msg -a "  Termux host: pkg install python"
    return 1
  fi

  if ! python3 -m venv "${HOME}/venv-aider" 2>>"${LOG_FILE:-/dev/null}"; then
    cursor -u1
    msg -tw "venv failed — trying pip install --user"
    if python3 -m pip install --user aider-chat 2>>"${LOG_FILE:-/dev/null}"; then
      msg -ts "Aider installed with pip --user"
    else
      msg -te "Failed to install Aider — see docs/EDITORS.md"
      return 1
    fi
  else
    if "${HOME}/venv-aider/bin/pip" install -q aider-chat 2>>"${LOG_FILE:-/dev/null}"; then
      cursor -u1
      msg -ts "Aider installed in ~/venv-aider"
    else
      cursor -u1
      msg -te "pip install aider-chat failed"
      return 1
    fi
  fi

  mkdir -p "${HOME}/.local/bin"
  cat > "${HOME}/.local/bin/aider-grok" << 'WRAP'
#!/usr/bin/env bash
# Aider preconfigured for xAI / Grok (GrokHunter)
set -euo pipefail
if [[ -x "${HOME}/venv-aider/bin/aider" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/venv-aider/bin/activate"
fi
[[ -f "${HOME}/.grok/secrets.env" ]] && source "${HOME}/.grok/secrets.env"
export OPENAI_API_BASE="${OPENAI_API_BASE:-https://api.x.ai/v1}"
export OPENAI_API_KEY="${XAI_API_KEY:-${OPENAI_API_KEY:-}}"
if [[ -z "${OPENAI_API_KEY}" ]]; then
  echo "Set XAI_API_KEY (e.g. in ~/.grok/secrets.env) before using aider-grok" >&2
  exit 1
fi
exec aider "$@"
WRAP
  chmod +x "${HOME}/.local/bin/aider-grok"
  msg -ts "Helper: aider-grok (uses XAI_API_KEY)"
  msg -a "  ${P}source ~/venv-aider/bin/activate && aider${S}"
  msg -a "  or: ${P}aider-grok${S}"
}

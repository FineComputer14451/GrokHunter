#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — native Grok Build CLI + optional Aider
#
# Install path is shared with scripts/ensure_grok.sh:
#   GROKHUNTER_GROK_INSTALLER=auto|official|termux-native

_gh_find_ensure_script() {
  local candidates=(
    "${SCRIPT_DIR:-}/scripts/ensure_grok.sh"
    "${GROKHUNTER_HOME:-${HOME}/GrokHunter}/scripts/ensure_grok.sh"
    "${HOME}/GrokHunter/scripts/ensure_grok.sh"
    "${HOME}/.cache/grokhunter/scripts/ensure_grok.sh"
  )
  local c
  for c in "${candidates[@]}"; do
    [[ -n "$c" && -f "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  return 1
}

_gh_fetch_ensure_script() {
  local dest="${HOME}/.cache/grokhunter/scripts"
  local url="${REPO_RAW:-https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main}/scripts/ensure_grok.sh"
  mkdir -p "${dest}" || return 1
  if curl -fsSL --connect-timeout 12 --max-time 60 --retry 2 "${url}" -o "${dest}/ensure_grok.sh"; then
    if grep -qE 'GROKHUNTER_GROK_INSTALLER|_resolve_mode' "${dest}/ensure_grok.sh" 2>/dev/null; then
      chmod 755 "${dest}/ensure_grok.sh" 2>/dev/null || true
      printf '%s\n' "${dest}/ensure_grok.sh"
      return 0
    fi
  fi
  return 1
}

install_grok_build() {
  msg -t "Installing Grok Build CLI"

  if command -v grok &>/dev/null && [[ "${GROKHUNTER_FORCE_GROK:-0}" != "1" ]]; then
    msg -ts "Grok Build already present — skipping"
    return 0
  fi

  local ensure
  if ! ensure="$(_gh_find_ensure_script)"; then
    msg -tn "Fetching shared ensure_grok.sh…"
    if ensure="$(_gh_fetch_ensure_script)"; then
      cursor -u1
      msg -ts "ensure_grok.sh cached"
    else
      cursor -u1
      msg -tw "Could not locate ensure_grok.sh — using inline fallback"
      ensure=""
    fi
  fi

  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"

  if [[ -n "${ensure}" ]]; then
    msg -tn "Running shared Grok installer (see scripts/ensure_grok.sh)…"
    if bash "${ensure}"; then
      cursor -u1
      if command -v grok &>/dev/null; then
        msg -ts "Grok Build installed successfully"
        msg -a "  Run ${P}grok${S} or ${P}grok -p \"hello from coding lab\"${S}"
        msg -a "  Auth: export XAI_API_KEY=xai-...   or browser sign-in on first launch"
        msg -a "  Installer mode: ${P}\${GROKHUNTER_GROK_INSTALLER:-auto}${S} (auto|official|termux-native)"
        return 0
      fi
    fi
    cursor -u1
  fi

  # Inline fallback (same policy as ensure_grok.sh) if shared script unavailable
  local mode="${GROKHUNTER_GROK_INSTALLER:-auto}"
  local official="${GROKHUNTER_GROK_OFFICIAL_URL:-https://x.ai/cli/install.sh}"
  local termux_native="${GROKHUNTER_GROK_TERMUX_URL:-https://raw.githubusercontent.com/Thr45hx/grok-cli-termux-native/main/install.sh}"
  local primary secondary

  if [[ "${mode}" == "auto" ]]; then
    if [[ -n "${PREFIX:-}" && "${PREFIX}" == *com.termux* ]] || [[ -d /data/data/com.termux/files/usr ]]; then
      mode="termux-native"
    else
      mode="official"
    fi
  fi

  if [[ "${mode}" == "termux-native" ]]; then
    primary="${termux_native}"; secondary="${official}"
  else
    primary="${official}"; secondary="${termux_native}"
  fi

  msg -tn "Downloading & running Grok installer (${mode})…"
  if curl -fsSL --connect-timeout 15 --max-time 180 --retry 2 "${primary}" | bash; then
    export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"
    cursor -u1
    if command -v grok &>/dev/null; then
      msg -ts "Grok Build installed successfully"
      msg -a "  Run ${P}grok${S} or ${P}grok -p \"hello from coding lab\"${S}"
      msg -a "  Auth: export XAI_API_KEY=xai-...   or browser sign-in on first launch"
      return 0
    fi
  fi
  cursor -u1
  msg -tw "Primary installer failed — trying fallback…"
  if curl -fsSL --connect-timeout 15 --max-time 180 --retry 2 "${secondary}" | bash; then
    export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"
    if command -v grok &>/dev/null; then
      msg -ts "Grok Build installed via fallback"
      return 0
    fi
  fi

  msg -te "Failed to install Grok Build"
  msg -a "  Manual official: curl -fsSL ${official} | bash"
  msg -a "  Manual Termux:   curl -fsSL ${termux_native} | bash"
  msg -a "  Or: bash scripts/ensure_grok.sh"
  return 1
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

#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Grok Build + Aider + V9 helpers
# Called from lib/actions.sh during install / complete phase.

# ---------------------------------------------------------------------------
# Grok Build
# ---------------------------------------------------------------------------
install_grok_build() {
  msg -t "Installing Grok Build CLI"

  local ensure=""
  # Prefer the shared script from the overlay / cache
  if [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/scripts/ensure_grok.sh" ]]; then
    ensure="${SCRIPT_DIR}/scripts/ensure_grok.sh"
  elif [[ -f "${HOME}/GrokHunter/scripts/ensure_grok.sh" ]]; then
    ensure="${HOME}/GrokHunter/scripts/ensure_grok.sh"
  elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/scripts/ensure_grok.sh" ]]; then
    ensure="${GROKHUNTER_HOME}/scripts/ensure_grok.sh"
  fi

  if [[ -n "${ensure}" && -f "${ensure}" ]]; then
    msg -tn "Running shared ensure_grok.sh…"
    if bash "${ensure}"; then
      cursor -u1
      msg -ts "Grok Build ready"
    else
      cursor -u1
      msg -tw "ensure_grok.sh reported issues — try: grokhunter ensure --force"
    fi
  else
    msg -tn "Fetching official Grok Build installer…"
    if curl -fsSL --connect-timeout 15 --max-time 180 \
         "${GROKHUNTER_GROK_OFFICIAL_URL:-https://x.ai/cli/install.sh}" | bash; then
      cursor -u1
      msg -ts "Grok Build installed (official)"
    else
      cursor -u1
      msg -te "Grok Build install failed"
      return 1
    fi
  fi

  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"
  if command -v grok >/dev/null 2>&1; then
    msg -a "  $(grok --version 2>/dev/null | head -1 || echo grok)"
  fi
}

# ---------------------------------------------------------------------------
# Aider (git-native pair programmer, xAI / Grok 4.5)
# ---------------------------------------------------------------------------
install_aider() {
  msg -t "Installing Aider (git-native pair-programmer for Grok)"

  local rootfs_home="${ROOTFS_DIRECTORY:-/data/data/com.termux/files/kali}/home/kali"
  local venv_dir="${rootfs_home}/venv-aider"
  local host_local_bin="${HOME}/.local/bin"
  local overlay_bin=""

  # Resolve overlay bin so we can drop aider-grok there too
  if [[ -n "${SCRIPT_DIR:-}" && -d "${SCRIPT_DIR}/bin" ]]; then
    overlay_bin="${SCRIPT_DIR}/bin"
  elif [[ -d "${HOME}/GrokHunter/bin" ]]; then
    overlay_bin="${HOME}/GrokHunter/bin"
  elif [[ -n "${GROKHUNTER_HOME:-}" && -d "${GROKHUNTER_HOME}/bin" ]]; then
    overlay_bin="${GROKHUNTER_HOME}/bin"
  fi

  # Prefer installing inside the Kali rootfs (where coding actually happens)
  if declare -F distro_exec >/dev/null 2>&1 && [[ -d "${ROOTFS_DIRECTORY:-}" ]]; then
    msg -tn "Creating Python venv + installing aider-chat inside NetHunter…"
    if distro_exec bash -c '
      set -e
      export DEBIAN_FRONTEND=noninteractive
      apt-get update -qq >/dev/null 2>&1 || true
      apt-get install -y -qq python3 python3-pip python3-venv git >/dev/null 2>&1 || true
      python3 -m venv "$HOME/venv-aider"
      # shellcheck disable=SC1091
      source "$HOME/venv-aider/bin/activate"
      pip install -U pip >/dev/null
      pip install -U aider-chat
      echo "aider version: $(aider --version 2>/dev/null | head -1 || echo unknown)"
    '; then
      cursor -u1
      msg -ts "Aider installed in ~/venv-aider (Kali)"
    else
      cursor -u1
      msg -tw "Rootfs Aider install had issues — see docs/EDITORS.md for manual steps"
    fi
  else
    # Fallback: host-side venv (still useful on pure Termux)
    msg -tn "Creating host-side ~/venv-aider…"
    if command -v python3 >/dev/null 2>&1; then
      python3 -m venv "${HOME}/venv-aider" 2>/dev/null || true
      # shellcheck disable=SC1091
      if source "${HOME}/venv-aider/bin/activate" 2>/dev/null; then
        pip install -U pip >/dev/null 2>&1 || true
        pip install -U aider-chat >/dev/null 2>&1 || true
        cursor -u1
        msg -ts "Aider host venv ready"
      else
        cursor -u1
        msg -tw "Could not create host venv"
      fi
    else
      cursor -u1
      msg -tw "python3 missing on host — install Aider manually inside nethunter"
    fi
  fi

  # Write the aider-grok helper (host + overlay)
  mkdir -p "${host_local_bin}" 2>/dev/null || true
  local helper_content
  helper_content="$(cat << 'AIDER_GROK_EOF'
#!/usr/bin/env bash
# aider-grok — GrokHunter helper: Aider + xAI / Grok 4.5
# Sources ~/.grok/secrets.env, sets OpenAI-compatible base, launches aider.
set -euo pipefail

# Secrets (never echo)
if [[ -r "${HOME}/.grok/secrets.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${HOME}/.grok/secrets.env"
  set +a
fi

# xAI OpenAI-compatible endpoint
export OPENAI_API_BASE="${OPENAI_API_BASE:-https://api.x.ai/v1}"
if [[ -n "${XAI_API_KEY:-}" ]]; then
  export OPENAI_API_KEY="${XAI_API_KEY}"
fi

# Prefer Grok 4.5-class coding model (override with AIDER_MODEL if needed)
export AIDER_MODEL="${AIDER_MODEL:-grok-4.5}"

# Prefer the NetHunter / lab venv if present
if [[ -x "${HOME}/venv-aider/bin/aider" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/venv-aider/bin/activate"
elif [[ -x "/home/kali/venv-aider/bin/aider" ]]; then
  # shellcheck disable=SC1091
  source "/home/kali/venv-aider/bin/activate"
fi

if ! command -v aider >/dev/null 2>&1; then
  echo "[aider-grok] aider not found." >&2
  echo "  Inside nethunter:  source ~/venv-aider/bin/activate" >&2
  echo "  Or re-run:         bash install.sh --with-aider" >&2
  echo "  Manual:            docs/EDITORS.md" >&2
  exit 1
fi

# Default model if user did not pass --model
has_model=0
for a in "$@"; do
  case "$a" in
    --model|--model=*) has_model=1 ;;
  esac
done

if [[ "${has_model}" -eq 0 ]]; then
  exec aider --model "${AIDER_MODEL}" "$@"
else
  exec aider "$@"
fi
AIDER_GROK_EOF
)"

  # Install helper on host
  printf '%s\n' "${helper_content}" > "${host_local_bin}/aider-grok"
  chmod 755 "${host_local_bin}/aider-grok" 2>/dev/null || true
  msg -ts "Helper: ${host_local_bin}/aider-grok"

  # Also drop into overlay bin/ when available
  if [[ -n "${overlay_bin}" ]]; then
    printf '%s\n' "${helper_content}" > "${overlay_bin}/aider-grok"
    chmod 755 "${overlay_bin}/aider-grok" 2>/dev/null || true
  fi

  # Best-effort: copy helper into the rootfs so it is available as kali user
  if declare -F distro_exec >/dev/null 2>&1 && [[ -d "${ROOTFS_DIRECTORY:-}" ]]; then
    distro_exec bash -c "
      mkdir -p /usr/local/bin /home/kali/.local/bin 2>/dev/null || true
      cat > /usr/local/bin/aider-grok << 'INNER'
${helper_content}
INNER
      chmod 755 /usr/local/bin/aider-grok
      cp -f /usr/local/bin/aider-grok /home/kali/.local/bin/aider-grok 2>/dev/null || true
      chown kali:kali /home/kali/.local/bin/aider-grok 2>/dev/null || true
    " 2>/dev/null || true
  fi

  msg -a "  Usage (inside nethunter):  aider-grok"
  msg -a "  Or:  source ~/venv-aider/bin/activate && aider --model grok-4.5"
  msg -a "  Docs: docs/EDITORS.md"
}

# ---------------------------------------------------------------------------
# V9 / 4.5 model pickers
# ---------------------------------------------------------------------------
install_v9_models() {
  msg -t "Installing Grok V9 / 4.5 model pickers"

  local script=""
  if [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/scripts/install_v9_grok_models.sh" ]]; then
    script="${SCRIPT_DIR}/scripts/install_v9_grok_models.sh"
  elif [[ -f "${HOME}/GrokHunter/scripts/install_v9_grok_models.sh" ]]; then
    script="${HOME}/GrokHunter/scripts/install_v9_grok_models.sh"
  elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/scripts/install_v9_grok_models.sh" ]]; then
    script="${GROKHUNTER_HOME}/scripts/install_v9_grok_models.sh"
  fi

  if [[ -n "${script}" && -f "${script}" ]]; then
    msg -tn "Running install_v9_grok_models.sh…"
    if bash "${script}"; then
      cursor -u1
      msg -ts "V9 / 4.5 model pickers installed"
    else
      cursor -u1
      msg -tw "V9 picker install reported issues — try: bash scripts/install_v9_grok_models.sh --force"
    fi
  else
    msg -tw "scripts/install_v9_grok_models.sh not found — skip or clone the repo"
  fi
}

# ---------------------------------------------------------------------------
# Shell completions
# ---------------------------------------------------------------------------
install_shell_completions() {
  msg -t "Installing shell completions"

  local script=""
  if [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/scripts/install-completions.sh" ]]; then
    script="${SCRIPT_DIR}/scripts/install-completions.sh"
  elif [[ -f "${HOME}/GrokHunter/scripts/install-completions.sh" ]]; then
    script="${HOME}/GrokHunter/scripts/install-completions.sh"
  elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/scripts/install-completions.sh" ]]; then
    script="${GROKHUNTER_HOME}/scripts/install-completions.sh"
  fi

  if [[ -n "${script}" && -f "${script}" ]]; then
    if bash "${script}"; then
      msg -ts "Completions + profile snippet installed"
    else
      msg -tw "Completions install had issues"
    fi
  else
    msg -tw "scripts/install-completions.sh not found"
  fi
}

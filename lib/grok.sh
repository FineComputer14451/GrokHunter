#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Grok Build + Aider + V9 helpers
# Called from lib/actions.sh during install / complete phase.

# ---------------------------------------------------------------------------
# Path helpers (single resolution path for scripts / bins)
# ---------------------------------------------------------------------------
_gh_overlay_root() {
  local d
  for d in "${SCRIPT_DIR:-}" "${GROKHUNTER_HOME:-}" "${HOME}/GrokHunter"; do
    if [[ -n "${d}" && -d "${d}" && ( -f "${d}/install.sh" || -d "${d}/bin" || -d "${d}/scripts" ) ]]; then
      printf '%s\n' "${d}"
      return 0
    fi
  done
  return 1
}

_gh_resolve() {
  local rel="$1"
  local root
  if root="$(_gh_overlay_root)"; then
    if [[ -f "${root}/${rel}" ]]; then
      printf '%s\n' "${root}/${rel}"
      return 0
    fi
  fi
  return 1
}

_gh_install_bin() {
  local rel="$1"
  local dest="$2"
  local src
  if ! src="$(_gh_resolve "${rel}")"; then
    msg -tw "Missing ${rel} in overlay"
    return 1
  fi
  mkdir -p "$(dirname "${dest}")" 2>/dev/null || true
  if command -v install >/dev/null 2>&1; then
    install -m 755 "${src}" "${dest}" 2>/dev/null || cp -f "${src}" "${dest}"
  else
    cp -f "${src}" "${dest}"
  fi
  chmod 755 "${dest}" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Grok Build
# ---------------------------------------------------------------------------
install_grok_build() {
  msg -t "Installing Grok Build CLI"

  local ensure=""
  ensure="$(_gh_resolve "scripts/ensure_grok.sh" || true)"

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

  local rootfs="${ROOTFS_DIRECTORY:-/data/data/com.termux/files/kali}"
  local host_local_bin="${HOME}/.local/bin"
  local helper_src=""
  helper_src="$(_gh_resolve "bin/aider-grok" || true)"

  # Prefer installing inside the Kali rootfs (where coding actually happens)
  if declare -F distro_exec >/dev/null 2>&1 && [[ -d "${rootfs}" ]]; then
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
    # Fallback: host-side venv (still useful on pure Termux / overlay-only)
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

  # Install canonical bin/aider-grok (no embedded heredoc)
  if [[ -z "${helper_src}" || ! -f "${helper_src}" ]]; then
    msg -tw "bin/aider-grok missing — clone the repo or re-run from a full tree"
  else
    mkdir -p "${host_local_bin}" 2>/dev/null || true
    _gh_install_bin "bin/aider-grok" "${host_local_bin}/aider-grok" \
      && msg -ts "Helper: ${host_local_bin}/aider-grok"

    # Best-effort: copy into rootfs without string embedding
    if [[ -d "${rootfs}" ]]; then
      mkdir -p "${rootfs}/usr/local/bin" "${rootfs}/home/kali/.local/bin" 2>/dev/null || true
      if cp -f "${helper_src}" "${rootfs}/usr/local/bin/aider-grok" 2>/dev/null; then
        chmod 755 "${rootfs}/usr/local/bin/aider-grok" 2>/dev/null || true
        cp -f "${helper_src}" "${rootfs}/home/kali/.local/bin/aider-grok" 2>/dev/null || true
        chmod 755 "${rootfs}/home/kali/.local/bin/aider-grok" 2>/dev/null || true
        chown kali:kali "${rootfs}/home/kali/.local/bin/aider-grok" 2>/dev/null || true
        msg -ts "Helper also installed in rootfs /usr/local/bin/aider-grok"
      fi
    fi
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
  script="$(_gh_resolve "scripts/install_v9_grok_models.sh" || true)"

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
  script="$(_gh_resolve "scripts/install-completions.sh" || true)"

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

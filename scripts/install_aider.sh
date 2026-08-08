#!/usr/bin/env bash
# Shared Aider installer — used by install (lib/grok.sh) and standalone repair.
#
# Why this is not a plain `pip install aider-chat` into a system venv:
#   - aider-chat requires Python >=3.10,<3.13 (Kali default is often 3.13)
#   - Debian/Kali need python3-venv/ensurepip or venv creation fails
#   - Official path uses uv + managed Python 3.12 (see https://aider.chat/docs/install.html)
#
# Env:
#   GROKHUNTER_AIDER_HOME   Target home for tools (default: /home/kali if present, else $HOME)
#   GROKHUNTER_FORCE_AIDER=1  Reinstall even if aider already works
#   GROKHUNTER_AIDER_METHOD=auto|uv|venv|curl  Prefer a method (default auto)
#
# Exit: 0 if `aider` is on PATH (or under known tool dirs), 1 on failure.
set -euo pipefail

info() { echo "[install_aider] $*"; }
warn() { echo "[install_aider] WARN: $*" >&2; }
die()  { echo "[install_aider] ERROR: $*" >&2; exit 1; }

# Prefer kali home when running as root inside NetHunter so the user session finds the tool.
_resolve_target_home() {
  if [[ -n "${GROKHUNTER_AIDER_HOME:-}" ]]; then
    printf '%s\n' "${GROKHUNTER_AIDER_HOME}"
    return 0
  fi
  if [[ -d /home/kali ]] && { [[ "$(id -u)" -eq 0 ]] || [[ "${HOME:-}" == /root ]]; }; then
    printf '%s\n' "/home/kali"
    return 0
  fi
  if [[ -d /home/kali && -w /home/kali ]]; then
    printf '%s\n' "/home/kali"
    return 0
  fi
  printf '%s\n' "${HOME:-/home/kali}"
}

TARGET_HOME="$(_resolve_target_home)"
export HOME="${TARGET_HOME}"
export PATH="${TARGET_HOME}/.local/bin:${TARGET_HOME}/.cargo/bin:${PATH:-}"
mkdir -p "${TARGET_HOME}/.local/bin" 2>/dev/null || true

# Known places we may have left aider
_aider_candidates() {
  printf '%s\n' \
    "${TARGET_HOME}/.local/bin/aider" \
    "${TARGET_HOME}/venv-aider/bin/aider" \
    "/home/kali/.local/bin/aider" \
    "/home/kali/venv-aider/bin/aider" \
    "${HOME}/.local/bin/aider" \
    "${HOME}/venv-aider/bin/aider"
}

_aider_ok() {
  local c
  if command -v aider >/dev/null 2>&1; then
    if aider --version >/dev/null 2>&1 || aider --help >/dev/null 2>&1; then
      return 0
    fi
  fi
  while IFS= read -r c; do
    [[ -x "${c}" ]] || continue
    if "${c}" --version >/dev/null 2>&1 || "${c}" --help >/dev/null 2>&1; then
      export PATH="$(dirname "${c}"):${PATH}"
      return 0
    fi
  done < <(_aider_candidates)
  return 1
}

_report_aider() {
  local c
  if command -v aider >/dev/null 2>&1; then
    info "OK — $(command -v aider)"
    aider --version 2>/dev/null | head -1 || true
    return 0
  fi
  while IFS= read -r c; do
    if [[ -x "${c}" ]]; then
      info "OK — ${c}"
      "${c}" --version 2>/dev/null | head -1 || true
      return 0
    fi
  done < <(_aider_candidates)
  return 1
}

_have_cmd() { command -v "$1" >/dev/null 2>&1; }

_apt_install_prereqs() {
  if ! _have_cmd apt-get && ! _have_cmd apt; then
    return 0
  fi
  export DEBIAN_FRONTEND=noninteractive
  info "Ensuring apt prereqs (python3, venv, curl, git)…"
  # Do not hide failures entirely — warn but continue; methods below may still work.
  if _have_cmd apt-get; then
    apt-get update -qq 2>/dev/null || warn "apt-get update failed (continuing)"
    apt-get install -y -qq \
      python3 python3-pip python3-venv python3-full \
      curl ca-certificates git \
      2>/dev/null \
      || apt-get install -y \
        python3 python3-pip python3-venv curl ca-certificates git \
        2>&1 | tail -20 \
      || warn "apt prereq install incomplete"
  fi
}

# Standalone uv binary (no ensurepip needed).
_install_uv() {
  if _have_cmd uv; then
    return 0
  fi
  if [[ -x "${TARGET_HOME}/.local/bin/uv" ]]; then
    export PATH="${TARGET_HOME}/.local/bin:${PATH}"
    _have_cmd uv && return 0
  fi
  if [[ -x "${TARGET_HOME}/.cargo/bin/uv" ]]; then
    export PATH="${TARGET_HOME}/.cargo/bin:${PATH}"
    _have_cmd uv && return 0
  fi

  _have_cmd curl || return 1
  info "Installing uv (Astral) into ${TARGET_HOME}…"
  # UV_INSTALL_DIR pins the bin dir; installer respects HOME for cargo path.
  export UV_INSTALL_DIR="${TARGET_HOME}/.local/bin"
  if ! curl -LsSf --connect-timeout 15 --max-time 120 --retry 2 \
       https://astral.sh/uv/install.sh | sh; then
    warn "uv install.sh failed"
    return 1
  fi
  export PATH="${TARGET_HOME}/.local/bin:${TARGET_HOME}/.cargo/bin:${PATH}"
  _have_cmd uv
}

# Primary: uv manages a Python 3.12 env (aider-chat requires <3.13).
_method_uv() {
  info "Method: uv tool install (Python 3.12 + aider-chat)"
  _install_uv || return 1

  # Mobile / proot: avoid huge caches when free space is tight.
  export UV_TOOL_BIN_DIR="${TARGET_HOME}/.local/bin"
  export UV_TOOL_DIR="${TARGET_HOME}/.local/share/uv/tools"
  mkdir -p "${UV_TOOL_BIN_DIR}" "${UV_TOOL_DIR}" 2>/dev/null || true

  info "Running: uv tool install --force --python 3.12 --with pip aider-chat@latest"
  # --python 3.12 pulls a managed CPython if system is 3.13+
  if ! uv tool install --force --python 3.12 --with pip "aider-chat@latest"; then
    warn "uv tool install failed"
    return 1
  fi
  export PATH="${TARGET_HOME}/.local/bin:${PATH}"
  _aider_ok
}

# Official one-liner (also uv-based under the hood).
_method_curl() {
  info "Method: official aider install.sh"
  _have_cmd curl || return 1
  if ! curl -LsSf --connect-timeout 15 --max-time 180 --retry 2 \
       https://aider.chat/install.sh | sh; then
    warn "aider.chat/install.sh failed"
    return 1
  fi
  export PATH="${TARGET_HOME}/.local/bin:${TARGET_HOME}/.cargo/bin:${PATH}"
  _aider_ok
}

# Legacy venv only when a supported interpreter exists (3.10–3.12).
_pick_supported_python() {
  local p ver major minor
  for p in python3.12 python3.11 python3.10 python3; do
    _have_cmd "$p" || continue
    ver="$("$p" -c 'import sys; print("%d.%d"%sys.version_info[:2])' 2>/dev/null || true)"
    [[ -n "${ver}" ]] || continue
    major="${ver%%.*}"
    minor="${ver#*.}"
    if [[ "${major}" -eq 3 && "${minor}" -ge 10 && "${minor}" -lt 13 ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  done
  return 1
}

_method_venv() {
  local py venv_dir
  info "Method: classic venv + pip (Python 3.10–3.12 only)"
  py="$(_pick_supported_python)" || {
    warn "No Python 3.10–3.12 on PATH (system is often 3.13; use uv method)"
    return 1
  }
  info "Using interpreter: ${py} ($("${py}" --version 2>&1))"

  # Ensure ensurepip when possible
  if ! "${py}" -c 'import ensurepip' 2>/dev/null; then
    warn "ensurepip missing — install python3-venv / python3-full"
    _apt_install_prereqs
  fi

  venv_dir="${TARGET_HOME}/venv-aider"
  info "Creating venv at ${venv_dir}"
  rm -rf "${venv_dir}" 2>/dev/null || true
  if ! "${py}" -m venv "${venv_dir}"; then
    warn "venv creation failed"
    return 1
  fi
  # shellcheck disable=SC1091
  source "${venv_dir}/bin/activate"
  export PIP_DISABLE_PIP_VERSION_CHECK=1
  export PIP_NO_CACHE_DIR=1
  python -m pip install -U pip setuptools wheel >/dev/null 2>&1 || true
  if ! python -m pip install -U --upgrade-strategy only-if-needed --prefer-binary aider-chat; then
    warn "pip install aider-chat failed"
    deactivate 2>/dev/null || true
    return 1
  fi
  # Symlink into ~/.local/bin for PATH discovery
  if [[ -x "${venv_dir}/bin/aider" ]]; then
    ln -sfn "${venv_dir}/bin/aider" "${TARGET_HOME}/.local/bin/aider" 2>/dev/null || true
  fi
  deactivate 2>/dev/null || true
  export PATH="${TARGET_HOME}/.local/bin:${venv_dir}/bin:${PATH}"
  _aider_ok
}

# Bootstrap aider-install via ephemeral venv or --break-system-packages (tiny package).
_method_aider_install_pkg() {
  info "Method: pip install aider-install + aider-install"
  _have_cmd python3 || return 1
  _have_cmd curl || true

  local boot="${TARGET_HOME}/.cache/grokhunter/aider-boot-venv"
  mkdir -p "${TARGET_HOME}/.cache/grokhunter" 2>/dev/null || true

  if python3 -c 'import ensurepip' 2>/dev/null; then
    rm -rf "${boot}" 2>/dev/null || true
    python3 -m venv "${boot}" 2>/dev/null || true
  fi

  if [[ -x "${boot}/bin/pip" ]]; then
    "${boot}/bin/pip" install -U aider-install || return 1
    # aider-install uses uv under the hood and respects user home
    if ! "${boot}/bin/aider-install"; then
      warn "aider-install failed"
      return 1
    fi
  else
    # Last resort: user install of tiny bootstrap only
    if ! python3 -m pip install --user --break-system-packages -U aider-install 2>/dev/null; then
      warn "could not pip install aider-install"
      return 1
    fi
    export PATH="${TARGET_HOME}/.local/bin:${PATH}"
    if ! aider-install; then
      warn "aider-install failed"
      return 1
    fi
  fi
  export PATH="${TARGET_HOME}/.local/bin:${PATH}"
  _aider_ok
}

_chown_kali_if_root() {
  if [[ "$(id -u)" -eq 0 ]] && id kali >/dev/null 2>&1; then
    if [[ "${TARGET_HOME}" == /home/kali ]]; then
      chown -R kali:kali \
        "${TARGET_HOME}/.local" \
        "${TARGET_HOME}/venv-aider" \
        2>/dev/null || true
    fi
  fi
}

main() {
  info "Target HOME=${TARGET_HOME} (uid=$(id -u) host=$(uname -m))"

  if _aider_ok && [[ "${GROKHUNTER_FORCE_AIDER:-0}" != "1" ]]; then
    info "Aider already present — skipping (set GROKHUNTER_FORCE_AIDER=1 to reinstall)"
    _report_aider
    return 0
  fi

  _apt_install_prereqs

  local method="${GROKHUNTER_AIDER_METHOD:-auto}"
  local ok=0

  case "${method}" in
    uv)
      _method_uv && ok=1
      ;;
    curl)
      _method_curl && ok=1
      ;;
    venv)
      _method_venv && ok=1
      ;;
    auto)
      if _method_uv; then
        ok=1
      elif _method_curl; then
        ok=1
      elif _method_aider_install_pkg; then
        ok=1
      elif _method_venv; then
        ok=1
      fi
      ;;
    *)
      die "GROKHUNTER_AIDER_METHOD must be auto|uv|venv|curl (got: ${method})"
      ;;
  esac

  _chown_kali_if_root

  if [[ "${ok}" -eq 1 ]] && _aider_ok; then
    _report_aider
    info "Hint: run via aider-grok (sources ~/.grok/secrets.env, model grok-4.5)"
    return 0
  fi

  die "Could not install Aider.

Common causes on Kali NetHunter rootless:
  • System Python is 3.13+ (aider-chat needs <3.13) — we try uv + Python 3.12
  • Missing ensurepip — run:  sudo apt install -y python3-venv python3-full
  • Network / disk — free space, then retry

Manual (inside nethunter):
  curl -LsSf https://aider.chat/install.sh | sh
  # or:
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH=\"\$HOME/.local/bin:\$PATH\"
  uv tool install --force --python 3.12 --with pip aider-chat@latest

Then:  aider-grok
Force reinstall:  GROKHUNTER_FORCE_AIDER=1 bash scripts/install_aider.sh"
}

main "$@"

#!/usr/bin/env bash
# Shared Grok Build installer — used by install (lib/grok.sh) and `grokhunter ensure`.
# Targets Grok Build 1.0.5+ (stable).
#
# Env:
#   GROKHUNTER_GROK_INSTALLER  official | termux-native | auto (default: auto)
#   GROKHUNTER_FORCE_GROK=1    reinstall even if grok is already on PATH
#   GROKHUNTER_MIN_GROK        minimum version (default: 1.0.5)
#   GROKHUNTER_SKIP_PROFILE=1  skip NetHunter config profile merge
#
# Exit: 0 on success (grok on PATH, version ≥ min), 1 on failure.
set -euo pipefail

OFFICIAL_URL="${GROKHUNTER_GROK_OFFICIAL_URL:-https://x.ai/cli/install.sh}"
# Pin Thr45hx termux-native installer to a commit (not floating main).
# Override: GROKHUNTER_GROK_TERMUX_URL=https://raw.githubusercontent.com/…/<sha>/install.sh
TERMUX_NATIVE_PIN="7d17945ee0baa499df66852dce956d614ba685b1"
TERMUX_NATIVE_URL="${GROKHUNTER_GROK_TERMUX_URL:-https://raw.githubusercontent.com/Thr45hx/grok-cli-termux-native/${TERMUX_NATIVE_PIN}/install.sh}"
MIN_VER="${GROKHUNTER_MIN_GROK:-1.0.5}"

info() { echo "[ensure_grok] $*"; }
warn() { echo "[ensure_grok] WARN: $*" >&2; }
die()  { echo "[ensure_grok] ERROR: $*" >&2; exit 1; }

_is_termux() {
  [[ -n "${PREFIX:-}" && "${PREFIX}" == *com.termux* ]] \
    || [[ -d /data/data/com.termux/files/usr ]]
}

_resolve_mode() {
  local mode="${GROKHUNTER_GROK_INSTALLER:-auto}"
  case "${mode}" in
    auto)
      if _is_termux; then
        echo "termux-native"
      else
        echo "official"
      fi
      ;;
    official|termux-native)
      echo "${mode}"
      ;;
    *)
      die "GROKHUNTER_GROK_INSTALLER must be auto|official|termux-native (got: ${mode})"
      ;;
  esac
}

_grok_ok() {
  command -v grok >/dev/null 2>&1
}

_grok_version() {
  # Parse first semver from `grok --version` (e.g. "grok 1.0.5 (…)")
  grok --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true
}

# Return 0 if $1 >= $2 (semver-ish, sort -V)
_version_ge() {
  local have="$1" need="$2"
  [[ -n "${have}" && -n "${need}" ]] || return 1
  printf '%s\n%s\n' "${need}" "${have}" | sort -V | head -1 | grep -qx "${need}"
}

_run_remote_installer() {
  local url="$1"
  local label="$2"
  info "Installing Grok Build via ${label}…"
  info "  URL: ${url}"
  if ! curl -fsSL --connect-timeout 15 --max-time 180 --retry 2 "${url}" | bash; then
    return 1
  fi
  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"
  _grok_ok
}

_try_grok_update() {
  # Prefer in-product updater when binary exists but is below min or force requested.
  if ! _grok_ok; then
    return 1
  fi
  if ! grok update --help >/dev/null 2>&1 && ! grok help update >/dev/null 2>&1; then
    # Still try plain `grok update` — many builds accept it.
    :
  fi
  info "Trying in-product upgrade: grok update…"
  if grok update 2>&1; then
    export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"
    return 0
  fi
  return 1
}

_apply_profile() {
  if [[ "${GROKHUNTER_SKIP_PROFILE:-0}" == "1" ]]; then
    return 0
  fi
  local root script
  root="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd 2>/dev/null || true)"
  script="${root}/scripts/install_grok_profile.sh"
  if [[ -f "${script}" ]]; then
    info "Applying GrokHunter 1.0.5 NetHunter profile…"
    bash "${script}" || warn "profile merge had issues (non-fatal)"
  fi
}

main() {
  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"

  local have="" need_install=0
  if _grok_ok; then
    have="$(_grok_version)"
    info "Found grok: $(command -v grok) ${have:+(v${have})}"
    if [[ "${GROKHUNTER_FORCE_GROK:-0}" == "1" ]]; then
      info "GROKHUNTER_FORCE_GROK=1 — reinstalling"
      need_install=1
    elif [[ -z "${have}" ]]; then
      warn "Could not parse version — will reinstall to ensure ≥ ${MIN_VER}"
      need_install=1
    elif _version_ge "${have}" "${MIN_VER}"; then
      info "Grok Build ${have} already ≥ ${MIN_VER}"
      grok --version 2>/dev/null | head -1 || true
      _apply_profile
      return 0
    else
      info "Grok Build ${have} < min ${MIN_VER} — upgrading"
      need_install=1
    fi
  else
    need_install=1
  fi

  if [[ "${need_install}" -eq 0 ]]; then
    _apply_profile
    return 0
  fi

  command -v curl >/dev/null 2>&1 || die "curl is required"
  command -v bash >/dev/null 2>&1 || die "bash is required"

  # Prefer in-product update when an older binary is already present
  if _grok_ok && [[ "${GROKHUNTER_FORCE_GROK:-0}" != "1" || -n "${have}" ]]; then
    if _try_grok_update; then
      have="$(_grok_version)"
      if [[ -n "${have}" ]] && _version_ge "${have}" "${MIN_VER}"; then
        info "OK via grok update — v${have}"
        _apply_profile
        return 0
      fi
      warn "grok update finished but version still < ${MIN_VER} (${have:-unknown}) — full reinstall"
    fi
  fi

  local mode primary_url primary_label fallback_url fallback_label
  mode="$(_resolve_mode)"

  if [[ "${mode}" == "termux-native" ]]; then
    primary_url="${TERMUX_NATIVE_URL}"
    primary_label="Termux-native installer"
    fallback_url="${OFFICIAL_URL}"
    fallback_label="official xAI installer"
  else
    primary_url="${OFFICIAL_URL}"
    primary_label="official xAI installer"
    fallback_url="${TERMUX_NATIVE_URL}"
    fallback_label="Termux-native installer"
  fi

  if _run_remote_installer "${primary_url}" "${primary_label}"; then
    :
  else
    warn "${primary_label} failed — trying ${fallback_label}"
    if ! _run_remote_installer "${fallback_url}" "${fallback_label}"; then
      die "Could not install Grok Build. Manual:
  curl -fsSL ${OFFICIAL_URL} | bash
  # Termux aarch64 fallback:
  curl -fsSL ${TERMUX_NATIVE_URL} | bash
  export PATH=\"\$HOME/.grok/bin:\$HOME/.local/bin:\$PATH\"
  grok --version   # expect ≥ ${MIN_VER}"
    fi
  fi

  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"
  have="$(_grok_version)"
  if [[ -z "${have}" ]]; then
    die "grok installed but version unreadable"
  fi
  if ! _version_ge "${have}" "${MIN_VER}"; then
    die "Grok Build ${have} is still < required ${MIN_VER}.
  Try:  grok update
  Or:   GROKHUNTER_FORCE_GROK=1 bash scripts/ensure_grok.sh
  Official: curl -fsSL ${OFFICIAL_URL} | bash"
  fi

  info "OK — $(command -v grok) v${have}"
  grok --version 2>/dev/null | head -1 || true
  _apply_profile
}

main "$@"

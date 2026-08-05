#!/usr/bin/env bash
# Shared Grok Build installer — used by install (lib/grok.sh) and `grokhunter ensure`.
#
# Env:
#   GROKHUNTER_GROK_INSTALLER  official | termux-native | auto (default: auto)
#   GROKHUNTER_FORCE_GROK=1    reinstall even if grok is already on PATH
#
# Exit: 0 on success (grok on PATH or freshly installed), 1 on failure.
set -euo pipefail

OFFICIAL_URL="${GROKHUNTER_GROK_OFFICIAL_URL:-https://x.ai/cli/install.sh}"
TERMUX_NATIVE_URL="${GROKHUNTER_GROK_TERMUX_URL:-https://raw.githubusercontent.com/Thr45hx/grok-cli-termux-native/main/install.sh}"

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

_run_remote_installer() {
  local url="$1"
  local label="$2"
  info "Installing Grok Build via ${label}…"
  info "  URL: ${url}"
  # Stream to bash (same pattern as upstream CLIs). Prefer clone install for auditability.
  if ! curl -fsSL --connect-timeout 15 --max-time 180 --retry 2 "${url}" | bash; then
    return 1
  fi
  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"
  _grok_ok
}

main() {
  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"

  if _grok_ok && [[ "${GROKHUNTER_FORCE_GROK:-0}" != "1" ]]; then
    info "Grok already present: $(command -v grok)"
    grok --version 2>/dev/null | head -1 || true
    return 0
  fi

  command -v curl >/dev/null 2>&1 || die "curl is required"
  command -v bash >/dev/null 2>&1 || die "bash is required"

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
    info "OK — $(command -v grok)"
    grok --version 2>/dev/null | head -1 || true
    return 0
  fi

  warn "${primary_label} failed — trying ${fallback_label}"
  if _run_remote_installer "${fallback_url}" "${fallback_label}"; then
    info "OK via fallback — $(command -v grok)"
    grok --version 2>/dev/null | head -1 || true
    return 0
  fi

  die "Could not install Grok Build. Manual:
  curl -fsSL ${OFFICIAL_URL} | bash
  # Termux aarch64 fallback:
  curl -fsSL ${TERMUX_NATIVE_URL} | bash
  export PATH=\"\$HOME/.grok/bin:\$HOME/.local/bin:\$PATH\""
}

main "$@"

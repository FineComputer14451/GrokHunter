#!/usr/bin/env bash
# HTTPS reachability for grokhunter doctor.
# curl -f treats Cloudflare 403 / unauthenticated 401 as failure even when
# DNS + TLS work. Any 1xx–5xx means the lab reached the host.

_gh_http_code_means_reachable() {
  case "${1:-}" in
    [1-9][0-9][0-9]) return 0 ;;
    *) return 1 ;;
  esac
}

if ! declare -F _gh_tls_sanitize_env >/dev/null 2>&1; then
  _gh_tls="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/tls.sh"
  if [[ -f "${_gh_tls}" ]]; then
    # shellcheck source=lib/tls.sh
    source "${_gh_tls}"
  fi
  unset _gh_tls
fi

_gh_https_got_response() {
  local url="${1:-}" code=""
  [[ -n "${url}" ]] || return 1
  command -v curl >/dev/null 2>&1 || return 1
  _gh_tls_sanitize_env
  code="$(curl -sS --max-time "${GROKHUNTER_HTTPS_PROBE_TIMEOUT:-5}" \
    -o /dev/null -w '%{http_code}' "${url}" 2>/dev/null || true)"
  _gh_http_code_means_reachable "${code}"
}

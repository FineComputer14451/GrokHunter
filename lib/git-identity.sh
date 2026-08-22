#!/usr/bin/env bash
# Git identity helpers — keep GitHub from mapping commits to invalid-email-address.
# Sourced by grokhunter / grokhunter-doctor. Idempotent.

_gh_git_identity_is_placeholder() {
  local name="${1:-}" email="${2:-}"
  local n e
  n="$(printf '%s' "${name}" | tr '[:upper:]' '[:lower:]')"
  e="$(printf '%s' "${email}" | tr '[:upper:]' '[:lower:]')"
  if [[ -z "${n}" && -z "${e}" ]]; then
    return 0
  fi
  case "${n}" in
    root) return 0 ;;
  esac
  case "${e}" in
    ""|*@localhost|*@localhost.*|root@*) return 0 ;;
  esac
  return 1
}

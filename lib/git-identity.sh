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

_gh_git_cfg() {
  local key="$1"
  git config --global --get "${key}" 2>/dev/null \
    || git config --get "${key}" 2>/dev/null \
    || true
}

_gh_git_identity_name()  { _gh_git_cfg user.name; }
_gh_git_identity_email() { _gh_git_cfg user.email; }

_gh_git_identity_from_gh() {
  # Prints "name<TAB>email". Uses gh if authenticated.
  command -v gh >/dev/null 2>&1 || return 1
  local json login id display
  json="$(gh api user --jq '[.login,.id,(.name // .login)] | @tsv' 2>/dev/null)" || return 1
  login="$(printf '%s' "${json}" | awk -F'\t' '{print $1}')"
  id="$(printf '%s' "${json}" | awk -F'\t' '{print $2}')"
  display="$(printf '%s' "${json}" | awk -F'\t' '{print $3}')"
  [[ -n "${login}" && -n "${id}" ]] || return 1
  [[ -n "${display}" ]] || display="${login}"
  printf '%s\t%s\n' "${display}" "${id}+${login}@users.noreply.github.com"
}

_gh_git_identity_set() {
  local name="$1" email="$2" scope="${3:-global}"
  [[ -n "${name}" && -n "${email}" ]] || return 1
  case "${scope}" in
    global|local) ;;
    *) return 1 ;;
  esac
  git config --"${scope}" user.name "${name}"
  git config --"${scope}" user.email "${email}"
}

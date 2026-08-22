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

_gh_git_identity_github_login_from_url() {
  # Extract GitHub owner from a remote URL. Prints login or returns 1.
  local url="${1:-}" path login
  [[ -n "${url}" ]] || return 1
  url="${url%%[[:space:]]*}"
  url="${url%.git}"
  case "${url}" in
    git@github.com:*)
      path="${url#git@github.com:}"
      ;;
    https://github.com/*|http://github.com/*|https://www.github.com/*|http://www.github.com/*)
      path="${url#*github.com/}"
      path="${path#/}"
      ;;
    ssh://git@github.com/*|ssh://github.com/*)
      path="${url#*github.com/}"
      path="${path#/}"
      ;;
    *)
      return 1
      ;;
  esac
  path="${path%%\?*}"
  login="${path%%/*}"
  [[ -n "${login}" && "${login}" != "${path}" ]] || return 1
  case "${login}" in
    ""|.*|*:*|*@*) return 1 ;;
  esac
  printf '%s\n' "${login}"
}

_gh_git_identity_pair_from_user_json() {
  # GitHub user JSON → "display<TAB>ID+login@users.noreply.github.com"
  local json="${1:-}" parsed login id display
  [[ -n "${json}" ]] || return 1
  if command -v python3 >/dev/null 2>&1; then
    parsed="$(printf '%s' "${json}" | python3 -c '
import json, sys
raw = sys.stdin.read()
try:
    d = json.loads(raw)
except Exception:
    sys.exit(1)
if not isinstance(d, dict):
    sys.exit(1)
login = d.get("login") or ""
uid = d.get("id")
name = d.get("name") or login
if not login or uid is None:
    sys.exit(1)
print("%s\t%s\t%s" % (login, uid, name))
' 2>/dev/null)" || return 1
  else
    login="$(printf '%s\n' "${json}" | sed -n 's/^[[:space:]]*"login":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    id="$(printf '%s\n' "${json}" | sed -n 's/^[[:space:]]*"id":[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n 1)"
    display="$(printf '%s\n' "${json}" | sed -n 's/^[[:space:]]*"name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
    [[ -n "${login}" && -n "${id}" ]] || return 1
    parsed="$(printf '%s\t%s\t%s\n' "${login}" "${id}" "${display:-${login}}")"
  fi
  login="$(printf '%s' "${parsed}" | awk -F'\t' '{print $1}')"
  id="$(printf '%s' "${parsed}" | awk -F'\t' '{print $2}')"
  display="$(printf '%s' "${parsed}" | awk -F'\t' '{print $3}')"
  [[ -n "${login}" && -n "${id}" ]] || return 1
  [[ -n "${display}" ]] || display="${login}"
  printf '%s\t%s\n' "${display}" "${id}+${login}@users.noreply.github.com"
}

_gh_git_identity_curl_github() {
  # $1 = API path beginning with /  (e.g. /user or /users/login)
  local path="${1:-}" token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
  local -a args
  [[ "${path}" == /* ]] || return 1
  command -v curl >/dev/null 2>&1 || return 1
  args=(-sS --max-time "${GROKHUNTER_GIT_IDENTITY_TIMEOUT:-8}"
        -H "Accept: application/vnd.github+json"
        -H "User-Agent: GrokHunter-git-identity")
  if [[ -n "${token}" ]]; then
    args+=(-H "Authorization: Bearer ${token}")
  fi
  curl "${args[@]}" "https://api.github.com${path}" 2>/dev/null
}

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

_gh_git_identity_from_token() {
  local json
  [[ -n "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ]] || return 1
  json="$(_gh_git_identity_curl_github /user)" || return 1
  _gh_git_identity_pair_from_user_json "${json}"
}

_gh_git_identity_from_origin() {
  local url login json
  command -v git >/dev/null 2>&1 || return 1
  url="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -z "${url}" && -n "${GROKHUNTER_HOME:-}" ]]; then
    url="$(git -C "${GROKHUNTER_HOME}" remote get-url origin 2>/dev/null || true)"
  fi
  login="$(_gh_git_identity_github_login_from_url "${url}")" || return 1
  json="$(_gh_git_identity_curl_github "/users/${login}")" || return 1
  _gh_git_identity_pair_from_user_json "${json}"
}

_gh_git_identity_resolve() {
  local pair
  if pair="$(_gh_git_identity_from_gh)"; then
    printf '%s\n' "${pair}"
    return 0
  fi
  if pair="$(_gh_git_identity_from_token)"; then
    printf '%s\n' "${pair}"
    return 0
  fi
  if pair="$(_gh_git_identity_from_origin)"; then
    printf '%s\n' "${pair}"
    return 0
  fi
  return 1
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

#!/usr/bin/env bash
# GrokHunter — role discovery (single source)
# Product roles: roles/<name>.toml → ~/.grok/roles/<name>.toml

_gh_list_role_names() {
  local root="${1:-}" f name
  [[ -n "${root}" && -d "${root}/roles" ]] || return 0
  local -a names=()
  for f in "${root}/roles"/*.toml; do
    [[ -f "${f}" ]] || continue
    name="${f##*/}"
    name="${name%.toml}"
    [[ "${name}" == _* ]] && continue
    [[ "${name}" == "README" || "${name}" == "readme" ]] && continue
    names+=("${name}")
  done
  if [[ ${#names[@]} -eq 0 ]]; then
    return 0
  fi
  printf '%s\n' "${names[@]}" | LC_ALL=C sort -u
}

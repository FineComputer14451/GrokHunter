#!/usr/bin/env bash
# GrokHunter — persona discovery (single source)
# Product personas: personas/<name>.toml → ~/.grok/personas/<name>.toml

# List product persona basenames (no .toml) under <root>/personas/*.toml.
# Skips _* and README. Prints one name per line, sorted.
_gh_list_persona_names() {
  local root="${1:-}" f name
  [[ -n "${root}" && -d "${root}/personas" ]] || return 0
  local -a names=()
  for f in "${root}/personas"/*.toml; do
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

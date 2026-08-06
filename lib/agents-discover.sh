#!/usr/bin/env bash
# GrokHunter — Coding Team agent discovery (single source)
# Sourced by lib/grok.sh, bin/grokhunter-doctor, uninstall.sh.
# Product agents are Grok Build agent defs: agents/<name>.md → ~/.grok/agents/<name>.md

# List product agent basenames (no .md) under <root>/agents/*.md.
# Skips _* and README.md. Prints one name per line, sorted.
_gh_list_agent_names() {
  local root="${1:-}" f name
  [[ -n "${root}" && -d "${root}/agents" ]] || return 0
  local -a names=()
  for f in "${root}/agents"/*.md; do
    [[ -f "${f}" ]] || continue
    name="${f##*/}"
    name="${name%.md}"
    [[ "${name}" == _* ]] && continue
    [[ "${name}" == "README" || "${name}" == "readme" ]] && continue
    names+=("${name}")
  done
  if [[ ${#names[@]} -eq 0 ]]; then
    return 0
  fi
  printf '%s\n' "${names[@]}" | LC_ALL=C sort -u
}

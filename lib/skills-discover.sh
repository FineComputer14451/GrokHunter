#!/usr/bin/env bash
# GrokHunter — skill discovery (single source of truth)
# Sourced by lib/grok.sh, bin/grokhunter, bin/grokhunter-doctor, uninstall.sh.
# Safe to source multiple times.

# Core coding-lab skills (status N/3 + doctor required). Order is display-stable.
GH_CORE_SKILLS=(grokhunter pair-programming aider-grok)

# List product skill names under <root>/skills (dirs with SKILL.md; skip _*).
# Prints one name per line, sorted. Empty if none.
_gh_list_skill_names() {
  local root="${1:-}" d name
  [[ -n "${root}" && -d "${root}/skills" ]] || return 0
  local -a names=()
  for d in "${root}/skills"/*/; do
    [[ -d "${d}" ]] || continue
    name="${d%/}"
    name="${name##*/}"
    [[ "${name}" == _* ]] && continue
    [[ -f "${d}SKILL.md" ]] || continue
    names+=("${name}")
  done
  if [[ ${#names[@]} -eq 0 ]]; then
    return 0
  fi
  printf '%s\n' "${names[@]}" | LC_ALL=C sort -u
}

# True if $1 is a core skill name.
_gh_is_core_skill() {
  local s="${1:-}" c
  [[ -n "${s}" ]] || return 1
  for c in "${GH_CORE_SKILLS[@]}"; do
    [[ "${s}" == "${c}" ]] && return 0
  done
  return 1
}

# Count how many core skills are installed under ~/.grok/skills (or $1 home).
_gh_count_core_installed() {
  local home="${1:-${HOME}}"
  local s n=0
  for s in "${GH_CORE_SKILLS[@]}"; do
    [[ -f "${home}/.grok/skills/${s}/SKILL.md" ]] && n=$((n + 1))
  done
  printf '%s\n' "${n}"
}

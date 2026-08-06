#!/usr/bin/env bash
# GrokHunter uninstall — removes overlay; keeps Grok binary unless --purge-grok
set -euo pipefail

PURGE_GROK=0
if [[ "${1:-}" == "--purge-grok" ]]; then
  PURGE_GROK=1
fi

BIN_DIR="${HOME}/.local/bin"
SKILLS_DIR="${HOME}/.grok/skills"
MARKER_BEGIN="# >>> grokhunter >>>"
MARKER_END="# <<< grokhunter <<<"

# Overlay root (script directory) + skill discovery
_GH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
if [[ -f "${_GH_ROOT}/lib/skills-discover.sh" ]]; then
  # shellcheck source=lib/skills-discover.sh
  source "${_GH_ROOT}/lib/skills-discover.sh"
fi

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

remove_bins() {
  for b in grokhunter grok-nethunter grokhunter-doctor aider-grok nh-x11; do
    if [[ -f "${BIN_DIR}/${b}" ]]; then
      rm -f "${BIN_DIR}/${b}"
      log "Removed ${BIN_DIR}/${b}"
    fi
  done
  # Termux PREFIX copies (if present)
  local prefix_bin="${PREFIX:-}/bin"
  if [[ -n "${PREFIX:-}" && -d "${prefix_bin}" ]]; then
    for b in grokhunter grok-nethunter grokhunter-doctor; do
      if [[ -f "${prefix_bin}/${b}" ]]; then
        rm -f "${prefix_bin}/${b}"
        log "Removed ${prefix_bin}/${b}"
      fi
    done
  fi
}

remove_skills() {
  local name
  if [[ ! -d "${_GH_ROOT}/skills" ]]; then
    # No product tree next to uninstall.sh — do not guess skill names
    warn "No skills/ next to uninstall.sh — leaving ~/.grok/skills unchanged"
    return 0
  fi
  if ! declare -F _gh_list_skill_names >/dev/null 2>&1; then
    warn "skill discovery missing — leaving ~/.grok/skills unchanged"
    return 0
  fi
  while IFS= read -r name; do
    [[ -n "${name}" ]] || continue
    if [[ -d "${SKILLS_DIR}/${name}" ]]; then
      rm -rf "${SKILLS_DIR}/${name}"
      log "Removed skill ${name}"
    fi
  done < <(_gh_list_skill_names "${_GH_ROOT}")
}

strip_shell() {
  for target in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
    [[ -f "$target" ]] || continue
    if grep -qF "$MARKER_BEGIN" "$target" 2>/dev/null; then
      python3 -c '
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
begin, end = "# >>> grokhunter >>>", "# <<< grokhunter <<<"
pat = re.compile(r"\n?" + re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
text2 = pat.sub("\n", text)
open(path, "w", encoding="utf-8").write(text2)
' "$target"
      log "Stripped markers from $target"
    fi
  done
}

remove_motd() {
  if [[ -f /etc/update-motd.d/99-grokhunter ]]; then
    if [[ "$(id -u)" -eq 0 ]]; then
      rm -f /etc/update-motd.d/99-grokhunter
      log "Removed system MOTD"
    elif command -v sudo >/dev/null 2>&1; then
      sudo rm -f /etc/update-motd.d/99-grokhunter && log "Removed system MOTD" || warn "Could not remove /etc MOTD"
    fi
  fi
  rm -f "${HOME}/.grokhunter/99-grokhunter.motd" 2>/dev/null || true
}

remove_meta() {
  rm -rf "${HOME}/.grokhunter"
  log "Removed ~/.grokhunter"
}

remove_cache() {
  # Module + termux-distro engine cache (safe; re-fetched on next install)
  if [[ -d "${HOME}/.cache/grokhunter" ]]; then
    rm -rf "${HOME}/.cache/grokhunter"
    log "Removed ~/.cache/grokhunter"
  fi
}

restore_launcher_backups() {
  local prefix="${PREFIX:-/data/data/com.termux/files/usr}"
  local f bak
  for f in "${prefix}/bin/nethunter" "${prefix}/bin/nh"; do
    bak="${f}.grokhunter.bak"
    if [[ -f "${bak}" && -f "${f}" ]]; then
      if mv -f "${bak}" "${f}" 2>/dev/null; then
        log "Restored launcher from ${bak}"
      else
        warn "Could not restore ${bak}"
      fi
    fi
  done
  # nh-x11 helper
  if [[ -f "${prefix}/bin/nh-x11" ]]; then
    rm -f "${prefix}/bin/nh-x11"
    log "Removed nh-x11"
  fi
}

purge_grok() {
  warn "Purging Grok Build state under ~/.grok (auth, binary, config)…"
  # Keep a last-chance backup of config
  if [[ -f "${HOME}/.grok/config.toml" ]]; then
    cp -a "${HOME}/.grok/config.toml" "${HOME}/.grok-config.toml.pre-purge-$(date +%Y%m%d)" || true
  fi
  rm -rf "${HOME}/.grok/bin" "${HOME}/.grok/downloads" "${HOME}/.grok/versions" 2>/dev/null || true
  warn "Left ~/.grok (skills/plugins/sessions). Delete manually if desired: rm -rf ~/.grok"
}

main() {
  echo "Uninstalling GrokHunter overlay…"
  remove_bins
  remove_skills
  strip_shell
  remove_motd
  remove_meta
  remove_cache
  restore_launcher_backups
  if [[ "$PURGE_GROK" -eq 1 ]]; then
    purge_grok
  else
    log "Kept Grok Build binary and ~/.grok (use --purge-grok to strip binary dirs)"
  fi
  log "Done. Open a new shell to refresh PATH/aliases."
  log "Note: Kali rootfs (nethunter) is left in place; remove separately if desired."
}

main "$@"

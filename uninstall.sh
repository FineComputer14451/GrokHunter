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

log() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }

remove_bins() {
  for b in grokhunter grok-nethunter grokhunter-doctor; do
    if [[ -f "${BIN_DIR}/${b}" ]]; then
      rm -f "${BIN_DIR}/${b}"
      log "Removed ${BIN_DIR}/${b}"
    fi
  done
}

remove_skills() {
  for s in grokhunter nethunter-recon; do
    if [[ -d "${SKILLS_DIR}/${s}" ]]; then
      rm -rf "${SKILLS_DIR}/${s}"
      log "Removed skill ${s}"
    fi
  done
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
  if [[ "$PURGE_GROK" -eq 1 ]]; then
    purge_grok
  else
    log "Kept Grok Build binary and ~/.grok (use --purge-grok to strip binary dirs)"
  fi
  log "Done. Open a new shell to refresh PATH/aliases."
}

main "$@"

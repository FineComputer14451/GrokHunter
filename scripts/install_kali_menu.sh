#!/usr/bin/env bash
# Install / remove GrokHunter entries in the Kali (XFCE) application menu.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
SRC="${ROOT}/config/desktop"
REMOVE=0

info() { echo "[install_kali_menu] $*"; }
warn() { echo "[install_kali_menu] WARN: $*" >&2; }
die()  { echo "[install_kali_menu] ERROR: $*" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --remove|-r) REMOVE=1 ;;
    --help|-h)
      cat <<'EOF'
Usage: bash scripts/install_kali_menu.sh [--remove]

  Install  GrokHunter submenu + .desktop apps for Kali/XFCE menus
  --remove Remove installed menu files (product entries only)
EOF
      exit 0
      ;;
    *) die "Unknown option: $arg" ;;
  esac
done

APPS="${HOME}/.local/share/applications"
DIRS="${HOME}/.local/share/desktop-directories"
MENUS="${HOME}/.config/menus/applications-merged"
BIN="${HOME}/.local/bin"

remove_menu() {
  local f
  mkdir -p "${APPS}" "${DIRS}" "${MENUS}" 2>/dev/null || true
  for f in \
    "${APPS}"/grokhunter-*.desktop \
    "${DIRS}/grokhunter.directory" \
    "${MENUS}/grokhunter.menu"
  do
    if [[ -e "${f}" ]]; then
      rm -f "${f}"
      info "Removed ${f}"
    fi
  done
  rm -f "${BIN}/grokhunter-desktop-run" 2>/dev/null || true
  update-desktop-database "${APPS}" 2>/dev/null || true
  info "GrokHunter Kali menu entries removed"
}

install_menu() {
  [[ -d "${SRC}" ]] || die "Missing ${SRC}"
  mkdir -p "${APPS}" "${DIRS}" "${MENUS}" "${BIN}"

  # Launcher used by Exec= lines
  if [[ -f "${ROOT}/bin/grokhunter-desktop-run" ]]; then
    if command -v install >/dev/null 2>&1; then
      install -m 755 "${ROOT}/bin/grokhunter-desktop-run" "${BIN}/grokhunter-desktop-run"
    else
      cp -f "${ROOT}/bin/grokhunter-desktop-run" "${BIN}/grokhunter-desktop-run"
      chmod 755 "${BIN}/grokhunter-desktop-run"
    fi
    info "Installed ${BIN}/grokhunter-desktop-run"
  else
    die "bin/grokhunter-desktop-run missing"
  fi

  # Ensure PATH in desktop env: wrap Exec to use absolute runner when possible
  local run="${BIN}/grokhunter-desktop-run"
  local f base
  for f in "${SRC}"/grokhunter-*.desktop; do
    [[ -f "${f}" ]] || continue
    base="$(basename "${f}")"
    # Rewrite every Exec line to use absolute runner path (DE often has minimal PATH)
    sed "s|grokhunter-desktop-run|${run}|g" "${f}" > "${APPS}/${base}"
    chmod 644 "${APPS}/${base}"
    info "Installed ${APPS}/${base}"
  done

  cp -f "${SRC}/grokhunter.directory" "${DIRS}/grokhunter.directory"
  chmod 644 "${DIRS}/grokhunter.directory"
  info "Installed ${DIRS}/grokhunter.directory"

  cp -f "${SRC}/grokhunter.menu" "${MENUS}/grokhunter.menu"
  chmod 644 "${MENUS}/grokhunter.menu"
  info "Installed ${MENUS}/grokhunter.menu"

  update-desktop-database "${APPS}" 2>/dev/null || true
  # Hint XFCE panel to pick up menu changes when available
  if command -v xfce4-panel >/dev/null 2>&1; then
    xfce4-panel -r 2>/dev/null || true
  fi

  info "Done. Look for Applications → GrokHunter (log out/in if needed)."
  info "  Grok Build · Coding Team · Scout · Aider · Doctor · Setup"
}

if [[ "${REMOVE}" -eq 1 ]]; then
  remove_menu
else
  install_menu
fi

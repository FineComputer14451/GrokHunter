#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Termux:X11 low-latency desktop + proot bind optimizers

GROKHUNTER_BINDS_MARK="# grokhunter-optimized-binds"
TERMUX_FILES_DIR="${TERMUX_FILES_DIR:-/data/data/com.termux/files}"
TERMUX_HOME="${TERMUX_FILES_DIR}/home"
TERMUX_TMP="${TERMUX_FILES_DIR}/usr/tmp"
GROK_WORKSPACE="${TERMUX_HOME}/grok-workspace"

# Recommended extra binds for GrokHunter Rootless
# (core /dev /proc /sys are assumed to already exist in the launcher)
_GROKHUNTER_EXTRA_BINDS=(
  "-b ${TERMUX_TMP}:/tmp"
  "-b /sdcard"
  "-b ${TERMUX_HOME}/storage/downloads:/downloads"
  "-b ${TERMUX_HOME}:/termux-home"
  "-b ${GROK_WORKSPACE}:/workspace"
)

_ensure_workspace() {
  mkdir -p "${GROK_WORKSPACE}" 2>/dev/null || true
}

_patch_launcher_binds() {
  local f="$1"
  [[ -f "${f}" ]] || return 0

  # Already patched?
  if grep -q "${GROKHUNTER_BINDS_MARK}" "${f}" 2>/dev/null; then
    msg -ts "${f##*/}: binds OK"
    return 0
  fi

  # Backup once
  if [[ ! -f "${f}.grokhunter.bak" ]]; then
    cp -a "${f}" "${f}.grokhunter.bak" 2>/dev/null || true
  fi

  # Only attempt if a -b /dev line exists (standard nethunter launcher shape)
  if ! grep -q -- "-b /dev" "${f}"; then
    msg -tw "Could not auto-patch ${f##*/} (no '-b /dev' anchor found)"
    return 1
  fi

  _ensure_workspace

  # Build the block we will insert after the first "-b /dev" line
  local insert_block="${GROKHUNTER_BINDS_MARK}"
  local b
  for b in "${_GROKHUNTER_EXTRA_BINDS[@]}"; do
    insert_block="${insert_block}
        ${b} \\"
  done

  # Insert after the line that contains "-b /dev"
  if sed -i "/-b \\\/dev/{
a\\
${insert_block}
}" "${f}" 2>/dev/null; then
    if grep -q "${GROKHUNTER_BINDS_MARK}" "${f}" 2>/dev/null; then
      msg -ts "Patched ${f##*/} with optimized binds"
      return 0
    fi
  fi

  msg -tw "Could not auto-patch ${f##*/}"
  msg -a "  Backup: ${f}.grokhunter.bak (if created)"
  msg -a "  Manually add after '-b /dev':"
  for b in "${_GROKHUNTER_EXTRA_BINDS[@]}"; do
    msg -a "    ${b} \\"
  done
  return 1
}

save_x11_session() {
  local session_cmd="${1:-startxfce4}"
  local cfg_dir="${HOME}/.config/grokhunter"
  mkdir -p "${cfg_dir}" 2>/dev/null || true
  printf '%s\n' "${session_cmd}" > "${cfg_dir}/x11-session" 2>/dev/null || true
  if [[ -n "${TERMUX_FILES_DIR:-}" ]]; then
    mkdir -p "${TERMUX_FILES_DIR}/home/.config/grokhunter" 2>/dev/null || true
    printf '%s\n' "${session_cmd}" \
      > "${TERMUX_FILES_DIR}/home/.config/grokhunter/x11-session" 2>/dev/null || true
  fi
}

# Canonical nh-x11 lives in bin/nh-x11 (install copies; no heredoc drift).
_resolve_overlay_file() {
  local rel="$1"
  local d
  for d in "${SCRIPT_DIR:-}" "${GROKHUNTER_HOME:-}" "${HOME}/GrokHunter"; do
    if [[ -n "${d}" && -f "${d}/${rel}" ]]; then
      printf '%s\n' "${d}/${rel}"
      return 0
    fi
  done
  return 1
}

_install_repo_bin() {
  local rel="$1"
  local dest="$2"
  local src
  if ! src="$(_resolve_overlay_file "${rel}")"; then
    msg -tw "Missing repo file: ${rel}"
    return 1
  fi
  mkdir -p "$(dirname "${dest}")" 2>/dev/null || true
  if command -v install >/dev/null 2>&1; then
    install -m 755 "${src}" "${dest}" || cp -f "${src}" "${dest}"
  else
    cp -f "${src}" "${dest}"
  fi
  chmod 755 "${dest}" 2>/dev/null || true
  return 0
}

setup_termux_x11() {
  msg -t "Setting up Termux:X11 (low-latency desktop)"

  msg -tn "Installing x11-repo, termux-x11-nightly and pulseaudio..."
  if pkg install -y x11-repo >/dev/null 2>&1 && \
     pkg install -y termux-x11-nightly pulseaudio >/dev/null 2>&1; then
    cursor -u1
    msg -ts "Termux:X11 packages installed"
  else
    cursor -u1
    msg -tw "Failed to install some X11 packages — run: pkg install x11-repo termux-x11-nightly pulseaudio"
  fi

  local launcher="${TERMUX_FILES_DIR}/usr/bin/nethunter"
  local shortcut="${TERMUX_FILES_DIR}/usr/bin/nh"
  for f in "${launcher}" "${shortcut}"; do
    _patch_launcher_binds "${f}" || true
  done

  local helper="${TERMUX_FILES_DIR}/usr/bin/nh-x11"
  if _install_repo_bin "bin/nh-x11" "${helper}"; then
    msg -ts "Installed helper: nh-x11 (from repo bin/nh-x11)"
  else
    msg -tw "Could not install nh-x11 — clone repo or ensure bin/nh-x11 is present"
  fi
  msg -a "  Session: NH_X11_SESSION or ~/.config/grokhunter/x11-session"
  optimize_proot_binds 2>/dev/null || true

  echo
  msg -a "  ${T:-}Usage:${S:-}"
  msg -a "    1. Install Termux:X11 APK (prefer sharedUid if Termux is from GitHub)"
  msg -a "    2. Run:  ${P:-}nh-x11${S:-}"
  msg -a "    Override DE:  ${P:-}NH_X11_SESSION=startxfce4 nh-x11${S:-}"
  msg -a "    Black screen?  ${P:-}NH_X11_LEGACY=1 nh-x11${S:-}"
  msg -a "  ${T:-}Tips:${S:-} docs/X11-PERFORMANCE.md  docs/PROOT.md"
}

optimize_proot_binds() {
  msg -t "Optimizing proot binds on nethunter launcher"
  _ensure_workspace
  local launcher="${TERMUX_FILES_DIR}/usr/bin/nethunter"
  local shortcut="${TERMUX_FILES_DIR}/usr/bin/nh"
  for f in "${launcher}" "${shortcut}"; do
    _patch_launcher_binds "${f}" || true
  done
  msg -a "  Binds: /tmp, /sdcard, /downloads, /termux-home, /workspace"
  msg -a "  Tip: keep rootfs on internal storage; see docs/PROOT.md"
}

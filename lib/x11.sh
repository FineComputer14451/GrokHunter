#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Termux:X11 low-latency desktop + proot bind optimizers

# Marker base must remain "grokhunter-optimized-binds" (ci-unit greps it).
# Version suffix lets us detect stale blocks and re-patch safely.
GROKHUNTER_BINDS_MARK_BASE="# grokhunter-optimized-binds"
GROKHUNTER_BINDS_VERSION="2"
GROKHUNTER_BINDS_MARK="${GROKHUNTER_BINDS_MARK_BASE} v${GROKHUNTER_BINDS_VERSION}"

TERMUX_FILES_DIR="${TERMUX_FILES_DIR:-/data/data/com.termux/files}"
TERMUX_HOME="${TERMUX_FILES_DIR}/home"
TERMUX_TMP="${TERMUX_FILES_DIR}/usr/tmp"
GROK_WORKSPACE="${TERMUX_HOME}/grok-workspace"

# Recommended extra binds for GrokHunter Rootless
# (core /dev /proc /sys are assumed to already exist in the launcher)
_ensure_workspace() {
  mkdir -p "${GROK_WORKSPACE}" 2>/dev/null || true
  mkdir -p "${TERMUX_TMP}" 2>/dev/null || true
}

# Optional user extra binds: one "-b host[:guest]" per line (comments/# ok).
# Checked in Termux home first, then current HOME.
_gh_user_extra_binds_file() {
  local f
  for f in \
    "${TERMUX_HOME}/.config/grokhunter/extra-binds" \
    "${HOME:-}/.config/grokhunter/extra-binds"; do
    if [[ -n "${f}" && -r "${f}" ]]; then
      printf '%s\n' "${f}"
      return 0
    fi
  done
  return 1
}

# Desired -b lines whose host path exists (missing /sdcard must not break nethunter).
# Includes optional user lines from extra-binds config.
_gh_extra_bind_lines() {
  local -a lines=()
  local user_file line host
  _ensure_workspace
  if [[ -d "${TERMUX_TMP}" ]]; then
    lines+=("-b ${TERMUX_TMP}:/tmp")
  fi
  if [[ -e /sdcard ]]; then
    lines+=("-b /sdcard")
  elif [[ -d /storage/emulated/0 ]]; then
    lines+=("-b /storage/emulated/0:/sdcard")
  fi
  if [[ -d "${TERMUX_HOME}/storage/downloads" ]]; then
    lines+=("-b ${TERMUX_HOME}/storage/downloads:/downloads")
  fi
  if [[ -d "${TERMUX_HOME}" ]]; then
    lines+=("-b ${TERMUX_HOME}:/termux-home")
  fi
  if [[ -d "${GROK_WORKSPACE}" ]]; then
    lines+=("-b ${GROK_WORKSPACE}:/workspace")
  fi
  # User extras (host path must exist; guest optional)
  if user_file="$(_gh_user_extra_binds_file)"; then
    while IFS= read -r line || [[ -n "${line}" ]]; do
      line="${line%%#*}"
      line="${line#"${line%%[![:space:]]*}"}"  # ltrim
      line="${line%"${line##*[![:space:]]}"}"  # rtrim
      [[ -n "${line}" ]] || continue
      case "${line}" in
        -b\ *) ;;
        *) line="-b ${line}" ;;
      esac
      host="${line#-b }"
      host="${host%%:*}"
      host="${host%%[[:space:]]*}"
      if [[ -e "${host}" || -d "${host}" ]]; then
        lines+=("${line}")
      fi
    done < "${user_file}"
  fi
  if [[ ${#lines[@]} -gt 0 ]]; then
    printf '%s\n' "${lines[@]}"
  fi
}

# True if file already has current versioned marker.
_gh_binds_are_current() {
  local f="$1"
  [[ -f "${f}" ]] || return 1
  grep -qF "${GROKHUNTER_BINDS_MARK}" "${f}" 2>/dev/null
}

# True if any grokhunter bind marker is present (any version).
_gh_binds_have_any_mark() {
  local f="$1"
  [[ -f "${f}" ]] || return 1
  grep -qF "${GROKHUNTER_BINDS_MARK_BASE}" "${f}" 2>/dev/null
}

# Find a line that is a good insertion anchor. Prefer -b /dev, then -b /proc,
# then the first -b line. Prints 1-based line number or returns 1.
_gh_find_bind_anchor() {
  local f="$1"
  local line n=0
  local first_b=0 dev_n=0 proc_n=0
  while IFS= read -r line || [[ -n "${line}" ]]; do
    n=$((n + 1))
    case "${line}" in
      *"-b /dev"*|*-b\ /dev\ *|*-b\ /dev) [[ ${dev_n} -eq 0 ]] && dev_n=${n} ;;
    esac
    case "${line}" in
      *"-b /proc"*|*-b\ /proc\ *|*-b\ /proc) [[ ${proc_n} -eq 0 ]] && proc_n=${n} ;;
    esac
    if [[ ${first_b} -eq 0 && "${line}" == *"-b "* ]]; then
      first_b=${n}
    fi
  done < "${f}"
  if [[ ${dev_n} -gt 0 ]]; then
    printf '%s\n' "${dev_n}"
    return 0
  fi
  if [[ ${proc_n} -gt 0 ]]; then
    printf '%s\n' "${proc_n}"
    return 0
  fi
  if [[ ${first_b} -gt 0 ]]; then
    printf '%s\n' "${first_b}"
    return 0
  fi
  return 1
}

# Strip any existing GrokHunter bind block (marker + following indented -b lines).
_gh_strip_bind_block() {
  local f="$1"
  local line in_block=0
  local -a out=()
  while IFS= read -r line || [[ -n "${line}" ]]; do
    if [[ "${line}" == *"${GROKHUNTER_BINDS_MARK_BASE}"* ]]; then
      in_block=1
      continue
    fi
    if [[ ${in_block} -eq 1 ]]; then
      # Continue skipping while line looks like an inserted bind continuation
      case "${line}" in
        *"-b "*|""|[[:space:]]*)
          # blank or bind-ish → still in block if indented or empty
          if [[ "${line}" == *"-b "* ]] || [[ -z "${line//[[:space:]]/}" ]]; then
            continue
          fi
          # non-bind content ends the block
          in_block=0
          ;;
        *)
          in_block=0
          ;;
      esac
    fi
    if [[ ${in_block} -eq 0 ]]; then
      out+=("${line}")
    fi
  done < "${f}"
  printf '%s\n' "${out[@]}"
}

# Pure-bash atomic patch: insert extra proot binds after an anchor line.
# Usage: _patch_launcher_binds <file> [force]
# force=1 rewrites even when current version marker is present.
_patch_launcher_binds() {
  local f="$1"
  local force="${2:-0}"
  local line found=0 tmp anchor_n n=0
  local -a out=() extra=()
  local b

  [[ -f "${f}" ]] || return 0

  if [[ "${force}" != "1" ]] && _gh_binds_are_current "${f}"; then
    msg -ts "${f##*/}: binds OK (v${GROKHUNTER_BINDS_VERSION})"
    return 0
  fi

  if ! anchor_n="$(_gh_find_bind_anchor "${f}")"; then
    msg -tw "Could not auto-patch ${f##*/} (no '-b' anchor found)"
    return 1
  fi

  if [[ ! -f "${f}.grokhunter.bak" ]]; then
    cp -a "${f}" "${f}.grokhunter.bak" 2>/dev/null || true
  fi

  _ensure_workspace
  mapfile -t extra < <(_gh_extra_bind_lines)

  # Rebuild: drop stale block if any, then insert current block after anchor.
  local -a base=()
  if _gh_binds_have_any_mark "${f}"; then
    mapfile -t base < <(_gh_strip_bind_block "${f}")
    # Recompute anchor after strip
    tmp="$(mktemp)"
    printf '%s\n' "${base[@]}" > "${tmp}"
    if ! anchor_n="$(_gh_find_bind_anchor "${tmp}")"; then
      rm -f "${tmp}"
      msg -tw "Could not auto-patch ${f##*/} (anchor lost after strip)"
      return 1
    fi
    rm -f "${tmp}"
  else
    mapfile -t base < "${f}"
  fi

  n=0
  for line in "${base[@]}"; do
    n=$((n + 1))
    out+=("${line}")
    if [[ ${found} -eq 0 && ${n} -eq ${anchor_n} ]]; then
      found=1
      out+=("${GROKHUNTER_BINDS_MARK}")
      for b in "${extra[@]}"; do
        [[ -n "${b}" ]] || continue
        out+=("        ${b} \\")
      done
    fi
  done

  if [[ ${found} -eq 0 ]]; then
    msg -tw "Could not auto-patch ${f##*/} (anchor not applied)"
    return 1
  fi

  tmp="$(mktemp "${f}.grokhunter.XXXXXX")" || {
    msg -tw "mktemp failed while patching ${f##*/}"
    return 1
  }
  printf '%s\n' "${out[@]}" > "${tmp}" || {
    rm -f "${tmp}"
    msg -tw "Failed writing temp patch for ${f##*/}"
    return 1
  }
  if ! mv -f "${tmp}" "${f}"; then
    rm -f "${tmp}"
    msg -tw "Failed installing patched ${f##*/}"
    return 1
  fi
  chmod --reference="${f}.grokhunter.bak" "${f}" 2>/dev/null || chmod 755 "${f}" 2>/dev/null || true

  if _gh_binds_are_current "${f}"; then
    msg -ts "Patched ${f##*/} with optimized binds (v${GROKHUNTER_BINDS_VERSION})"
    return 0
  fi

  msg -tw "Could not auto-patch ${f##*/}"
  msg -a "  Backup: ${f}.grokhunter.bak (if created)"
  msg -a "  Manually add after '-b /dev' (only if the host path exists):"
  while IFS= read -r b; do
    [[ -n "${b}" ]] || continue
    msg -a "    ${b} \\"
  done < <(_gh_extra_bind_lines)
  return 1
}

# Status: show desired vs applied binds for nethunter/nh launchers.
show_proot_binds() {
  local launcher="${TERMUX_FILES_DIR}/usr/bin/nethunter"
  local shortcut="${TERMUX_FILES_DIR}/usr/bin/nh"
  local f b user_file
  msg -t "GrokHunter proot binds"
  msg -a "  marker: ${GROKHUNTER_BINDS_MARK}"
  if user_file="$(_gh_user_extra_binds_file)"; then
    msg -a "  user extras: ${user_file}"
  else
    msg -a "  user extras: (none — optional ~/.config/grokhunter/extra-binds)"
  fi
  echo
  msg -a "  Desired (host path must exist):"
  while IFS= read -r b; do
    [[ -n "${b}" ]] || continue
    msg -a "    ${b}"
  done < <(_gh_extra_bind_lines)
  echo
  for f in "${launcher}" "${shortcut}"; do
    if [[ ! -f "${f}" ]]; then
      msg -a "  ${f##*/}: missing"
      continue
    fi
    if _gh_binds_are_current "${f}"; then
      msg -ts "  ${f##*/}: current (v${GROKHUNTER_BINDS_VERSION})"
    elif _gh_binds_have_any_mark "${f}"; then
      msg -tw "  ${f##*/}: stale marker (run repair_proot_binds)"
    else
      msg -tw "  ${f##*/}: not patched"
    fi
    grep -E 'grokhunter-optimized-binds|-b .*(/tmp|/sdcard|/downloads|/termux-home|/workspace)' "${f}" 2>/dev/null \
      | sed 's/^/    /' || true
  done
}

# Force re-apply optimized binds on both launchers.
repair_proot_binds() {
  msg -t "Repairing proot binds"
  _ensure_workspace
  local launcher="${TERMUX_FILES_DIR}/usr/bin/nethunter"
  local shortcut="${TERMUX_FILES_DIR}/usr/bin/nh"
  local f rc=0
  for f in "${launcher}" "${shortcut}"; do
    if [[ ! -f "${f}" ]]; then
      msg -a "  skip missing ${f##*/}"
      continue
    fi
    _patch_launcher_binds "${f}" 1 || rc=1
  done
  show_proot_binds
  return "${rc}"
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
  # Also Termux home when running inside Kali proot with different HOME
  if [[ -d /data/data/com.termux/files/home ]]; then
    mkdir -p /data/data/com.termux/files/home/.config/grokhunter 2>/dev/null || true
    printf '%s\n' "${session_cmd}" \
      > /data/data/com.termux/files/home/.config/grokhunter/x11-session 2>/dev/null || true
  fi
}

# Probe rootfs / PATH for a desktop session binary (same order as nh-x11).
_detect_x11_session() {
  local rootfs="${ROOTFS_DIRECTORY:-${NH_ROOTFS:-/data/data/com.termux/files/kali}}"
  local c
  for c in startxfce4 startlxde mate-session i3 startplasma-x11 enlightenment_start gnome-session; do
    if [[ -x "/usr/bin/${c}" || -x "/bin/${c}" || -x "/usr/bin/X11/${c}" ]]; then
      printf '%s\n' "${c}"
      return 0
    fi
    if [[ -n "${rootfs}" && -d "${rootfs}" ]]; then
      if [[ -x "${rootfs}/usr/bin/${c}" || -x "${rootfs}/bin/${c}" || -x "${rootfs}/usr/bin/X11/${c}" ]]; then
        printf '%s\n' "${c}"
        return 0
      fi
    fi
  done
  # Default preferred for GrokHunter full installs
  printf '%s\n' "startxfce4"
}

# Write ~/.config/grokhunter/x11-session if missing (or when force=1).
# Usage: ensure_x11_session [session_cmd] [force]
ensure_x11_session() {
  local session="${1:-}"
  local force="${2:-0}"
  local cfg="${HOME}/.config/grokhunter/x11-session"
  if [[ -z "${session}" ]]; then
    session="$(_detect_x11_session)"
  fi
  if [[ "${force}" != "1" && -r "${cfg}" ]]; then
    # already present
    return 0
  fi
  save_x11_session "${session}"
  return 0
}

# Canonical nh-x11 lives in bin/nh-x11 (install copies; no heredoc drift).
_resolve_overlay_file() {
  local rel="$1"
  local d stamp
  local -a candidates=()
  for d in "${SCRIPT_DIR:-}" "${GROKHUNTER_HOME:-}" "${HOME}/GrokHunter"; do
    candidates+=("${d}")
  done
  stamp="${HOME}/.cache/grokhunter/OVERLAY_ROOT"
  if [[ -r "${stamp}" ]]; then
    d="$(tr -d '[:space:]' < "${stamp}" 2>/dev/null || true)"
    [[ -n "${d}" ]] && candidates+=("${d}")
  fi
  candidates+=("${HOME}/.cache/grokhunter/src")

  for d in "${candidates[@]}"; do
    [[ -n "${d}" ]] || continue
    case "${d}" in
      /dev/fd|/dev/fd/*|/proc/self/fd|/proc/self/fd/*|/proc/*/fd|/proc/*/fd/*) continue ;;
    esac
    if [[ -f "${d}/${rel}" ]]; then
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
  # gdk-pixbuf 2.44 glycin SVG loaders call bwrap --unshare-all (fatal under proot).
  local kali_root="${DEFAULT_ROOTFS_DIR:-${TERMUX_FILES_DIR}/kali}"
  local kali_local="${kali_root}/usr/local/bin"
  local kali_bwrap="${kali_root}/usr/bin/bwrap"
  if src="$(_resolve_overlay_file "bin/bwrap-proot")" && [[ -f "${src}" ]]; then
    mkdir -p "${kali_local}" 2>/dev/null || true
    _install_repo_bin "bin/bwrap-proot" "${kali_local}/bwrap" && \
      msg -ts "Installed /usr/local/bin/bwrap stub (glycin SVG under proot)" || true
    if [[ -f "${kali_bwrap}" ]] && ! grep -q bwrap-proot "${kali_bwrap}" 2>/dev/null; then
      [[ -f "${kali_bwrap}.real" ]] || cp -f "${kali_bwrap}" "${kali_bwrap}.real" 2>/dev/null || true
      if _install_repo_bin "bin/bwrap-proot" "${kali_bwrap}"; then
        msg -ts "Replaced /usr/bin/bwrap with proot stub (saved bwrap.real)"
      fi
    fi
  fi
  # Persist preferred DE session for nh-x11 (doctor checks this file)
  local sess
  sess="$(_detect_x11_session)"
  ensure_x11_session "${sess}" 0
  if [[ -r "${HOME}/.config/grokhunter/x11-session" ]]; then
    msg -ts "X11 session: $(tr -d '[:space:]' < "${HOME}/.config/grokhunter/x11-session")"
  fi
  # Desktop menu entries (Grok Build, Coding Team, Doctor, …)
  if declare -F install_kali_menu >/dev/null 2>&1; then
    install_kali_menu || true
  elif [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/scripts/install_kali_menu.sh" ]]; then
    bash "${SCRIPT_DIR}/scripts/install_kali_menu.sh" || true
  fi
  msg -a "  Session: NH_X11_SESSION or ~/.config/grokhunter/x11-session"
  msg -a "  Menu:    Applications → GrokHunter (after menu install)"
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
  msg -a "  Binds (existing host paths only): /tmp, /sdcard, /downloads, /termux-home, /workspace"
  msg -a "  User extras: ~/.config/grokhunter/extra-binds (one -b line per path)"
  msg -a "  Status: show_proot_binds · Repair: repair_proot_binds"
  msg -a "  Tip: keep rootfs on internal storage; see docs/PROOT.md"
}

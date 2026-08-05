#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Termux:X11 low-latency desktop + proot bind optimizers

GROKHUNTER_TMP_MARK="# grokhunter-shared-tmp"
TERMUX_FILES_DIR="${TERMUX_FILES_DIR:-/data/data/com.termux/files}"

_patch_launcher_tmp_bind() {
  local f="$1"
  local tmp_bind="-b /data/data/com.termux/files/usr/tmp:/tmp"
  [[ -f "${f}" ]] || return 0

  if grep -q "${GROKHUNTER_TMP_MARK}" "${f}" 2>/dev/null \
     || grep -q "/data/data/com.termux/files/usr/tmp:/tmp" "${f}" 2>/dev/null; then
    msg -ts "${f##*/}: /tmp bind OK"
    return 0
  fi

  if [[ ! -f "${f}.grokhunter.bak" ]]; then
    cp -a "${f}" "${f}.grokhunter.bak" 2>/dev/null || true
  fi

  if grep -q -- "-b /dev" "${f}"; then
    if sed -i "/-b \\\/dev/{
a\\
        ${GROKHUNTER_TMP_MARK}\\
        ${tmp_bind} \\\\
}" "${f}" 2>/dev/null; then
      if grep -q "/data/data/com.termux/files/usr/tmp:/tmp" "${f}" 2>/dev/null; then
        msg -ts "Patched ${f##*/} with /tmp bind"
        return 0
      fi
    fi
  fi

  msg -tw "Could not auto-patch ${f##*/}"
  msg -a "  Backup: ${f}.grokhunter.bak (if created)"
  msg -a "  Manually add: ${tmp_bind} \\"
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
    _patch_launcher_tmp_bind "${f}" || true
  done

  local helper="${TERMUX_FILES_DIR}/usr/bin/nh-x11"
  cat > "${helper}" << 'X11HELPER'
#!/data/data/com.termux/files/usr/bin/bash
# nh-x11 — Kali desktop via Termux:X11 (GrokHunter Rootless)
# IMPORTANT: do NOT pass -r to nethunter — that means --rename rootfs.

set -euo pipefail

_ROOTFS="${NH_ROOTFS:-/data/data/com.termux/files/kali}"
_CFG_SESSION=""
for _p in \
  "${HOME}/.config/grokhunter/x11-session" \
  "/data/data/com.termux/files/home/.config/grokhunter/x11-session"
do
  if [[ -r "${_p}" ]]; then
    _CFG_SESSION="$(tr -d '[:space:]' < "${_p}" 2>/dev/null || true)"
    [[ -n "${_CFG_SESSION}" ]] && break
  fi
done

_session_exists() {
  local cmd="$1"
  [[ -z "${cmd}" ]] && return 1
  [[ -x "${_ROOTFS}/usr/bin/${cmd}" ]] \
    || [[ -x "${_ROOTFS}/bin/${cmd}" ]] \
    || [[ -x "${_ROOTFS}/usr/bin/X11/${cmd}" ]]
}

_pick_session() {
  if [[ -n "${NH_X11_SESSION:-}" ]]; then
    printf '%s\n' "${NH_X11_SESSION}"
    return 0
  fi
  if [[ -n "${_CFG_SESSION}" ]] && _session_exists "${_CFG_SESSION}"; then
    printf '%s\n' "${_CFG_SESSION}"
    return 0
  fi
  local c
  for c in startxfce4 startlxde mate-session i3 startplasma-x11 enlightenment_start gnome-session; do
    if _session_exists "${c}"; then
      printf '%s\n' "${c}"
      return 0
    fi
  done
  if [[ -n "${_CFG_SESSION}" ]]; then
    printf '%s\n' "${_CFG_SESSION}"
    return 0
  fi
  printf '%s\n' "startxfce4"
}

SESSION_CMD="$(_pick_session)"
if [[ ! "${SESSION_CMD}" =~ ^[A-Za-z0-9_./+-]+$ ]]; then
  echo "[nh-x11] WARN: rejecting unsafe session '${SESSION_CMD}'; using startxfce4" >&2
  SESSION_CMD="startxfce4"
fi
SESSION_CMD="${SESSION_CMD##*/}"

SESSION_PREP=""
case "${SESSION_CMD}" in
  startxfce4)
    SESSION_PREP='xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true;'
    ;;
esac

if ! command -v nethunter >/dev/null 2>&1 && ! command -v nh >/dev/null 2>&1; then
  echo "[nh-x11] nethunter/nh launcher missing — re-run install.sh" >&2
  exit 1
fi
if ! command -v termux-x11 >/dev/null 2>&1; then
  echo "[nh-x11] termux-x11 not found — pkg install termux-x11-nightly" >&2
  exit 1
fi
if [[ ! -d "${_ROOTFS}" ]]; then
  echo "[nh-x11] rootfs missing: ${_ROOTFS} — re-run install.sh" >&2
  exit 1
fi

LAUNCHER="nethunter"
command -v nethunter >/dev/null 2>&1 || LAUNCHER="nh"

am force-stop com.termux.x11 2>/dev/null || true
pkill -f '[t]ermux-x11' 2>/dev/null || true
sleep 0.4

pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1 2>/dev/null || true

export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
mkdir -p "${XDG_RUNTIME_DIR}"

X11_EXTRA=()
[[ "${NH_X11_LEGACY:-0}" == "1" ]] && X11_EXTRA+=(-legacy-drawing)
[[ -n "${NH_X11_DPI:-}" ]] && X11_EXTRA+=(-dpi "${NH_X11_DPI}")

termux-x11 :0 "${X11_EXTRA[@]}" >/dev/null 2>&1 &
sleep 2

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true
sleep 0.8

echo "[nh-x11] Termux:X11 on :0 — starting ${SESSION_CMD} (via ${LAUNCHER})..."

# nethunter args become the proot command. DO NOT use -r (that is --rename).
# Run a login shell with DISPLAY set, then the DE session as user kali.
exec "${LAUNCHER}" /bin/bash -lc "export DISPLAY=:0 PULSE_SERVER=127.0.0.1 XDG_RUNTIME_DIR=/tmp LANG=\${LANG:-en_US.UTF-8}; ${SESSION_PREP} exec su - kali -c '${SESSION_CMD}'"
X11HELPER

  chmod 755 "${helper}"
  msg -ts "Created helper command: nh-x11"
  msg -a "  Session: NH_X11_SESSION or ~/.config/grokhunter/x11-session"
  optimize_proot_binds 2>/dev/null || true

  echo
  msg -a "  ${T}Usage:${S}"
  msg -a "    1. Install Termux:X11 APK (prefer sharedUid if Termux is from GitHub)"
  msg -a "    2. Run:  ${P}nh-x11${S}"
  msg -a "    Override DE:  ${P}NH_X11_SESSION=startxfce4 nh-x11${S}"
  msg -a "    Black screen?  ${P}NH_X11_LEGACY=1 nh-x11${S}"
  msg -a "  ${T}Tips:${S} docs/X11-PERFORMANCE.md  docs/PROOT.md"
}

optimize_proot_binds() {
  msg -t "Optimizing proot binds on nethunter launcher"
  local launcher="${TERMUX_FILES_DIR}/usr/bin/nethunter"
  local shortcut="${TERMUX_FILES_DIR}/usr/bin/nh"
  for f in "${launcher}" "${shortcut}"; do
    _patch_launcher_tmp_bind "${f}" || true
  done
  msg -a "  Tip: keep rootfs on internal storage; see docs/PROOT.md"
}

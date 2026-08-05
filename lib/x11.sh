#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Termux:X11 low-latency desktop + proot bind optimizers

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
  local tmp_bind="-b /data/data/com.termux/files/usr/tmp:/tmp"

  for f in "${launcher}" "${shortcut}"; do
    if [[ -f ${f} ]]; then
      if grep -q "/data/data/com.termux/files/usr/tmp:/tmp" "${f}" 2>/dev/null; then
        msg -ts "${f##*/} already has /tmp bind"
        continue
      fi
      if grep -q -- "-b /dev" "${f}"; then
        sed -i "/-b \/dev/a\\        ${tmp_bind} \\\\" "${f}" 2>/dev/null && {
          msg -ts "Patched ${f##*/} with /tmp bind (method A)"
          continue
        }
      fi
      if grep -q -- "-b " "${f}"; then
        sed -i "0,/-b /s||-b |        ${tmp_bind} \\\\\n        -b |" "${f}" 2>/dev/null && {
          msg -ts "Patched ${f##*/} with /tmp bind (method B)"
          continue
        }
      fi
      msg -tw "Could not auto-patch ${f##*/}"
      msg -a "  Manually add among proot -b options: ${tmp_bind} \\"
    fi
  done

  local helper="${TERMUX_FILES_DIR}/usr/bin/nh-x11"
  cat > "${helper}" << 'X11HELPER'
#!/data/data/com.termux/files/usr/bin/bash
# nh-x11 — Kali desktop via Termux:X11 (GrokHunter Rootless)

pkill -f "termux.x11" 2>/dev/null || true
sleep 0.5

pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1 2>/dev/null || true

export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
termux-x11 :0 >/dev/null 2>&1 &
sleep 2

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || true
sleep 1

echo "[nh-x11] Termux:X11 on :0 — starting desktop inside NetHunter..."

# Shared /tmp (launcher patched) + coding-friendly env
nethunter -r 'export DISPLAY=:0 PULSE_SERVER=127.0.0.1 XDG_RUNTIME_DIR=/tmp LANG=${LANG:-en_US.UTF-8} && su - kali -c "startxfce4"'
X11HELPER

  chmod 755 "${helper}"
  msg -ts "Created helper command: nh-x11"
  optimize_proot_binds 2>/dev/null || true

  echo
  msg -a "  ${T}Usage:${S}"
  msg -a "    1. Install Termux:X11 APK (GitHub nightlies)"
  msg -a "    2. Run:  ${P}nh-x11${S}"
  msg -a "  ${T}Tips:${S} keep rootfs on internal storage — see docs/PROOT.md"
}

# Idempotent /tmp bind check (shared-tmp equivalent)
optimize_proot_binds() {
  msg -t "Optimizing proot binds on nethunter launcher"
  local launcher="${TERMUX_FILES_DIR}/usr/bin/nethunter"
  local shortcut="${TERMUX_FILES_DIR}/usr/bin/nh"
  local tmp_bind="-b /data/data/com.termux/files/usr/tmp:/tmp"
  for f in "${launcher}" "${shortcut}"; do
    [[ -f ${f} ]] || continue
    if ! grep -q "/data/data/com.termux/files/usr/tmp:/tmp" "${f}" 2>/dev/null; then
      if grep -q -- "-b /dev" "${f}"; then
        sed -i "/-b \/dev/a\\        ${tmp_bind} \\\\" "${f}" 2>/dev/null && msg -ts "Added /tmp bind to ${f##*/}"
      fi
    else
      msg -ts "${f##*/}: /tmp bind OK"
    fi
  done
  msg -a "  Tip: keep rootfs on internal storage; see docs/PROOT.md"
}

#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter install/config/complete action hooks
# These functions are called by the upstream termux-distro engine.

pre_check_actions() {
  P=${W}; S=${B}; T=${M}
}

distro_banner() {
  local spaces
  spaces=$(printf "%*s" $((($(stty size 2>/dev/null | awk '{print $2}') - 49) / 2)) "")
  msg -a "${spaces}${S}.............."
  msg -a "${spaces}${S}            ..,;:ccc,."
  msg -a "${spaces}${S}          ......''';lxO."
  msg -a "${spaces}${S}.....''''..........,:ld;"
  msg -a "${spaces}${S}           .';;;:::;,,.x,"
  msg -a "${spaces}${S}      ..'''.            0Xxoc:,.  ..."
  msg -a "${spaces}${S}  ....                ,ONkc;,;cokOdc',."
  msg -a "${spaces}${S} .                   OMo           ':${R}dd${S}o."
  msg -a "${spaces}${S}                    dMc               :OO;"
  msg -a "${spaces}${S}                    0M.                 .:o."
  msg -a "${spaces}${S}                    ;Wd"
  msg -a "${spaces}${S}                     ;XO,"
  msg -a "${spaces}${S}                       ,d0Odlc;,.."
  msg -a "${spaces}${S}                           ..',;:cdOOd::,."
  msg -a "${spaces}${S}                                    .:d;.':;."
  msg -a "${spaces}${S}                                       'd,  .'"
  msg -a "${spaces}${S}${P}${DISTRO_NAME}${S}                           ;l   .."
  msg -a "${spaces}${S}    ${T}${VERSION_NAME}${S}                                    .o"
  msg -a "${spaces}${S}                                            c  ."
  msg -a "${spaces}${S}                                            .'"
  msg -a "${spaces}${S}                                             ."
  msg -a "${spaces}${T}GrokHunter • Grok Build • Termux:X11 • Dynamic rootfs${S}"
}

post_check_actions() { return; }

pre_install_actions() {
  if [[ ! ${KEEP_ROOTFS_DIRECTORY} ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_INSTALLATION} ]]; then
      case "${SELECTED_INSTALLATION}" in
        full) SELECTED_INSTALLATION=full; DE_INSTALLED=1 ;;
        nano) SELECTED_INSTALLATION=nano ;;
        *)    SELECTED_INSTALLATION=mini ;;
      esac
    else
      choose -d2 -t "Select installation" \
        "Full (Desktop environment)" \
        "Mini (Essential Packages)" \
        "Nano (Essential Packages)"
      SELECTED_INSTALLATION=${?}
      case "${SELECTED_INSTALLATION}" in
        1) SELECTED_INSTALLATION=full; DE_INSTALLED=1 ;;
        3) SELECTED_INSTALLATION=nano ;;
        *) SELECTED_INSTALLATION=mini ;;
      esac
    fi

    ARCHIVE_NAME=kali-nethunter-rootfs-${SELECTED_INSTALLATION/mini/minimal}-${SYS_ARCH}.tar.xz

    # Dynamic official SHA256
    msg -tn "Fetching latest SHA256SUMS from Kali servers..."
    local sha_line
    if sha_line=$(curl -fsSL "${BASE_URL}/SHA256SUMS" 2>>"${LOG_FILE}" | grep " ${ARCHIVE_NAME}$"); then
      TRUSTED_SHASUMS="${sha_line}"
      cursor -u1
      msg -ts "Official SHA loaded"
    else
      cursor -u1
      msg -tw "Could not fetch SHA256SUMS — using bundled checksums"
    fi

    # Storage check
    local available required=2
    available=$(df -BG "${TERMUX_FILES_DIR}" 2>/dev/null | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
    [[ ${SELECTED_INSTALLATION} == full ]] && required=6
    if [[ -n ${available} && ${available} -lt ${required} ]]; then
      msg -tw "Low storage: ${available}GB free (need ~${required}GB+)"
      if ! ask -y -- -t "Continue with limited space?"; then
        msg -te "Installation aborted"
        exit 1
      fi
    fi
  fi
}

post_install_actions() { return; }

pre_config_actions() {
  mkdir -p "${ROOTFS_DIRECTORY}"/etc &>>"${LOG_FILE}" && \
    echo "${ROOTFS_DIRECTORY}" >"${ROOTFS_DIRECTORY}"/etc/debian_chroot
}

post_config_actions() {
  if [[ -f ${ROOTFS_DIRECTORY}/etc/locale.gen && -x ${ROOTFS_DIRECTORY}/sbin/dpkg-reconfigure ]]; then
    msg -tn "Generating locales..."
    sed -i -E 's/#[[:space:]]?(en_US.UTF-8[[:space:]]+UTF-8)/\1/g' "${ROOTFS_DIRECTORY}"/etc/locale.gen
    if distro_exec DEBIAN_FRONTEND=noninteractive /sbin/dpkg-reconfigure locales &>>"${LOG_FILE}"; then
      cursor -u1; msg -ts "Locales generated"
    else
      cursor -u1; msg -te "Failed to generate locales"
    fi
  fi
}

pre_complete_actions() {
  # Desktop Environment
  if [[ ${SKIP_DE} -eq 0 && ! ${DE_INSTALLED} && ${SELECTED_INSTALLATION} != full ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_DE} ]]; then
      set_up_de && {
        DE_INSTALLED=1
        [[ -n ${SELECTED_BROWSER} ]] && set_up_browser
      }
    else
      set_up_de && {
        DE_INSTALLED=1
        set_up_browser
      }
    fi
  fi

  # Grok Build
  if [[ ${SKIP_GROK} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      [[ ${INSTALL_GROK} -eq 1 ]] && install_grok_build
    else
      if ask -y -- -t "Also install native Grok Build CLI (recommended)?"; then
        install_grok_build
      fi
    fi
  fi

  # Termux:X11
  if [[ ${SKIP_X11} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      [[ ${INSTALL_X11} -eq 1 ]] && setup_termux_x11
    else
      if ask -y -- -t "Also set up Termux:X11 (low-latency desktop)?"; then
        setup_termux_x11
      fi
    fi
  fi
}

post_complete_actions() {
  echo
  msg -a "${P}════════════════════════════════════════════════════════════${S}"
  msg -a "${P}  GrokHunter is ready!  (NetHunter + Grok Build)${S}"
  msg -a "${P}════════════════════════════════════════════════════════════${S}"
  echo
  msg -a "  ${T}Quick Start:${S}"
  msg -a "    nethunter          ${S}# Login to Kali shell${S}"
  msg -a "    nethunter -l       ${S}# List available commands${S}"
  echo
  if [[ ${DE_INSTALLED} -eq 1 ]]; then
    msg -a "  ${T}Desktop (Termux:X11 – recommended):${S}"
    if command -v nh-x11 &>/dev/null; then
      msg -a "    nh-x11             ${S}# One-command low-latency desktop${S}"
    else
      msg -a "    termux-x11 :0 &    ${S}# then inside nethunter: startxfce4${S}"
    fi
    echo
    msg -a "  ${T}Desktop (VNC / KeX fallback):${S}"
    msg -a "    vncserver :1 -geometry 1920x1080 -depth 24"
    msg -a "    → connect VNC Viewer / KeX to localhost:5901"
  fi
  echo
  msg -a "  ${T}Inside NetHunter:${S}"
  msg -a "    sudo apt update && sudo apt full-upgrade -y"
  msg -a "    sudo apt install kali-linux-nethunter kali-tools-top10 -y"
  echo
  if command -v grok &>/dev/null; then
    msg -a "  ${T}Grok Build:${S}"
    msg -a "    grok               ${S}# Interactive TUI${S}"
    msg -a "    grok -p \"task\"     ${S}# Headless mode${S}"
  fi
  echo
  msg -a "${P}Enjoy your AI-powered mobile lab!${S}"
  msg -a "${P}════════════════════════════════════════════════════════════${S}"
}

# ---------- Desktop Environment ----------
set_up_de() {
  local available_desktops=(E17 GNOME i3 KDE LXDE MATE Xfce)
  local -A xstartups=(
    [e17]=enlightenment_start [gnome]=gnome-session [i3]=i3
    [kde]=startplasma-x11 [lxde]=startlxde [mate]=mate-session [xfce]=startxfce4
  )
  local selected_desktop

  if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_DE} ]]; then
    case "${SELECTED_DE,,}" in
      e17|enlightenment) selected_desktop=E17 ;;
      gnome) selected_desktop=GNOME ;;
      i3) selected_desktop=i3 ;;
      kde|plasma) selected_desktop=KDE ;;
      lxde) selected_desktop=LXDE ;;
      mate) selected_desktop=MATE ;;
      xfce|xfce4) selected_desktop=Xfce ;;
      *) selected_desktop=Xfce; msg -tw "Unknown DE — defaulting to Xfce" ;;
    esac
  else
    choose -d7 -t "Select Desktop Environment" "${available_desktops[@]}"
    selected_desktop=${available_desktops[$((${?} - 1))]}
  fi

  msg -t "Installing ${selected_desktop} Desktop"
  command -v termux-wake-lock &>>"${LOG_FILE}" && termux-wake-lock &>>"${LOG_FILE}" || true

  msg -tn "Installing ${selected_desktop} packages..."
  trap 'buffer -h; echo; msg -fem2; exit 130' INT
  buffer -s

  local pkgs=(tigervnc-standalone-server dbus-x11 kali-desktop-"${selected_desktop,,}")
  if buffer -i apt update && distro_exec apt update &&
     buffer -i apt full-upgrade && distro_exec apt full-upgrade &&
     buffer -i apt install -y "${pkgs[@]}" && distro_exec apt install -y "${pkgs[@]}"; then
    buffer -h3; trap - INT; cursor -u1
    msg -ts "${selected_desktop} installed"

    local xstartup
    xstartup="#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_RUNTIME_DIR=\${TMPDIR:-/tmp}/runtime-\$(id -u)
export SHELL=\${SHELL:-/bin/sh}
export QT_QPA_PLATFORMTHEME=gtk2
export GDK_SCALE=1.5
[[ -r ~/.Xresources ]] && xrdb ~/.Xresources
exec ${xstartups[${selected_desktop,,}]}"

    mkdir -p "${ROOTFS_DIRECTORY}"/root/.vnc
    echo "${xstartup}" >"${ROOTFS_DIRECTORY}"/root/.vnc/xstartup
    chmod 744 "${ROOTFS_DIRECTORY}"/root/.vnc/xstartup
    if [[ ${DEFAULT_LOGIN} != root ]]; then
      mkdir -p "${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc
      echo "${xstartup}" >"${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc/xstartup
      chmod 744 "${ROOTFS_DIRECTORY}"/home/"${DEFAULT_LOGIN}"/.vnc/xstartup
    fi
    msg -ts "xstartup created"
  else
    buffer -h5; trap - INT; cursor -u1
    msg -te "Failed to install ${selected_desktop}"
    return 1
  fi
}

set_up_browser() {
  local available_browsers=("Chromium" "Firefox ESR" "Chromium & Firefox ESR")
  local selected_browser selected_browsers suffix

  if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_BROWSER} ]]; then
    case "${SELECTED_BROWSER,,}" in
      chromium|chrome) selected_browser="Chromium" ;;
      firefox*) selected_browser="Firefox ESR" ;;
      both|"chromium & firefox"*) selected_browser="${available_browsers[-1]}" ;;
      *) selected_browser="Chromium" ;;
    esac
  else
    choose -d2 -t "Select Browser" "${available_browsers[@]}"
    selected_browser=${available_browsers[$((${?} - 1))]}
  fi

  if [[ ${selected_browser} == "${available_browsers[-1]}" ]]; then
    selected_browsers=("${available_browsers[@]:0:${#available_browsers[@]}-1}")
    selected_browsers=("${selected_browsers[@]// /-}")
    suffix=s
  else
    selected_browsers=("${selected_browser// /-}")
    suffix=
  fi

  msg -tn "Installing ${selected_browser} Browser${suffix}..."
  trap 'buffer -h; echo; msg -fem2; exit 130' INT
  buffer -s
  if buffer -i apt install -y "${selected_browsers[@],,}" && distro_exec apt install -y "${selected_browsers[@],,}"; then
    if [[ ${selected_browsers[0]} == Chromium && -f "${ROOTFS_DIRECTORY}"/usr/share/applications/chromium.desktop ]]; then
      sed -Ei 's/^(Exec=.*chromium).*(%U)$/\1 --no-sandbox \2/' "${ROOTFS_DIRECTORY}"/usr/share/applications/chromium.desktop
    fi
    buffer -h3; trap - INT; cursor -u1
    msg -ts "${selected_browser} installed"
  else
    buffer -h5; trap - INT; cursor -u1
    msg -te "Failed to install browser"
  fi
}

#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter Rootless install/config/complete action hooks
# These functions are called by the upstream termux-distro engine.

pre_check_actions() {
  P=${W}; S=${B}; T=${M}
}

distro_banner() {
  local spaces
  spaces=$(printf "%*s" $((($(stty size 2>/dev/null | awk '{print $2}') - 49) / 2)) "")
  msg -a "${spaces}${S}${P}${DISTRO_NAME}${S}"
  msg -a "${spaces}${S}${T}${VERSION_NAME}${S}"
  msg -a "${spaces}${T}GrokHunter Rootless • coding lab • proot${S}"
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
    msg -tn "Fetching latest SHA256SUMS from Kali servers..."
    local sha_line
    if sha_line=$(curl -fsSL "${BASE_URL}/SHA256SUMS" 2>>"${LOG_FILE}" | grep " ${ARCHIVE_NAME}$"); then
      TRUSTED_SHASUMS="${sha_line}"
      cursor -u1; msg -ts "Official SHA loaded"
    else
      cursor -u1; msg -tw "Could not fetch SHA256SUMS — using bundled checksums"
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
  if [[ ${SKIP_DE} -eq 0 && ! ${DE_INSTALLED} && ${SELECTED_INSTALLATION} != full ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_DE} ]]; then
      set_up_de && { DE_INSTALLED=1; [[ -n ${SELECTED_BROWSER} ]] && set_up_browser; }
    else
      set_up_de && { DE_INSTALLED=1; set_up_browser; }
    fi
  fi

  if [[ ${SKIP_GROK} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      [[ ${INSTALL_GROK} -eq 1 ]] && install_grok_build
    else
      if ask -y -- -t "Also install native Grok Build CLI (recommended)?"; then
        install_grok_build
      fi
    fi
  fi

  if [[ ${SKIP_X11} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      [[ ${INSTALL_X11} -eq 1 ]] && setup_termux_x11
    else
      if ask -y -- -t "Also set up Termux:X11 (low-latency desktop)?"; then
        setup_termux_x11
      fi
    fi
  fi

  if [[ ${SKIP_AIDER:-0} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      [[ ${INSTALL_AIDER:-0} -eq 1 ]] && install_aider
    else
      if ask -y -- -t "Also install Aider (git-native pair-programmer)?"; then
        install_aider
      fi
    fi
  fi

  if [[ ${SKIP_V9:-0} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      [[ ${INSTALL_V9:-0} -eq 1 ]] && install_v9_models
    else
      if ask -y -- -t "Also install Grok V9 / 4.5 model pickers (/model chat-expert, multi, auto)?"; then
        install_v9_models
      fi
    fi
  fi

  if [[ ${SKIP_COMPLETIONS:-0} -eq 0 ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
      if [[ ${INSTALL_COMPLETIONS:-0} -eq 1 || ${INSTALL_GROK:-0} -eq 1 || ${INSTALL_V9:-0} -eq 1 || ${INSTALL_AIDER:-0} -eq 1 ]]; then
        install_shell_completions || true
      fi
    else
      if ask -y -- -t "Install zsh/bash completions for grokhunter (recommended)?"; then
        install_shell_completions || true
      fi
    fi
  fi
}

post_complete_actions() {
  echo
  msg -a "${P}GrokHunter Rootless is ready!  (coding & building lab)${S}"
  msg -a "  nethunter          # Kali shell"
  msg -a "  nh-x11             # desktop (if configured)"
  msg -a "  grok / grokhunter  # pair programming"
  msg -a "  grokhunter models  # V9 / 4.5 pickers"
  msg -a "  grokhunter doctor  # health report"
  msg -a "  source ~/.grok/profile.sh  # zsh/bash completions"
}

set_up_de() {
  local available_desktops=(E17 GNOME i3 KDE LXDE MATE Xfce)
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
  local pkgs=(tigervnc-standalone-server dbus-x11 kali-desktop-"${selected_desktop,,}")
  if distro_exec apt update && distro_exec apt install -y "${pkgs[@]}"; then
    msg -ts "${selected_desktop} installed"
  else
    msg -te "Failed to install ${selected_desktop}"; return 1
  fi
}

set_up_browser() {
  local selected_browser
  if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_BROWSER} ]]; then
    case "${SELECTED_BROWSER,,}" in
      chromium|chrome) selected_browser="chromium" ;;
      firefox*) selected_browser="firefox-esr" ;;
      both) selected_browser="chromium firefox-esr" ;;
      *) selected_browser="chromium" ;;
    esac
  else
    selected_browser="chromium"
  fi
  msg -tn "Installing browser (${selected_browser})..."
  if distro_exec apt install -y ${selected_browser}; then
    cursor -u1; msg -ts "Browser installed"
  else
    cursor -u1; msg -te "Failed to install browser"
  fi
}

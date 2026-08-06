#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter Rootless install/config/complete action hooks
# These functions are called by the upstream termux-distro engine.

pre_check_actions() {
  P=${W-}; S=${B-}; T=${M-}
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

    # Storage pre-check (from Grok-Build-2026.2 precursor)
    local available required=2
    available=$(df -BG "${TERMUX_FILES_DIR:-/data/data/com.termux/files}" 2>/dev/null | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
    [[ ${SELECTED_INSTALLATION} == full ]] && required=6
    if [[ -n ${available} && ${available} -lt ${required} ]]; then
      msg -tw "Low storage: ${available}GB free (need ~${required}GB+ for ${SELECTED_INSTALLATION})"
      if [[ ${NON_INTERACTIVE} -eq 0 ]]; then
        if ! ask -y -- -t "Continue with limited space?"; then
          msg -te "Installation aborted by user"
          exit 1
        fi
      else
        msg -tw "Non-interactive: continuing despite low storage"
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

# Resolve FEATURE_*=yes|no|auto into a concrete install decision.
# Completions: non-interactive auto follows sibling --with-grok|v9|aider.
maybe_install() {
  local want="${1:-auto}"
  local prompt="$2"
  local fn="$3"
  local allow_fail="${4:-0}"
  local decision="${want}"

  case "${decision}" in
    no) return 0 ;;
    yes) ;;
    auto)
      if [[ ${NON_INTERACTIVE:-0} -eq 1 ]]; then
        return 0
      fi
      if ! ask -y -- -t "${prompt}"; then
        return 0
      fi
      ;;
    *) return 0 ;;
  esac

  if [[ "${allow_fail}" -eq 1 ]]; then
    "${fn}" || true
  else
    "${fn}"
  fi
}

_completions_want() {
  local want="${FEATURE_COMPLETIONS:-auto}"
  if [[ "${want}" == "auto" && ${NON_INTERACTIVE:-0} -eq 1 ]]; then
    if [[ "${FEATURE_GROK:-auto}" == "yes" \
       || "${FEATURE_V9:-auto}" == "yes" \
       || "${FEATURE_AIDER:-auto}" == "yes" ]]; then
      printf 'yes\n'
      return 0
    fi
    printf 'no\n'
    return 0
  fi
  printf '%s\n' "${want}"
}

run_optional_features() {
  maybe_install "${FEATURE_GROK:-auto}" \
    "Also install native Grok Build CLI (recommended)?" \
    install_grok_build
  maybe_install "${FEATURE_X11:-auto}" \
    "Also set up Termux:X11 (low-latency desktop)?" \
    setup_termux_x11
  maybe_install "${FEATURE_AIDER:-auto}" \
    "Also install Aider (git-native pair-programmer)?" \
    install_aider
  maybe_install "${FEATURE_V9:-auto}" \
    "Also install Grok V9 / 4.5 model pickers (/model chat-expert, multi, auto)?" \
    install_v9_models
  maybe_install "$(_completions_want)" \
    "Install zsh/bash completions for grokhunter (recommended)?" \
    install_shell_completions \
    1
}

pre_complete_actions() {
  if [[ ${SKIP_DE} -eq 0 && ! ${DE_INSTALLED} && ${SELECTED_INSTALLATION} != full ]]; then
    if [[ ${NON_INTERACTIVE} -eq 1 && -n ${SELECTED_DE} ]]; then
      set_up_de && { DE_INSTALLED=1; [[ -n ${SELECTED_BROWSER} ]] && set_up_browser; }
    else
      set_up_de && { DE_INSTALLED=1; set_up_browser; }
    fi
  fi

  run_optional_features
}

post_complete_actions() {
  echo
  msg -a "${P}GrokHunter Rootless is ready!  (coding & building lab)${S}"
  echo
  msg -a "  ${T}Quick start:${S}"
  msg -a "    nethunter              # Kali shell"
  msg -a "    nh-x11                 # desktop (if configured)"
  msg -a "    grok / grokhunter      # pair programming"
  msg -a "    aider-grok             # git-native pair (if --with-aider)"
  msg -a "    grokhunter models      # V9 / 4.5 pickers"
  msg -a "    grokhunter doctor      # health report"
  msg -a "    source ~/.grok/profile.sh  # zsh/bash completions"
  echo
  msg -a "  ${T}Auth:${S}  export XAI_API_KEY=xai-...  or put it in ~/.grok/secrets.env"
  msg -a "  ${T}Docs:${S}   docs/EDITORS.md  docs/GROK-45.md  docs/X11-PERFORMANCE.md"
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
    # Remember session for nh-x11 (DE-aware)
    local session_cmd=startxfce4
    case "${selected_desktop,,}" in
      e17|enlightenment) session_cmd=enlightenment_start ;;
      gnome) session_cmd=gnome-session ;;
      i3) session_cmd=i3 ;;
      kde|plasma) session_cmd=startplasma-x11 ;;
      lxde) session_cmd=startlxde ;;
      mate) session_cmd=mate-session ;;
      xfce|xfce4) session_cmd=startxfce4 ;;
    esac
    if declare -F save_x11_session >/dev/null 2>&1; then
      save_x11_session "${session_cmd}"
    else
      mkdir -p "${HOME}/.config/grokhunter" 2>/dev/null || true
      printf '%s\n' "${session_cmd}" > "${HOME}/.config/grokhunter/x11-session" 2>/dev/null || true
    fi
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
    # Chromium under proot needs --no-sandbox (from precursor)
    if [[ "${selected_browser}" == *chromium* ]]; then
      local desk="${ROOTFS_DIRECTORY}/usr/share/applications/chromium.desktop"
      if [[ -f "${desk}" ]]; then
        if sed -Ei 's/^(Exec=.*chromium).*(%U)$/\1 --no-sandbox \2/' "${desk}" 2>/dev/null; then
          msg -ts "Chromium desktop entry: --no-sandbox applied"
        else
          msg -tw "Could not patch chromium.desktop — launch with --no-sandbox manually under proot"
        fi
      else
        msg -tw "chromium.desktop not found yet — under proot always use: chromium --no-sandbox"
      fi
    fi
  else
    cursor -u1; msg -te "Failed to install browser"
  fi
}

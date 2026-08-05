#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — native Grok Build CLI installer for Termux

install_grok_build() {
  msg -t "Installing native Grok Build CLI (Termux)"

  if command -v grok &>/dev/null; then
    msg -ts "Grok Build already present — skipping"
    return 0
  fi

  # Prefer the community Termux-native installer (handles DNS patch + launcher)
  local installer_url="https://raw.githubusercontent.com/Thr45hx/grok-cli-termux-native/main/install.sh"

  msg -tn "Downloading & running Grok Build Termux-native installer..."
  if curl -fsSL "${installer_url}" | bash; then
    cursor -u1
    if command -v grok &>/dev/null; then
      msg -ts "Grok Build installed successfully"
      msg -a "  Run ${P}grok${S} or ${P}grok -p \"hello from GrokHunter\"${S}"
      msg -a "  Auth: export XAI_API_KEY=xai-...  or browser sign-in"
    else
      msg -tw "Installer finished but 'grok' not found in PATH — restart Termux or check ~/agents/grok"
    fi
  else
    cursor -u1
    msg -te "Failed to install Grok Build"
    msg -a "  Manual: curl -fsSL ${installer_url} | bash"
    msg -a "  Or official: curl -fsSL https://x.ai/cli/install.sh | bash"
    return 1
  fi
}

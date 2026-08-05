#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# GrokHunter — One-command installer
# Kali NetHunter (Rootless) powered by Grok Build + optional Termux:X11
#
# https://github.com/FineComputer14451/GrokHunter
################################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

# Fallback: if running from a curl | bash one-liner the modules may not be local
if [[ ! -d "${LIB_DIR}" ]]; then
  echo "[GrokHunter] Local modules not found — fetching from GitHub..."
  TMP=$(mktemp -d)
  curl -fsSL https://github.com/FineComputer14451/GrokHunter/archive/refs/heads/main.tar.gz \
    | tar -xz -C "$TMP" --strip-components=1
  SCRIPT_DIR="$TMP"
  LIB_DIR="${SCRIPT_DIR}/lib"
fi

# shellcheck source=/dev/null
source "${LIB_DIR}/cli.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/actions.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/grok.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/x11.sh"

# --- Core identity (used by termux-distro template) ---------------------------
DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME=$(basename "${0}")
DISTRO_REPOSITORY=termux-nethunter
KERNEL_RELEASE=$(uname -r)
VERSION_NAME="GrokHunter-2026.2"

SHASUM_CMD=sha256sum
TRUSTED_SHASUMS="b8098fc90ed74a553592f7019a1d88dfe3c65b16c60af487b0658860554dc5aa  kali-nethunter-rootfs-full-arm64.tar.xz
b15a4aba9fb1c6f7481d7b3d08cb77c9e9c993eb542475961d008bdc64767d64  kali-nethunter-rootfs-full-armhf.tar.xz
08f121b553d03476b82b6322365eb4f47f73f4edf8800dafa7462b061eb2d0fc  kali-nethunter-rootfs-minimal-arm64.tar.xz
1ff5a8313cca728cf3c967bd2c8b59c629e8d4b9f4b35bf62b9df9f0097c8c1d  kali-nethunter-rootfs-minimal-armhf.tar.xz
484af462afa5064512f420d8565a90c7923ac6288f35d37d37dff6aa44936a23  kali-nethunter-rootfs-nano-arm64.tar.xz
d0761b79c0b303401a1ac405db1b2b223b0e3e8d60ec647a6b391fd70c595fdf  kali-nethunter-rootfs-nano-armhf.tar.xz"

ARCHIVE_STRIP_DIRS=1
BASE_URL=https://kali.download/nethunter-images/current/rootfs
TERMUX_FILES_DIR=/data/data/com.termux/files

DISTRO_SHORTCUT=${TERMUX_FILES_DIR}/usr/bin/nh
DISTRO_LAUNCHER=${TERMUX_FILES_DIR}/usr/bin/nethunter
DEFAULT_ROOTFS_DIR=${TERMUX_FILES_DIR}/kali
DEFAULT_LOGIN=kali

# Parse CLI early
parse_cli "$@"

# Load the upstream termux-distro engine
distro_template=$(realpath "$(dirname "${0}")")/termux-distro.sh
if [[ -f ${distro_template} ]] || curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh &>/dev/null; then
  # shellcheck disable=SC1090
  source "${distro_template}" "${@}" || exit 1
else
  echo "You need an active internet connection to run this program."
  exit 1
fi

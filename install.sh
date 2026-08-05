#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# GrokHunter — One-command installer
# Kali NetHunter (Rootless) powered by Grok Build + optional Termux:X11
#
# https://github.com/FineComputer14451/GrokHunter
################################################################################
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main"
REPO_TAR="https://github.com/FineComputer14451/GrokHunter/archive/refs/heads/main.tar.gz"
MODULES=(cli.sh actions.sh grok.sh x11.sh)

# Resolve where we are
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Running under curl | bash (no real script path)
  SCRIPT_DIR=""
fi

LIB_DIR=""
CLEANUP_TMP=""

fetch_modules() {
  local dest="$1"
  mkdir -p "${dest}/lib"
  local ok=0
  local m
  for m in "${MODULES[@]}"; do
    if curl -fsSL --connect-timeout 15 --retry 2 \
         "${REPO_RAW}/lib/${m}" -o "${dest}/lib/${m}"; then
      ok=$((ok + 1))
    else
      echo "[GrokHunter] Failed to fetch lib/${m}" >&2
      return 1
    fi
  done
  [[ $ok -eq ${#MODULES[@]} ]]
}

# ---------- Bootstrap -------------------------------------------------------
if [[ -n "${SCRIPT_DIR}" && -d "${SCRIPT_DIR}/lib" ]]; then
  # Normal case: running from a local clone / extracted tree
  LIB_DIR="${SCRIPT_DIR}/lib"
else
  echo "[GrokHunter] Bootstrapping modules (one-liner mode)..."

  # Prefer a persistent cache so repeated one-liners are fast
  CACHE_DIR="${HOME}/.cache/grokhunter"
  mkdir -p "${CACHE_DIR}"

  if [[ -f "${CACHE_DIR}/lib/cli.sh" && -f "${CACHE_DIR}/lib/actions.sh" \
     && -f "${CACHE_DIR}/lib/grok.sh" && -f "${CACHE_DIR}/lib/x11.sh" ]]; then
    echo "[GrokHunter] Using cached modules in ${CACHE_DIR}"
    LIB_DIR="${CACHE_DIR}/lib"
  else
    # Try lightweight individual downloads first
    if fetch_modules "${CACHE_DIR}"; then
      echo "[GrokHunter] Modules downloaded to ${CACHE_DIR}"
      LIB_DIR="${CACHE_DIR}/lib"
    else
      echo "[GrokHunter] Individual download failed — falling back to tarball..."
      TMP=$(mktemp -d)
      CLEANUP_TMP="$TMP"
      if curl -fsSL --connect-timeout 20 --retry 2 "${REPO_TAR}" \
           | tar -xz -C "$TMP" --strip-components=1 2>/dev/null; then
        if [[ -d "${TMP}/lib" ]]; then
          cp -a "${TMP}/lib" "${CACHE_DIR}/"
          LIB_DIR="${CACHE_DIR}/lib"
          echo "[GrokHunter] Modules extracted from tarball"
        else
          echo "[GrokHunter] ERROR: tarball did not contain lib/" >&2
          exit 1
        fi
      else
        echo "[GrokHunter] ERROR: could not download modules from GitHub" >&2
        echo "  Check your network or try:" >&2
        echo "  git clone https://github.com/FineComputer14451/GrokHunter.git" >&2
        exit 1
      fi
    fi
  fi
fi

# Safety check
for m in "${MODULES[@]}"; do
  if [[ ! -f "${LIB_DIR}/${m}" ]]; then
    echo "[GrokHunter] ERROR: missing module ${LIB_DIR}/${m}" >&2
    exit 1
  fi
done

# shellcheck source=/dev/null
source "${LIB_DIR}/cli.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/actions.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/grok.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/x11.sh"

# Clean temp dir if we created one
[[ -n "${CLEANUP_TMP}" && -d "${CLEANUP_TMP}" ]] && rm -rf "${CLEANUP_TMP}"

# --- Core identity (used by termux-distro template) ---------------------------
DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="install.sh"
DISTRO_REPOSITORY=termux-nethunter
KERNEL_RELEASE=$(uname -r 2>/dev/null || echo unknown)
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
distro_template=""
if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/termux-distro.sh" ]]; then
  distro_template="${SCRIPT_DIR}/termux-distro.sh"
fi

if [[ -n "${distro_template}" ]]; then
  # shellcheck disable=SC1090
  source "${distro_template}" "${@}" || exit 1
elif curl -fsSLO https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh; then
  # shellcheck disable=SC1090
  source ./termux-distro.sh "${@}" || exit 1
else
  echo "You need an active internet connection to run this program."
  exit 1
fi

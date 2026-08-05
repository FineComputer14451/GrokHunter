#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# GrokHunter Rootless — Termux one-line installer
# Coding lab: Kali NetHunter (proot) + Grok Build + optional Termux:X11 / Aider
#
# One-liner:
#   bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)
#
# Full stack:
#   bash <(curl -fsSL .../install.sh) --full --de xfce --with-grok --with-x11 --with-aider
#
# https://github.com/FineComputer14451/GrokHunter
################################################################################
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main"
REPO_TAR="https://github.com/FineComputer14451/GrokHunter/archive/refs/heads/main.tar.gz"
MODULES=(cli.sh actions.sh grok.sh x11.sh)

# ---------- Termux guards ---------------------------------------------------
if [[ -z "${PREFIX:-}" || "${PREFIX}" != *com.termux* ]]; then
  if [[ ! -d /data/data/com.termux/files/usr ]]; then
    echo "[GrokHunter] ERROR: This installer is for Termux on Android." >&2
    echo "  Install Termux from F-Droid or GitHub (not Play Store), then retry." >&2
    exit 1
  fi
  export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
fi

export PATH="${PREFIX}/bin:${PATH}"
export HOME="${HOME:-/data/data/com.termux/files/home}"
export TMPDIR="${TMPDIR:-${PREFIX}/tmp}"
mkdir -p "${TMPDIR}" 2>/dev/null || true

# ---------- Fast prerequisites (Termux pkg) ---------------------------------
need_pkg=0
for c in curl tar bash; do
  command -v "$c" >/dev/null 2>&1 || need_pkg=1
done
if [[ "$need_pkg" -eq 1 ]]; then
  echo "[GrokHunter] Installing Termux prerequisites (curl tar)..."
  pkg update -y >/dev/null 2>&1 || true
  pkg install -y curl tar >/dev/null 2>&1 || {
    echo "[GrokHunter] ERROR: need curl and tar. Run: pkg install curl tar" >&2
    exit 1
  }
fi

if command -v termux-wake-lock >/dev/null 2>&1; then
  termux-wake-lock 2>/dev/null || true
  trap 'termux-wake-unlock 2>/dev/null || true' EXIT
fi

# ---------- Resolve script location -----------------------------------------
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR=""
fi

LIB_DIR=""
CLEANUP_TMP=""
CACHE_DIR="${HOME}/.cache/grokhunter"
REFRESH="${GROKHUNTER_REFRESH:-0}"

fetch_modules() {
  local dest="$1"
  mkdir -p "${dest}/lib"
  local m fail=0
  for m in "${MODULES[@]}"; do
    if ! curl -fsSL --connect-timeout 12 --max-time 60 --retry 3 --retry-delay 1 \
         "${REPO_RAW}/lib/${m}" -o "${dest}/lib/${m}"; then
      echo "[GrokHunter] Failed to fetch lib/${m}" >&2
      fail=1
      break
    fi
  done
  [[ $fail -eq 0 ]]
}

# ---------- Bootstrap modules -----------------------------------------------
if [[ -n "${SCRIPT_DIR}" && -d "${SCRIPT_DIR}/lib" && "${REFRESH}" != "1" ]]; then
  LIB_DIR="${SCRIPT_DIR}/lib"
  echo "[GrokHunter] Using local modules: ${LIB_DIR}"
else
  echo "[GrokHunter] Termux one-liner bootstrap..."
  mkdir -p "${CACHE_DIR}"

  if [[ "${REFRESH}" != "1" \
     && -f "${CACHE_DIR}/lib/cli.sh" \
     && -f "${CACHE_DIR}/lib/actions.sh" \
     && -f "${CACHE_DIR}/lib/grok.sh" \
     && -f "${CACHE_DIR}/lib/x11.sh" ]]; then
    echo "[GrokHunter] Cache hit → ${CACHE_DIR}/lib"
    LIB_DIR="${CACHE_DIR}/lib"
  else
    [[ "${REFRESH}" == "1" ]] && echo "[GrokHunter] Refreshing module cache..."
    if fetch_modules "${CACHE_DIR}"; then
      echo "[GrokHunter] Modules ready in ${CACHE_DIR}"
      LIB_DIR="${CACHE_DIR}/lib"
    else
      echo "[GrokHunter] Falling back to full tarball..."
      TMP=$(mktemp -d)
      CLEANUP_TMP="$TMP"
      if curl -fsSL --connect-timeout 20 --max-time 180 --retry 2 \
           "${REPO_TAR}" | tar -xz -C "$TMP" --strip-components=1 2>/dev/null \
         && [[ -d "${TMP}/lib" ]]; then
        rm -rf "${CACHE_DIR}/lib"
        cp -a "${TMP}/lib" "${CACHE_DIR}/"
        LIB_DIR="${CACHE_DIR}/lib"
        echo "[GrokHunter] Modules from tarball"
      else
        echo "[GrokHunter] ERROR: cannot download modules from GitHub." >&2
        echo "  Try: pkg install git && git clone https://github.com/FineComputer14451/GrokHunter.git" >&2
        echo "       cd GrokHunter && bash install.sh" >&2
        exit 1
      fi
    fi
  fi
fi

for m in "${MODULES[@]}"; do
  if [[ ! -f "${LIB_DIR}/${m}" ]]; then
    echo "[GrokHunter] ERROR: missing ${LIB_DIR}/${m}" >&2
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

[[ -n "${CLEANUP_TMP}" && -d "${CLEANUP_TMP}" ]] && rm -rf "${CLEANUP_TMP}"

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="install.sh"
DISTRO_REPOSITORY=termux-nethunter
KERNEL_RELEASE=$(uname -r 2>/dev/null || echo unknown)
VERSION_NAME="GrokHunter-Rootless-2026.2"

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

parse_cli "$@"

distro_template=""
if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/termux-distro.sh" ]]; then
  distro_template="${SCRIPT_DIR}/termux-distro.sh"
fi

if [[ -n "${distro_template}" ]]; then
  # shellcheck disable=SC1090
  source "${distro_template}" "${@}" || exit 1
elif curl -fsSL --connect-timeout 15 --retry 2 \
       -o ./termux-distro.sh \
       https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh; then
  # shellcheck disable=SC1090
  source ./termux-distro.sh "${@}" || exit 1
else
  echo "[GrokHunter] ERROR: need network to fetch termux-distro engine." >&2
  exit 1
fi

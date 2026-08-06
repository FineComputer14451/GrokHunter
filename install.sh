#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# GrokHunter Rootless — Termux one-line installer
# Coding lab: Kali NetHunter (proot) + Grok Build + optional Termux:X11 / Aider
#
# https://github.com/FineComputer14451/GrokHunter
################################################################################
set -euo pipefail

die()  { echo "[GrokHunter] ERROR: $*" >&2; exit 1; }
warn() { echo "[GrokHunter] WARN: $*" >&2; }
info() { echo "[GrokHunter] $*"; }

REPO_RAW="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main"
REPO_TAR="https://github.com/FineComputer14451/GrokHunter/archive/refs/heads/main.tar.gz"
MODULES=(cli.sh actions.sh grok.sh x11.sh)
MODULES_VERSION="2026.2.5"

CLEANUP_TMP=""
WAKE_HELD=0

cleanup() {
  local ec=$?
  [[ -n "${CLEANUP_TMP:-}" && -d "${CLEANUP_TMP}" ]] && rm -rf "${CLEANUP_TMP}" || true
  if [[ "${WAKE_HELD}" -eq 1 ]] && command -v termux-wake-unlock >/dev/null 2>&1; then
    termux-wake-unlock 2>/dev/null || true
  fi
  exit "${ec}"
}
trap cleanup EXIT

if [[ -z "${PREFIX:-}" || "${PREFIX}" != *com.termux* ]]; then
  if [[ ! -d /data/data/com.termux/files/usr ]]; then
    die "This installer is for Termux on Android. Install Termux from F-Droid or GitHub (not Play Store)."
  fi
  export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
fi

export PATH="${PREFIX}/bin:${PATH:-}"
export HOME="${HOME:-/data/data/com.termux/files/home}"
export TMPDIR="${TMPDIR:-${PREFIX}/tmp}"

if ! mkdir -p "${TMPDIR}" 2>/dev/null; then die "cannot create TMPDIR=${TMPDIR}"; fi
[[ -w "${HOME}" ]] || die "HOME not writable: ${HOME}"

need_pkg=0
for c in curl tar bash; do command -v "$c" >/dev/null 2>&1 || need_pkg=1; done
if [[ "${need_pkg}" -eq 1 ]]; then
  info "Installing Termux prerequisites (curl tar)..."
  command -v pkg >/dev/null 2>&1 || die "pkg not found"
  pkg update -y >/dev/null 2>&1 || warn "pkg update failed (continuing)"
  pkg install -y curl tar >/dev/null 2>&1 || die "need curl and tar"
fi
command -v curl >/dev/null 2>&1 || die "curl still missing"
command -v tar >/dev/null 2>&1 || die "tar still missing"

if command -v termux-wake-lock >/dev/null 2>&1; then
  if termux-wake-lock 2>/dev/null; then WAKE_HELD=1; else warn "termux-wake-lock failed"; fi
fi

if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || SCRIPT_DIR=""
else SCRIPT_DIR=""; fi

LIB_DIR=""
CACHE_DIR="${HOME}/.cache/grokhunter"
REFRESH="${GROKHUNTER_REFRESH:-0}"

validate_module() {
  local f="$1"
  [[ -f "$f" && -s "$f" ]] || return 1
  grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)' "$f" 2>/dev/null || return 1
  return 0
}

fetch_modules() {
  local dest="$1"
  mkdir -p "${dest}/lib" || die "cannot create ${dest}/lib"
  local m fail=0
  for m in "${MODULES[@]}"; do
    if ! curl -fsSL --connect-timeout 12 --max-time 60 --retry 3 --retry-delay 1 \
         "${REPO_RAW}/lib/${m}" -o "${dest}/lib/${m}"; then
      warn "Failed to fetch lib/${m}"; fail=1; break
    fi
    if ! validate_module "${dest}/lib/${m}"; then
      warn "Downloaded lib/${m} looks invalid"; fail=1; break
    fi
  done
  [[ $fail -eq 0 ]]
}

if [[ -n "${SCRIPT_DIR}" && -d "${SCRIPT_DIR}/lib" && "${REFRESH}" != "1" ]]; then
  LIB_DIR="${SCRIPT_DIR}/lib"; info "Using local modules: ${LIB_DIR}"
else
  info "Termux one-liner bootstrap..."
  mkdir -p "${CACHE_DIR}" || die "cannot create cache ${CACHE_DIR}"
  cache_ok=0
  if [[ "${REFRESH}" != "1" \
     && -f "${CACHE_DIR}/lib/cli.sh" && -f "${CACHE_DIR}/lib/actions.sh" \
     && -f "${CACHE_DIR}/lib/grok.sh" && -f "${CACHE_DIR}/lib/x11.sh" \
     && -f "${CACHE_DIR}/MODULES_VERSION" ]] \
     && [[ "$(cat "${CACHE_DIR}/MODULES_VERSION" 2>/dev/null)" == "${MODULES_VERSION}" ]]; then
    cache_ok=1
  fi
  if [[ "${cache_ok}" -eq 1 ]]; then
    info "Cache hit → ${CACHE_DIR}/lib (v${MODULES_VERSION})"; LIB_DIR="${CACHE_DIR}/lib"
  else
    [[ "${REFRESH}" == "1" ]] && info "Refreshing module cache..."
    if fetch_modules "${CACHE_DIR}"; then
      printf '%s\n' "${MODULES_VERSION}" > "${CACHE_DIR}/MODULES_VERSION"
      info "Modules ready in ${CACHE_DIR}"; LIB_DIR="${CACHE_DIR}/lib"
    else
      info "Falling back to full tarball..."
      CLEANUP_TMP="$(mktemp -d "${TMPDIR}/grokhunter.XXXXXX")" || die "mktemp failed"
      if curl -fsSL --connect-timeout 20 --max-time 180 --retry 2 \
           "${REPO_TAR}" | tar -xz -C "${CLEANUP_TMP}" --strip-components=1 2>/dev/null \
         && [[ -d "${CLEANUP_TMP}/lib" ]]; then
        rm -rf "${CACHE_DIR}/lib"; mkdir -p "${CACHE_DIR}"
        cp -a "${CLEANUP_TMP}/lib" "${CACHE_DIR}/" || die "failed to copy modules"
        LIB_DIR="${CACHE_DIR}/lib"
        printf '%s\n' "${MODULES_VERSION}" > "${CACHE_DIR}/MODULES_VERSION"
        info "Modules from tarball"
      else
        die "cannot download modules from GitHub. Clone repo and run bash install.sh"
      fi
    fi
  fi
fi

[[ -n "${LIB_DIR}" && -d "${LIB_DIR}" ]] || die "LIB_DIR not set"
for m in "${MODULES[@]}"; do
  validate_module "${LIB_DIR}/${m}" || die "missing or invalid ${LIB_DIR}/${m} (try GROKHUNTER_REFRESH=1)"
done

# shellcheck source=/dev/null
source "${LIB_DIR}/cli.sh" || die "failed to source cli.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/actions.sh" || die "failed to source actions.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/grok.sh" || die "failed to source grok.sh"
# shellcheck source=/dev/null
source "${LIB_DIR}/x11.sh" || die "failed to source x11.sh"

for fn in parse_cli install_grok_build setup_termux_x11; do
  declare -F "$fn" >/dev/null 2>&1 || die "module missing function: $fn"
done

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="install.sh"
DISTRO_REPOSITORY=termux-nethunter
KERNEL_RELEASE=$(uname -r 2>/dev/null || echo unknown)
VERSION_NAME="GrokHunter-Rootless-2026.2"
SHASUM_CMD=sha256sum
TRUSTED_SHASUMS="b8098fc90ed74a553592f7019a1d88dfe3c65b16c60af487b0658860554dc5aa  kali-nethunter-rootfs-full-arm64.tar.xz"
ARCHIVE_STRIP_DIRS=1
BASE_URL=https://kali.download/nethunter-images/current/rootfs
TERMUX_FILES_DIR=/data/data/com.termux/files
DISTRO_SHORTCUT=${TERMUX_FILES_DIR}/usr/bin/nh
DISTRO_LAUNCHER=${TERMUX_FILES_DIR}/usr/bin/nethunter
DEFAULT_ROOTFS_DIR=${TERMUX_FILES_DIR}/kali
DEFAULT_LOGIN=kali

parse_cli "$@" || die "CLI parse failed"

# termux-distro msg() uses ${P}/${S}/${N}/... before colors() runs.
# Under set -u that is fatal ("P: unbound variable"). Seed + disable nounset.
: "${N:=}" "${R:=}" "${G:=}" "${Y:=}" "${B:=}" "${M:=}" "${C:=}" "${W:=}"
: "${P:=}" "${S:=}" "${T:=}"
: "${HC:=}" "${RC:=}" "${SU:=}" "${RU:=}" "${SV:=}" "${RV:=}"
: "${ENABLE_COLOR:=1}"
: "${SYS_ARCH:=}" "${ROOTFS_DIRECTORY:=}" "${LOG_FILE:=/dev/null}"
: "${KEEP_ROOTFS_DIRECTORY:=}" "${DE_INSTALLED:=}"

_source_termux_distro() {
  local engine="$1"
  shift
  set +u
  # shellcheck source=/dev/null
  source "${engine}" "$@"
  local ec=$?
  set -u
  return "${ec}"
}

distro_template=""
if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/termux-distro.sh" ]]; then
  distro_template="${SCRIPT_DIR}/termux-distro.sh"
fi
if [[ -n "${distro_template}" ]]; then
  _source_termux_distro "${distro_template}" "$@" || die "termux-distro engine failed"
else
  curl -fsSL --connect-timeout 15 --max-time 90 --retry 2 \
    -o ./termux-distro.sh \
    https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh \
    || die "need network to fetch termux-distro engine"
  [[ -s ./termux-distro.sh ]] || die "downloaded termux-distro.sh is empty"
  _source_termux_distro ./termux-distro.sh "$@" || die "termux-distro engine failed after download"
fi

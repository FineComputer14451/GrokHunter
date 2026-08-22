#!/data/data/com.termux/files/usr/bin/bash
################################################################################
# GrokHunter Rootless — Termux one-line installer
# Coding lab: Kali NetHunter (proot) + Grok Build + optional Termux:X11 / Aider
#
# https://github.com/FineComputer14451/GrokHunter
#
# BUILT ON (please support upstream — see CREDITS.md):
#   jorexdeveloper — termux-nethunter & termux-distro (GPL-3.0)
#     https://github.com/jorexdeveloper/termux-nethunter
#     https://github.com/jorexdeveloper/termux-distro
#   Termux team — host platform, packages, Termux:X11
#     https://termux.dev  ·  https://github.com/termux
#   Kali Linux / Offensive Security — NetHunter rootfs images
#     https://www.kali.org  ·  https://kali.download/nethunter-images/
#   xAI — Grok Build CLI & Grok models
#     https://x.ai/cli  ·  https://docs.x.ai
# Not affiliated with the above; we build upon their work with attribution.
################################################################################
set -euo pipefail

die()  { echo "[GrokHunter] ERROR: $*" >&2; exit 1; }
warn() { echo "[GrokHunter] WARN: $*" >&2; }
# Status on stderr so command substitutions (e.g. resolve_distro_engine) stay clean.
info() { echo "[GrokHunter] $*" >&2; }

# Rich error helper with recovery steps
die_with_help() {
  local msg="$1"
  shift
  echo "[GrokHunter] ERROR: ${msg}" >&2
  if [[ $# -gt 0 ]]; then
    echo >&2
    echo "[GrokHunter] What to try:" >&2
    local i=1
    for step in "$@"; do
      printf "  %d. %s\n" "$i" "$step" >&2
      ((i++)) || true
    done
  fi
  exit 1
}

REPO_RAW="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main"
REPO_TAR="https://github.com/FineComputer14451/GrokHunter/archive/refs/heads/main.tar.gz"
MODULES=(cli.sh actions.sh grok.sh x11.sh)
DISCOVER_MODULES=(skills-discover.sh agents-discover.sh personas-discover.sh roles-discover.sh)
MODULES_VERSION="2026.2.18"
OVERLAY_ITEMS=(
  install.sh uninstall.sh VERSION LICENSE CREDITS.md AGENTS.md README.md CHANGELOG.md
)
OVERLAY_DIRS=(
  bin lib scripts skills agents personas roles config templates branding docs
)

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
    die_with_help "This installer only works inside Termux on Android." \
      "Install Termux from F-Droid: https://f-droid.org/packages/com.termux/" \
      "Or from GitHub releases: https://github.com/termux/termux-app/releases" \
      "Do NOT use the Play Store version of Termux."
  fi
  export PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
fi

export PATH="${PREFIX}/bin:${PATH:-}"
export HOME="${HOME:-/data/data/com.termux/files/home}"
export TMPDIR="${TMPDIR:-${PREFIX}/tmp}"

if ! mkdir -p "${TMPDIR}" 2>/dev/null; then
  die_with_help "Cannot create TMPDIR=${TMPDIR}." \
    "Check that Termux has storage permission (run: termux-setup-storage)" \
    "Restart Termux and try again."
fi
[[ -w "${HOME}" ]] || die_with_help "HOME is not writable: ${HOME}" \
  "Run: termux-setup-storage" \
  "Then restart Termux and re-run the installer."

need_pkg=0
for c in curl tar bash; do command -v "$c" >/dev/null 2>&1 || need_pkg=1; done
if [[ "${need_pkg}" -eq 1 ]]; then
  info "Installing Termux prerequisites (curl tar)..."
  command -v pkg >/dev/null 2>&1 || die_with_help "pkg command not found." \
    "You must be running inside a working Termux environment." \
    "Reinstall Termux from F-Droid or GitHub if needed."
  pkg update -y >/dev/null 2>&1 || warn "pkg update failed (continuing)"
  pkg install -y curl tar >/dev/null 2>&1 || die_with_help "Failed to install curl and tar." \
    "Run manually:  pkg update && pkg install -y curl tar" \
    "Then re-run this installer."
fi
command -v curl >/dev/null 2>&1 || die_with_help "curl is still missing after install attempt." \
  "Run:  pkg install -y curl" \
  "Then re-run the installer."
command -v tar >/dev/null 2>&1 || die_with_help "tar is still missing after install attempt." \
  "Run:  pkg install -y tar" \
  "Then re-run the installer."

if command -v termux-wake-lock >/dev/null 2>&1; then
  if termux-wake-lock 2>/dev/null; then WAKE_HELD=1; else warn "termux-wake-lock failed"; fi
fi

if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || SCRIPT_DIR=""
else SCRIPT_DIR=""; fi

# Process substitution (`bash <(curl …)`) yields /dev/fd or /proc/self/fd — not a real overlay.
_gh_is_ephemeral_dir() {
  local d="${1:-}"
  [[ -z "$d" ]] && return 0
  case "$d" in
    /dev/fd|/dev/fd/*|/proc/self/fd|/proc/self/fd/*|/proc/*/fd|/proc/*/fd/*) return 0 ;;
  esac
  [[ "$d" == /dev/fd* || "$d" == /proc/*/fd* ]] && return 0
  return 1
}

if _gh_is_ephemeral_dir "${SCRIPT_DIR}" || [[ ! -f "${SCRIPT_DIR}/install.sh" ]]; then
  SCRIPT_DIR=""
fi

LIB_DIR=""
OVERLAY_ROOT=""
CACHE_DIR="${HOME}/.cache/grokhunter"
REFRESH="${GROKHUNTER_REFRESH:-0}"

validate_module() {
  local f="$1"
  [[ -f "$f" && -s "$f" ]] || return 1
  grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)' "$f" 2>/dev/null || return 1
  return 0
}

_gh_overlay_complete() {
  local dir="${1:-}"
  [[ -n "${dir}" && -d "${dir}" ]] || return 1
  [[ -f "${dir}/install.sh" ]] || return 1
  [[ -f "${dir}/lib/grok.sh" ]] || return 1
  [[ -f "${dir}/lib/skills-discover.sh" ]] || return 1
  [[ -f "${dir}/lib/agents-discover.sh" ]] || return 1
  [[ -f "${dir}/lib/personas-discover.sh" ]] || return 1
  [[ -f "${dir}/lib/roles-discover.sh" ]] || return 1
  [[ -f "${dir}/bin/grokhunter" ]] || return 1
  [[ -f "${dir}/scripts/install-completions.sh" ]] || return 1
  [[ -f "${dir}/scripts/ensure_grok.sh" ]] || return 1
  [[ -d "${dir}/skills" ]] || return 1
  return 0
}

# True if dir is a real GrokHunter overlay (complete tree or git clone), not a stray install.sh.
_gh_managed_overlay() {
  local dir="${1:-}"
  [[ -n "${dir}" && -d "${dir}" ]] || return 1
  _gh_is_ephemeral_dir "${dir}" && return 1
  if _gh_overlay_complete "${dir}"; then
    return 0
  fi
  if [[ -f "${dir}/install.sh" && -d "${dir}/.git" ]]; then
    return 0
  fi
  return 1
}

# Clone / GROKHUNTER_HOME / ~/GrokHunter / cache src (never a foreign non-empty dir).
_gh_pick_overlay_dest() {
  local home_dest="${HOME}/GrokHunter"
  local cache_src="${CACHE_DIR}/src"

  if [[ -n "${SCRIPT_DIR}" ]] && _gh_managed_overlay "${SCRIPT_DIR}"; then
    printf '%s\n' "${SCRIPT_DIR}"
    return 0
  fi

  if [[ -n "${GROKHUNTER_HOME:-}" ]] && _gh_managed_overlay "${GROKHUNTER_HOME}"; then
    printf '%s\n' "${GROKHUNTER_HOME}"
    return 0
  fi

  if [[ ! -e "${home_dest}" ]]; then
    printf '%s\n' "${home_dest}"
    return 0
  fi
  if [[ -d "${home_dest}" ]]; then
    if [[ -z "$(ls -A "${home_dest}" 2>/dev/null)" ]]; then
      printf '%s\n' "${home_dest}"
      return 0
    fi
    if _gh_managed_overlay "${home_dest}"; then
      printf '%s\n' "${home_dest}"
      return 0
    fi
  fi
  printf '%s\n' "${cache_src}"
}

_gh_stamp_overlay() {
  mkdir -p "${CACHE_DIR}" || true
  printf '%s\n' "${MODULES_VERSION}" > "${CACHE_DIR}/MODULES_VERSION"
  printf '%s\n' "${OVERLAY_ROOT}" > "${CACHE_DIR}/OVERLAY_ROOT"
  if [[ -n "${LIB_DIR}" && -d "${LIB_DIR}" ]]; then
    rm -rf "${CACHE_DIR}/lib"
    cp -a "${LIB_DIR}" "${CACHE_DIR}/" 2>/dev/null || true
  fi
}

_gh_fetch_repo_tarball() {
  CLEANUP_TMP="$(mktemp -d "${TMPDIR}/grokhunter.XXXXXX")" || die "mktemp failed"
  info "Fetching GrokHunter overlay (tarball)…"
  if curl -fsSL --connect-timeout 20 --max-time 180 --retry 2 \
       "${REPO_TAR}" | tar -xz -C "${CLEANUP_TMP}" --strip-components=1 2>/dev/null \
     && [[ -d "${CLEANUP_TMP}/lib" && -f "${CLEANUP_TMP}/install.sh" ]]; then
    return 0
  fi
  die_with_help "Failed to download GrokHunter overlay from GitHub." \
    "Check your internet connection" \
    "Force a clean re-download:  GROKHUNTER_REFRESH=1 bash <(curl -fsSL ${REPO_RAW}/install.sh) --overlay-only --with-completions" \
    "Or clone and run locally:  git clone https://github.com/FineComputer14451/GrokHunter.git && cd GrokHunter && bash install.sh"
}

_gh_install_overlay_from_tmp() {
  local dest="$1"
  local item
  [[ -n "${CLEANUP_TMP}" && -d "${CLEANUP_TMP}" ]] || die "overlay tmp missing"
  mkdir -p "${dest}" || die "cannot create overlay dest ${dest}"
  for item in "${OVERLAY_ITEMS[@]}"; do
    if [[ -e "${CLEANUP_TMP}/${item}" ]]; then
      cp -a "${CLEANUP_TMP}/${item}" "${dest}/" || die "failed to copy ${item}"
    fi
  done
  for item in "${OVERLAY_DIRS[@]}"; do
    if [[ -d "${CLEANUP_TMP}/${item}" ]]; then
      rm -rf "${dest}/${item}"
      cp -a "${CLEANUP_TMP}/${item}" "${dest}/" || die "failed to copy ${item}/"
    fi
  done
}

# One-liner: extract full overlay (bin/scripts/skills). Clone: local tree always wins.
ensure_overlay_tree() {
  mkdir -p "${CACHE_DIR}" || die "cannot create cache ${CACHE_DIR}"
  local dest
  dest="$(_gh_pick_overlay_dest)"

  # Git clone: local tree always wins (including REFRESH=1). Never tar onto .git.
  if [[ -n "${SCRIPT_DIR}" && "${dest}" == "${SCRIPT_DIR}" && -d "${SCRIPT_DIR}/.git" ]]; then
    if ! _gh_overlay_complete "${SCRIPT_DIR}"; then
      die_with_help "Git clone overlay is incomplete (missing bin/scripts/skills)." \
        "Run:  git pull" \
        "Or clone a fresh copy:  git clone https://github.com/FineComputer14451/GrokHunter.git"
    fi
    OVERLAY_ROOT="${SCRIPT_DIR}"
    LIB_DIR="${SCRIPT_DIR}/lib"
    export GROKHUNTER_HOME="${OVERLAY_ROOT}"
    info "Using local overlay: ${OVERLAY_ROOT}"
    _gh_stamp_overlay
    return 0
  fi

  # Extracted (non-git) tree: use local when complete unless REFRESH=1.
  # Incomplete trees fall through so the tarball can repair them.
  if [[ -n "${SCRIPT_DIR}" && "${dest}" == "${SCRIPT_DIR}" && -d "${SCRIPT_DIR}/lib" ]] \
     && [[ "${REFRESH}" != "1" ]] && _gh_overlay_complete "${SCRIPT_DIR}"; then
    OVERLAY_ROOT="${SCRIPT_DIR}"
    LIB_DIR="${SCRIPT_DIR}/lib"
    export GROKHUNTER_HOME="${OVERLAY_ROOT}"
    info "Using local overlay: ${OVERLAY_ROOT}"
    _gh_stamp_overlay
    return 0
  fi

  if [[ "${REFRESH}" != "1" ]] && _gh_overlay_complete "${dest}" \
     && [[ "$(cat "${CACHE_DIR}/MODULES_VERSION" 2>/dev/null || true)" == "${MODULES_VERSION}" ]]; then
    OVERLAY_ROOT="${dest}"
    LIB_DIR="${dest}/lib"
    SCRIPT_DIR="${dest}"
    export GROKHUNTER_HOME="${dest}"
    info "Cache hit → overlay ${OVERLAY_ROOT} (v${MODULES_VERSION})"
    _gh_stamp_overlay
    return 0
  fi

  if [[ -d "${dest}/.git" ]]; then
    die_with_help "Refusing to extract tarball onto git clone: ${dest}" \
      "cd ${dest} && git pull" \
      "Or:  GROKHUNTER_HOME=${HOME}/GrokHunter bash install.sh --overlay-only --with-completions"
  fi

  [[ "${REFRESH}" == "1" ]] && info "Refreshing overlay from GitHub tarball..."
  info "Termux one-liner bootstrap (full overlay)…"
  _gh_fetch_repo_tarball
  _gh_install_overlay_from_tmp "${dest}"
  _gh_overlay_complete "${dest}" || die_with_help "Extracted overlay looks incomplete: ${dest}" \
    "Force a clean re-download:  GROKHUNTER_REFRESH=1 bash <(curl -fsSL ${REPO_RAW}/install.sh) --overlay-only --with-completions" \
    "Or clone:  git clone https://github.com/FineComputer14451/GrokHunter.git && cd GrokHunter && bash install.sh"
  OVERLAY_ROOT="${dest}"
  LIB_DIR="${dest}/lib"
  SCRIPT_DIR="${dest}"
  export GROKHUNTER_HOME="${dest}"
  _gh_stamp_overlay
  info "Overlay ready → ${OVERLAY_ROOT}"
}

ensure_overlay_tree

[[ -n "${LIB_DIR}" && -d "${LIB_DIR}" ]] || die "LIB_DIR not set"
for m in "${MODULES[@]}" "${DISCOVER_MODULES[@]}"; do
  validate_module "${LIB_DIR}/${m}" || die_with_help "Missing or invalid module: ${LIB_DIR}/${m}" \
    "Force a clean re-download:  GROKHUNTER_REFRESH=1 bash install.sh --overlay-only --with-completions" \
    "Or clone a fresh copy of the repository and run bash install.sh"
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
  declare -F "$fn" >/dev/null 2>&1 || die_with_help "Installer modules are incomplete or corrupted (missing function: $fn)." \
    "Force a clean re-download:  GROKHUNTER_REFRESH=1 bash install.sh" \
    "Or clone a fresh copy of the repository"
done

DISTRO_NAME="Kali NetHunter"
PROGRAM_NAME="install.sh"
DISTRO_REPOSITORY=termux-nethunter
KERNEL_RELEASE=$(uname -r 2>/dev/null || echo unknown)
VERSION_NAME="GrokHunter-Rootless-2026.2.18"
SHASUM_CMD=sha256sum

# Offline / air-gapped fallbacks (live SHA from Kali /current/ is preferred).
# Last verified: 2026-08-05
TRUSTED_SHASUMS_FALLBACK_DATE="2026-08-05"
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

parse_cli "$@" || die_with_help "Invalid command-line options." \
  "Run with --help to see available flags" \
  "Example:  bash install.sh --full --de xfce --with-grok --with-x11"

# Lightweight messaging when termux-distro is not loaded (overlay-only).
_ensure_msg_stubs() {
  if declare -F msg >/dev/null 2>&1; then
    return 0
  fi
  msg() {
    # Compatible with termux-distro msg flags: -t -tn -ts -tw -te -a
    shift || true
    printf '[GrokHunter] %s\n' "$*"
  }
  cursor() { :; }
}

# Overlay-only: optional packages without re-downloading NetHunter rootfs.
if [[ "${OVERLAY_ONLY:-0}" -eq 1 ]]; then
  info "Overlay-only mode — skipping rootfs / termux-distro engine"
  : "${ROOTFS_DIRECTORY:=${DEFAULT_ROOTFS_DIR:-/data/data/com.termux/files/kali}}"
  : "${TERMUX_FILES_DIR:=/data/data/com.termux/files}"
  : "${P:=}" "${S:=}" "${T:=}" "${W:=}" "${B:=}" "${M:=}"
  _ensure_msg_stubs
  if [[ -z "${GROKHUNTER_HOME:-}" ]] || _gh_is_ephemeral_dir "${GROKHUNTER_HOME}"; then
    export GROKHUNTER_HOME="${OVERLAY_ROOT:-${SCRIPT_DIR:-${HOME}/GrokHunter}}"
  fi
  if _gh_is_ephemeral_dir "${GROKHUNTER_HOME}"; then
    export GROKHUNTER_HOME="${HOME}/GrokHunter"
  fi
  # Default: if user passed only --overlay-only with no --with-*, nothing runs.
  # Require at least one explicit yes feature, or warn.
  if [[ "${FEATURE_GROK}" == "auto" && "${FEATURE_X11}" == "auto" \
     && "${FEATURE_AIDER}" == "auto" && "${FEATURE_V9}" == "auto" \
     && "${FEATURE_COMPLETIONS}" == "auto" ]]; then
    die_with_help "Overlay-only needs at least one --with-* flag." \
      "Example:  bash install.sh --overlay-only --with-x11 --with-aider" \
      "Example:  bash install.sh --overlay-only --with-grok --with-v9-models --with-completions"
  fi
  run_optional_features
  echo
  info "Overlay-only complete."
  info "  PATH wrappers:  ~/.local/bin (grokhunter, doctor, …)"
  info "  doctor:  grokhunter doctor   # or bash ${GROKHUNTER_HOME}/bin/grokhunter-doctor"
  info "  models:  grokhunter models status"
  exit 0
fi

# termux-distro msg() uses ${P}/${S}/${N}/... before colors() runs.
# Under set -u that is fatal (\"P: unbound variable\"). Seed + disable nounset.
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

# Validate termux-distro engine: non-empty, not an HTML error page, looks like shell.
validate_distro_engine() {
  local f="$1"
  [[ -f "$f" && -s "$f" ]] || return 1
  if head -c 256 "$f" 2>/dev/null | grep -qiE '<!DOCTYPE|<html'; then
    return 1
  fi
  if head -1 "$f" 2>/dev/null | grep -qE '^#!'; then
    return 0
  fi
  grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*\s*\(\)' "$f" 2>/dev/null
}

# Prefer vendored → cached (same URL stamp) → download into ~/.cache (never pollute CWD).
# Override URL: GROKHUNTER_DISTRO_ENGINE_URL  (honored even when cache exists)
resolve_distro_engine() {
  local default_url="https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh"
  local url="${GROKHUNTER_DISTRO_ENGINE_URL:-${default_url}}"
  local cache_file="${CACHE_DIR}/termux-distro.sh"
  local stamp_file="${CACHE_DIR}/termux-distro.url"
  local dest=""
  local stamp=""

  if [[ -n "${SCRIPT_DIR}" && -f "${SCRIPT_DIR}/termux-distro.sh" ]]; then
    if validate_distro_engine "${SCRIPT_DIR}/termux-distro.sh"; then
      printf '%s\n' "${SCRIPT_DIR}/termux-distro.sh"
      return 0
    fi
    warn "Vendored termux-distro.sh failed validation — trying cache/download"
  fi

  stamp="$(cat "${stamp_file}" 2>/dev/null || true)"

  if [[ "${REFRESH}" != "1" ]] && validate_distro_engine "${cache_file}"; then
    if [[ "${stamp}" == "${url}" ]]; then
      info "Using cached termux-distro engine → ${cache_file}"
      printf '%s\n' "${cache_file}"
      return 0
    fi
    # Pre-stamp caches (no .url file) are treated as the default engine.
    if [[ -z "${GROKHUNTER_DISTRO_ENGINE_URL:-}" && -z "${stamp}" ]]; then
      info "Using cached termux-distro engine → ${cache_file}"
      printf '%s\n' "${cache_file}"
      return 0
    fi
    info "Engine URL stamp mismatch — fetching ${url}"
  fi

  mkdir -p "${CACHE_DIR}" || die "cannot create cache ${CACHE_DIR}"
  dest="$(mktemp "${CACHE_DIR}/termux-distro.XXXXXX")" || die "mktemp failed for distro engine"
  info "Fetching termux-distro engine…"
  if ! curl -fsSL --connect-timeout 15 --max-time 90 --retry 2 \
       "${url}" -o "${dest}"; then
    rm -f "${dest}"
    die_with_help "Could not download the termux-distro engine." \
      "Check your internet connection / DNS" \
      "Pin a fork:  GROKHUNTER_DISTRO_ENGINE_URL=https://… bash install.sh" \
      "Or vendor termux-distro.sh next to install.sh"
  fi
  if ! validate_distro_engine "${dest}"; then
    rm -f "${dest}"
    die_with_help "Downloaded termux-distro engine looks invalid (empty or HTML)." \
      "Check GROKHUNTER_DISTRO_ENGINE_URL if set" \
      "Force refresh:  GROKHUNTER_REFRESH=1 bash install.sh" \
      "Or clone the repo and vendor termux-distro.sh"
  fi
  mv -f "${dest}" "${cache_file}" || die "failed to install engine cache at ${cache_file}"
  printf '%s\n' "${url}" > "${stamp_file}" || true
  info "Engine cached at ${cache_file}"
  printf '%s\n' "${cache_file}"
}

DISTRO_ENGINE="$(resolve_distro_engine)" \
  || die_with_help "Could not resolve termux-distro engine." \
    "GROKHUNTER_REFRESH=1 bash install.sh" \
    "Or vendor termux-distro.sh next to install.sh"

# parse_cli already applied GrokHunter flags into SELECTED_* / FEATURE_* / etc.
# Do NOT forward "$@" into termux-distro — it only accepts its own options
# (-d, -l, --install-only, …) and rejects --full / --with-* as "Unrecognized option".
_source_termux_distro "${DISTRO_ENGINE}" || die_with_help "termux-distro engine failed." \
  "Try again with a stable connection" \
  "Force refresh:  GROKHUNTER_REFRESH=1 bash install.sh" \
  "Or clone the repo and run:  bash install.sh"

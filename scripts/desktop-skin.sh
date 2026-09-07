#!/usr/bin/env bash
# GrokHunter XFCE desktop skin — apply / status / revert.
# Rootless, user xfconf only. Does not touch /usr/share/themes.
#
# Run inside Kali (nethunter) with a live X session:
#   nethunter
#   DISPLAY=:0 bash scripts/desktop-skin.sh apply --plate og --dpi 120
#
# Usage:
#   bash scripts/desktop-skin.sh apply [--plate og|banner|minimal|PATH] [--dpi N] [--panel-slim] [--panel-size N] [--terminal] [--dry-run]
#   bash scripts/desktop-skin.sh status
#   bash scripts/desktop-skin.sh revert [--dry-run]
#   bash scripts/desktop-skin.sh self-test
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
CMD="${1:-}"
[[ -n "${CMD}" ]] && shift || true

PLATE="og"
DPI=""
DO_TERMINAL=0
DO_PANEL_SLIM=0
PANEL_SIZE="32"
DRY=0

STATE_DIR="${GROKHUNTER_SKIN_STATE:-${HOME}/.local/share/grokhunter/desktop-skin}"
SNAP="${STATE_DIR}/snapshot.env"
BG_DIR="${HOME}/.local/share/backgrounds/grokhunter"
TERM_RC="${HOME}/.config/xfce4/terminal/terminalrc"
TERM_BAK="${STATE_DIR}/terminalrc.bak"

# Repo tokens (website/styles.css + branding/README.md)
GH_BG="#0D1117"
GH_ELEVATED="#161B22"
GH_FG="#E6EDF3"
GH_MUTED="#8B949E"
GH_ACCENT="#00E5C7"
GH_ACCENT_SOFT="#5EEAD4"
GH_CODE_BG="#010409"

info() { printf '[desktop-skin] %s\n' "$*"; }
warn() { printf '[desktop-skin] WARN: %s\n' "$*" >&2; }
die()  { printf '[desktop-skin] ERROR: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: bash scripts/desktop-skin.sh <command> [options]

Commands
  apply       Kali-Dark + compositor off + GrokHunter wallpaper
  status      Show current xfconf skin values
  revert      Restore snapshot taken by the last apply
  self-test   Syntax + helper checks (no DISPLAY required)

Options (apply)
  --plate og|banner|minimal|PATH   Default: og
  --dpi N                          Override Xft DPI (96–192 typical)
  --panel-slim                     Thin panel(s): 32px, intelligent autohide, solid #161B22
  --panel-size N                   Height in px when using --panel-slim (default 32)
  --terminal                       Also color xfce4-terminal (backed up)
  --dry-run                        Print actions, change nothing
  -h, --help

Plates
  og       branding/og.jpg          (front wolf + tagline)
  banner   branding/x-banner.jpg    (profile wolf + lockup)
  minimal  branding/icon.png        (G tile; icon-heavy desktops)
  PATH     any existing image file

Must run in the Kali guest with DISPLAY set (nh-x11 or KeX).
Does not edit /usr. Does not print or request API keys.
EOF
}

for arg in "$@"; do
  case "${arg}" in
    --plate)
      die "--plate requires a value (use --plate=og or pass after parse)"
      ;;
    --plate=*)
      PLATE="${arg#--plate=}"
      ;;
    --dpi)
      die "--dpi requires a value (use --dpi=120)"
      ;;
    --dpi=*)
      DPI="${arg#--dpi=}"
      ;;
    --terminal) DO_TERMINAL=1 ;;
    --panel-slim) DO_PANEL_SLIM=1 ;;
    --panel-size)
      die "--panel-size requires a value (use --panel-size=32)"
      ;;
    --panel-size=*)
      PANEL_SIZE="${arg#--panel-size=}"
      ;;
    --dry-run)  DRY=1 ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      # allow: --plate og   --dpi 120
      :
      ;;
  esac
done

# Positional-style flags: --plate og --dpi 120
_prev=""
for arg in "$@"; do
  if [[ "${_prev}" == "--plate" ]]; then
    PLATE="${arg}"
  elif [[ "${_prev}" == "--dpi" ]]; then
    DPI="${arg}"
  elif [[ "${_prev}" == "--panel-size" ]]; then
    PANEL_SIZE="${arg}"
  fi
  _prev="${arg}"
done

run() {
  if [[ "${DRY}" -eq 1 ]]; then
    printf '[desktop-skin] DRY:'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

in_kali_guest() {
  if [[ -r /etc/os-release ]]; then
    grep -qiE 'kali|nethunter' /etc/os-release && return 0
  fi
  return 1
}

xfq() {
  xfconf-query "$@"
}

xfq_get() {
  local ch="$1" prop="$2"
  xfconf-query -c "${ch}" -p "${prop}" 2>/dev/null || true
}

xfq_set() {
  local ch="$1" prop="$2" val="$3"
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: xfconf-query -c ${ch} -p ${prop} -s ${val}"
    return 0
  fi
  if xfconf-query -c "${ch}" -p "${prop}" >/dev/null 2>&1; then
    xfconf-query -c "${ch}" -p "${prop}" -s "${val}"
  else
    xfconf-query -c "${ch}" -p "${prop}" -n -t string -s "${val}" 2>/dev/null \
      || xfconf-query -c "${ch}" -np "${prop}" -t string -s "${val}"
  fi
}

xfq_set_int() {
  local ch="$1" prop="$2" val="$3"
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: xfconf-query -c ${ch} -p ${prop} -t int -s ${val}"
    return 0
  fi
  if xfconf-query -c "${ch}" -p "${prop}" >/dev/null 2>&1; then
    xfconf-query -c "${ch}" -p "${prop}" -s "${val}"
  else
    xfconf-query -c "${ch}" -np "${prop}" -t int -s "${val}"
  fi
}

xfq_set_bool() {
  local ch="$1" prop="$2" val="$3"
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: xfconf-query -c ${ch} -p ${prop} -t bool -s ${val}"
    return 0
  fi
  if xfconf-query -c "${ch}" -p "${prop}" >/dev/null 2>&1; then
    xfconf-query -c "${ch}" -p "${prop}" -s "${val}"
  else
    xfconf-query -c "${ch}" -np "${prop}" -t bool -s "${val}"
  fi
}

require_session() {
  [[ -n "${DISPLAY:-}" ]] || die "DISPLAY is unset. Start nh-x11 / KeX, then retry inside Kali."
  need_cmd xfconf-query
  if ! in_kali_guest; then
    warn "os-release is not Kali — continuing anyway (proot guests vary)"
  fi
}

snapshot_take() {
  mkdir -p "${STATE_DIR}"
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: would write ${SNAP}"
    return 0
  fi
  {
    printf 'SNAP_THEME=%q\n' "$(xfq_get xsettings /Net/ThemeName)"
    printf 'SNAP_ICONS=%q\n' "$(xfq_get xsettings /Net/IconThemeName)"
    printf 'SNAP_WM=%q\n' "$(xfq_get xfwm4 /general/theme)"
    printf 'SNAP_COMP=%q\n' "$(xfq_get xfwm4 /general/use_compositing)"
    printf 'SNAP_DPI=%q\n' "$(xfq_get xsettings /Xft/DPI)"
    printf 'SNAP_WALL=%q\n' "$(xfq_get xfce4-desktop /backdrop/screen0/monitor0/workspace0/last-image)"
  } > "${SNAP}"
  # all wallpaper keys
  if xfconf-query -c xfce4-desktop -l >/dev/null 2>&1; then
    xfconf-query -c xfce4-desktop -l 2>/dev/null \
      | grep -E '/(last-image|image-path)$' \
      | while IFS= read -r p; do
          printf 'WALL:%s=%s\n' "${p}" "$(xfq_get xfce4-desktop "${p}")"
        done >> "${SNAP}.walls" || true
  fi
  snapshot_panels
  info "Snapshot ${SNAP}"
}

snapshot_exists() {
  [[ -f "${SNAP}" ]]
}

resolve_plate() {
  local want="${1}"
  local cand=""
  case "${want}" in
    og)
      cand="${ROOT}/branding/og.jpg"
      ;;
    banner)
      cand="${ROOT}/branding/x-banner.jpg"
      ;;
    minimal)
      cand="${ROOT}/branding/icon.png"
      ;;
    *)
      if [[ -f "${want}" ]]; then
        printf '%s\n' "${want}"
        return 0
      fi
      die "unknown plate or missing file: ${want}"
      ;;
  esac

  if [[ -f "${cand}" ]]; then
    printf '%s\n' "${cand}"
    return 0
  fi

  # Fallback: official raw assets (network, optional)
  local url=""
  case "${want}" in
    og)      url="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/branding/og.jpg" ;;
    banner)  url="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/branding/x-banner.jpg" ;;
    minimal) url="https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/branding/icon.png" ;;
  esac
  mkdir -p "${BG_DIR}"
  local dest="${BG_DIR}/$(basename "${cand}")"
  if [[ -f "${dest}" ]]; then
    printf '%s\n' "${dest}"
    return 0
  fi
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: would fetch ${url} -> ${dest}"
    printf '%s\n' "${dest}"
    return 0
  fi
  if command -v curl >/dev/null 2>&1 && [[ -n "${url}" ]]; then
    info "Fetching plate ${want} from GitHub branding/"
    curl -fsSL "${url}" -o "${dest}" || die "fetch failed: ${url}"
    printf '%s\n' "${dest}"
    return 0
  fi
  die "plate file missing: ${cand} (clone repo branding/ or pass --plate=/path/to.png)"
}

install_wallpaper_file() {
  local src="$1"
  mkdir -p "${BG_DIR}"
  local dest="${BG_DIR}/$(basename "${src}")"
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: cp ${src} ${dest}"
    printf '%s\n' "${dest}"
    return 0
  fi
  if [[ "${src}" != "${dest}" ]]; then
    cp -f "${src}" "${dest}"
    chmod 644 "${dest}"
  fi
  printf '%s\n' "${dest}"
}

panel_ids() {
  xfconf-query -c xfce4-panel -l 2>/dev/null \
    | sed -n 's|^/panels/panel-\([0-9][0-9]*\)/.*|\1|p' \
    | sort -n -u
}

snapshot_panels() {
  local id p val
  if ! command -v xfconf-query >/dev/null 2>&1; then
    return 0
  fi
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: would snapshot xfce4-panel"
    return 0
  fi
  : > "${SNAP}.panels"
  if ! xfconf-query -c xfce4-panel -l >/dev/null 2>&1; then
    return 0
  fi
  while IFS= read -r id; do
    [[ -n "${id}" ]] || continue
    for p in size icon-size autohide-behavior background-style dark-mode leave-opacity enter-opacity; do
      val="$(xfq_get xfce4-panel "/panels/panel-${id}/${p}")"
      printf 'PANEL:%s:%s=%s\n' "${id}" "${p}" "${val}" >> "${SNAP}.panels"
    done
    val="$(xfconf-query -c xfce4-panel -p "/panels/panel-${id}/background-rgba" 2>/dev/null | tr '\n' ' ' | awk '{$1=$1;print}' || true)"
    printf 'PANEL:%s:background-rgba=%s\n' "${id}" "${val}" >> "${SNAP}.panels"
  done < <(panel_ids)
}

xfq_set_rgba() {
  local ch="$1" prop="$2"
  shift 2
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: xfconf-query -c ${ch} -p ${prop} rgba $*"
    return 0
  fi
  xfconf-query -c "${ch}" -p "${prop}" \
    -t double -s "$1" -t double -s "$2" -t double -s "$3" -t double -s "$4" \
    2>/dev/null \
    || xfconf-query -c "${ch}" -np "${prop}" \
         -t double -s "$1" -t double -s "$2" -t double -s "$3" -t double -s "$4"
}

apply_panel_slim() {
  local id count=0
  mapfile -t _pids < <(panel_ids)
  count="${#_pids[@]}"
  if [[ "${count}" -eq 0 ]]; then
    warn "no xfce4-panel ids — skip --panel-slim"
    return 0
  fi
  if [[ "${count}" -gt 1 ]]; then
    warn "${count} panels found — slimming each (not deleting). Keep one panel in Panel Preferences if you want a single bar."
  fi
  # #161B22
  local r="0.0862745098" g="0.1058823529" b="0.1333333333" a="1.0"
  for id in "${_pids[@]}"; do
    [[ -n "${id}" ]] || continue
    info "Panel ${id}: size=${PANEL_SIZE} autohide=intelligently bg=${GH_ELEVATED}"
    xfq_set_int xfce4-panel "/panels/panel-${id}/size" "${PANEL_SIZE}"
    xfq_set_int xfce4-panel "/panels/panel-${id}/icon-size" 0
    xfq_set_int xfce4-panel "/panels/panel-${id}/autohide-behavior" 1
    xfq_set_int xfce4-panel "/panels/panel-${id}/background-style" 1
    xfq_set_rgba xfce4-panel "/panels/panel-${id}/background-rgba" "${r}" "${g}" "${b}" "${a}"
    xfq_set_int xfce4-panel "/panels/panel-${id}/leave-opacity" 100
    xfq_set_int xfce4-panel "/panels/panel-${id}/enter-opacity" 100
    xfq_set_bool xfce4-panel "/panels/panel-${id}/dark-mode" true 2>/dev/null || true
  done
  if [[ "${DRY}" -eq 0 ]] && command -v xfce4-panel >/dev/null 2>&1; then
    xfce4-panel -r 2>/dev/null || true
  fi
}

revert_panels() {
  local line id key val
  [[ -f "${SNAP}.panels" ]] || return 0
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: restore panel snapshot"
    return 0
  fi
  while IFS= read -r line; do
    [[ "${line}" == PANEL:* ]] || continue
    rest="${line#PANEL:}"
    id="${rest%%:*}"
    rest="${rest#*:}"
    key="${rest%%=*}"
    val="${rest#*=}"
    [[ -n "${id}" && -n "${key}" ]] || continue
    [[ -n "${val}" ]] || continue
    case "${key}" in
      background-rgba)
        # snapshot stores four floats on one line
        set -- ${val}
        if [[ "$#" -eq 4 ]]; then
          xfq_set_rgba xfce4-panel "/panels/panel-${id}/background-rgba" "$1" "$2" "$3" "$4"
        else
          warn "skip rgba restore for panel ${id} (need 4 floats, got: ${val})"
        fi
        continue
        ;;
      dark-mode)
        xfq_set_bool xfce4-panel "/panels/panel-${id}/${key}" "${val}"
        continue
        ;;
      size|icon-size|autohide-behavior|background-style|leave-opacity|enter-opacity)
        xfq_set_int xfce4-panel "/panels/panel-${id}/${key}" "${val}"
        continue
        ;;
    esac
  done < "${SNAP}.panels"
  if command -v xfce4-panel >/dev/null 2>&1; then
    xfce4-panel -r 2>/dev/null || true
  fi
}

set_all_wallpapers() {
  local img="$1"
  local props p base
  if ! xfconf-query -c xfce4-desktop -l >/dev/null 2>&1; then
    warn "xfce4-desktop channel missing — is XFCE running?"
    xfq_set xfce4-desktop /backdrop/screen0/monitor0/workspace0/last-image "${img}"
    return 0
  fi
  mapfile -t props < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/(last-image|image-path)$' || true)
  if [[ "${#props[@]}" -eq 0 ]]; then
    xfq_set xfce4-desktop /backdrop/screen0/monitor0/workspace0/last-image "${img}"
    xfq_set_int xfce4-desktop /backdrop/screen0/monitor0/workspace0/image-style 5
    return 0
  fi
  for p in "${props[@]}"; do
    xfq_set xfce4-desktop "${p}" "${img}"
    base="${p%/last-image}"
    base="${base%/image-path}"
    if xfconf-query -c xfce4-desktop -p "${base}/image-style" >/dev/null 2>&1; then
      xfq_set_int xfce4-desktop "${base}/image-style" 5
    fi
  done
  info "Wallpaper keys updated: ${#props[@]}"
}

apply_terminal() {
  mkdir -p "$(dirname "${TERM_RC}")" "${STATE_DIR}"
  if [[ -f "${TERM_RC}" && ! -f "${TERM_BAK}" && "${DRY}" -eq 0 ]]; then
    cp -f "${TERM_RC}" "${TERM_BAK}"
    info "Backed up ${TERM_RC}"
  fi
  if [[ "${DRY}" -eq 1 ]]; then
    info "DRY: write xfce4-terminal colors ${GH_CODE_BG} / ${GH_FG} / ${GH_ACCENT}"
    return 0
  fi
  touch "${TERM_RC}"
  # ColorMode=TRUE enables palette; BackgroundMode=TERMINAL_BACKGROUND_SOLID
  _term_set() {
    local key="$1" val="$2"
    if grep -q "^${key}=" "${TERM_RC}" 2>/dev/null; then
      sed -i "s|^${key}=.*|${key}=${val}|" "${TERM_RC}"
    else
      printf '%s=%s\n' "${key}" "${val}" >> "${TERM_RC}"
    fi
  }
  grep -q '^\[Configuration\]' "${TERM_RC}" 2>/dev/null || printf '[Configuration]\n' | cat - "${TERM_RC}" > "${TERM_RC}.tmp" && mv "${TERM_RC}.tmp" "${TERM_RC}"
  _term_set ColorForeground "${GH_FG}"
  _term_set ColorBackground "${GH_CODE_BG}"
  _term_set ColorCursor "${GH_ACCENT}"
  _term_set ColorBold "${GH_ACCENT}"
  info "Terminal colors written (revert restores backup if present)"
}

cmd_apply() {
  require_session
  if [[ -n "${DPI}" ]]; then
    [[ "${DPI}" =~ ^[0-9]+$ ]] || die "--dpi must be an integer"
    [[ "${DPI}" -ge 72 && "${DPI}" -le 240 ]] || die "--dpi out of range (72-240)"
  fi
  if [[ "${DO_PANEL_SLIM}" -eq 1 ]]; then
    [[ "${PANEL_SIZE}" =~ ^[0-9]+$ ]] || die "--panel-size must be an integer"
    [[ "${PANEL_SIZE}" -ge 20 && "${PANEL_SIZE}" -le 64 ]] || die "--panel-size out of range (20-64)"
  fi

  snapshot_take

  local src dest
  src="$(resolve_plate "${PLATE}")"
  dest="$(install_wallpaper_file "${src}")"

  info "Theme Kali-Dark / Flat-Remix-Blue-Dark"
  xfq_set xsettings /Net/ThemeName Kali-Dark
  xfq_set xsettings /Net/IconThemeName Flat-Remix-Blue-Dark
  xfq_set xfwm4 /general/theme Kali-Dark

  info "Compositor off"
  xfq_set_bool xfwm4 /general/use_compositing false

  info "Wallpaper ${dest}"
  set_all_wallpapers "${dest}"

  if [[ -n "${DPI}" ]]; then
    info "DPI ${DPI}"
    # Xft/DPI is 1024ths of an inch in some stacks; XFCE Appearance custom DPI
    # is stored as integer points. Set both custom flag and value when possible.
    xfq_set_int xsettings /Xft/DPI "${DPI}"
  fi

  if [[ "${DO_PANEL_SLIM}" -eq 1 ]]; then
    apply_panel_slim
  fi

  if [[ "${DO_TERMINAL}" -eq 1 ]]; then
    apply_terminal
  fi

  info "Apply done. Log out/in of XFCE only if GTK did not refresh."
  info "Revert: bash scripts/desktop-skin.sh revert"
}

cmd_status() {
  require_session
  info "DISPLAY=${DISPLAY}"
  info "theme     $(xfq_get xsettings /Net/ThemeName)"
  info "icons     $(xfq_get xsettings /Net/IconThemeName)"
  info "wm        $(xfq_get xfwm4 /general/theme)"
  info "composit  $(xfq_get xfwm4 /general/use_compositing)"
  info "dpi       $(xfq_get xsettings /Xft/DPI)"
  local walls
  walls="$(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/last-image$' || true)"
  if [[ -z "${walls}" ]]; then
    info "wallpaper  (no last-image keys)"
  else
    while IFS= read -r p; do
      info "wallpaper  ${p}=$(xfq_get xfce4-desktop "${p}")"
    done <<< "${walls}"
  fi
  if snapshot_exists; then
    info "snapshot   ${SNAP}"
  else
    info "snapshot   none"
  fi
  if command -v xfconf-query >/dev/null 2>&1; then
    local id
    while IFS= read -r id; do
      [[ -n "${id}" ]] || continue
      info "panel-${id}  size=$(xfq_get xfce4-panel "/panels/panel-${id}/size") hide=$(xfq_get xfce4-panel "/panels/panel-${id}/autohide-behavior") bgstyle=$(xfq_get xfce4-panel "/panels/panel-${id}/background-style")"
    done < <(panel_ids)
  fi
}

cmd_revert() {
  require_session
  snapshot_exists || die "no snapshot at ${SNAP} — apply first"
  # shellcheck disable=SC1090
  if [[ "${DRY}" -eq 0 ]]; then
    # snapshot.env uses %q so it is safe to source
    # shellcheck source=/dev/null
    source "${SNAP}"
  else
    info "DRY: would source ${SNAP}"
    SNAP_THEME="Kali-Dark"
    SNAP_ICONS="Flat-Remix-Blue-Dark"
    SNAP_WM="Kali-Dark"
    SNAP_COMP="false"
    SNAP_DPI=""
  fi

  [[ -n "${SNAP_THEME:-}" ]] && xfq_set xsettings /Net/ThemeName "${SNAP_THEME}"
  [[ -n "${SNAP_ICONS:-}" ]] && xfq_set xsettings /Net/IconThemeName "${SNAP_ICONS}"
  [[ -n "${SNAP_WM:-}" ]] && xfq_set xfwm4 /general/theme "${SNAP_WM}"
  if [[ -n "${SNAP_COMP:-}" ]]; then
    xfq_set_bool xfwm4 /general/use_compositing "${SNAP_COMP}"
  fi
  if [[ -n "${SNAP_DPI:-}" ]]; then
    xfq_set_int xsettings /Xft/DPI "${SNAP_DPI}"
  fi

  if [[ -f "${SNAP}.walls" && "${DRY}" -eq 0 ]]; then
    while IFS= read -r line; do
      [[ "${line}" == WALL:* ]] || continue
      local rest="${line#WALL:}"
      local p="${rest%%=*}"
      local v="${rest#*=}"
      [[ -n "${p}" ]] && xfq_set xfce4-desktop "${p}" "${v}"
    done < "${SNAP}.walls"
  fi

  revert_panels

  if [[ -f "${TERM_BAK}" ]]; then
    if [[ "${DRY}" -eq 1 ]]; then
      info "DRY: restore ${TERM_RC} from backup"
    else
      cp -f "${TERM_BAK}" "${TERM_RC}"
      info "Restored terminalrc"
    fi
  fi
  info "Revert done"
}

cmd_self_test() {
  need_cmd bash
  bash -n "${BASH_SOURCE[0]}"
  info "bash -n OK"
  [[ -n "${GH_ACCENT}" && "${GH_ACCENT_SOFT}" == "#5EEAD4" && "${GH_BG}" == "#0D1117" ]] || die "token mismatch"
  info "tokens OK"
  [[ "${PANEL_SIZE}" == "32" ]] || die "default panel size drift"
  case "og" in og|banner|minimal) ;; *) die "plate case broken" ;; esac
  info "self-test OK"
}

case "${CMD}" in
  apply)     cmd_apply ;;
  status)    cmd_status ;;
  revert)    cmd_revert ;;
  self-test) cmd_self_test ;;
  -h|--help|help|"")
    usage
    [[ -n "${CMD}" ]] || exit 1
    exit 0
    ;;
  *)
    die "unknown command: ${CMD} (try --help)"
    ;;
esac

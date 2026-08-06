#!/usr/bin/env bash
# Install / refresh full Grok V9 + Auto specialist picker surface into ~/.grok/config.toml
#
# Usage:
#   bash scripts/install_v9_grok_models.sh
#   bash scripts/install_v9_grok_models.sh --force
#   GROK_CONFIG=/path/to/config.toml bash scripts/install_v9_grok_models.sh
#
# Part of GrokHunter Rootless.
#
set -euo pipefail

die()  { echo "[install_v9_grok_models] ERROR: $*" >&2; exit 1; }
warn() { echo "[install_v9_grok_models] WARN: $*" >&2; }
info() { echo "[install_v9_grok_models] $*"; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)" || die "cannot resolve repo root"
SRC="$ROOT/config/grok-build-v9-models.example.toml"
CFG="${GROK_CONFIG:-${HOME:?HOME not set}/.grok/config.toml}"
MARKER_BEGIN="# --- Grok Imagine Cinematic Studio: v9-4p5 specialist models"
FORCE=0
BACKUP=""
TMP_OUT=""

cleanup() {
  [[ -n "${TMP_OUT:-}" && -f "${TMP_OUT}" ]] && rm -f "${TMP_OUT}" "${TMP_OUT}.new" 2>/dev/null || true
}
trap cleanup EXIT

OWNED_MODELS=(
  grok-v9-4p5-chat-expert grok-v9 grok-v9-4p5 v9 v9-4p5
  chat-expert v9-4p5-chat-expert 4p5-expert grok-4.5-expert
  grok-v9-4p5-multi multi v9-4p5-multi 4p5-multi grok-4.5-multi
  grok-4-auto auto 4-auto grok-auto
)

for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    --help|-h) sed -n '2,12p' "$0" || true; exit 0 ;;
    *) die "Unknown option: $arg (try --help)" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || die "python3 is required (Termux: pkg install python)"
command -v sed >/dev/null 2>&1 || die "sed is required"
command -v grep >/dev/null 2>&1 || die "grep is required"
command -v mktemp >/dev/null 2>&1 || die "mktemp is required"

[[ -f "$SRC" ]] || die "Missing template: $SRC — run from a GrokHunter clone"
[[ -s "$SRC" ]] || die "Template is empty: $SRC"
grep -q '^\[model\.' "$SRC" || die "Template has no [model.*] sections: $SRC"

CFG_DIR="$(dirname "$CFG")"
mkdir -p "$CFG_DIR" || die "cannot create config dir: $CFG_DIR"
[[ -w "$CFG_DIR" ]] || die "config dir not writable: $CFG_DIR"

if [[ -e "$CFG" ]]; then
  [[ -f "$CFG" ]] || die "GROK_CONFIG is not a regular file: $CFG"
  [[ -r "$CFG" && -w "$CFG" ]] || die "config not readable/writable: $CFG"
else
  touch "$CFG" || die "cannot create $CFG"
fi

_v9_model_blocks() {
  local out
  out="$(sed -n '/^\[model\./,$p' "$SRC")" || die "failed to extract [model.*] from $SRC"
  [[ -n "$out" ]] || die "extracted model blocks are empty"
  printf '%s\n' "$out"
}

_needs_upgrade() {
  if ! python3 - "$CFG" "${OWNED_MODELS[@]}" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
owned = sys.argv[2:]
try:
    text = path.read_text(encoding="utf-8")
except OSError:
    print("missing")
    raise SystemExit(0)

for name in owned:
    m = re.search(
        rf"(?ms)^\[model\.(?:\"{re.escape(name)}\"|{re.escape(name)})\]\n(.*?)(?=^\[|\Z)",
        text,
    )
    if not m:
        print("missing")
        raise SystemExit(0)
    body = m.group(1)
    if "temperature" not in body or "not on this team" in body:
        print("stub")
        raise SystemExit(0)
print("ok")
PY
  then
    warn "upgrade check failed — treating as needs install"
    echo "missing"
  fi
}

_backup_cfg() {
  BACKUP="${CFG}.bak.$(date +%Y%m%d%H%M%S 2>/dev/null || echo unknown)"
  cp -a "$CFG" "$BACKUP" || die "failed to backup $CFG"
  info "Backup: $BACKUP"
}

_verify_install() {
  local st
  st="$(_needs_upgrade)"
  if [[ "$st" != "ok" ]]; then
    die "post-install verification failed (status=${st}). Restore: cp -a ${BACKUP:-<backup>} $CFG"
  fi
}

status="$(_needs_upgrade)"
if [[ "$status" == "ok" && "$FORCE" -eq 0 ]]; then
  info "Grok V9 specialist models already complete in $CFG (use --force to refresh)"
else
  _backup_cfg
  blocks="$(_v9_model_blocks)"
  TMP_OUT="$(mktemp "${CFG_DIR}/.grok-v9.XXXXXX")" || die "mktemp failed in $CFG_DIR"
  if ! python3 - "$CFG" "$TMP_OUT" "$MARKER_BEGIN" "${OWNED_MODELS[@]}" <<'PY'
from pathlib import Path
import re
import sys

cfg_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
marker = sys.argv[3]
owned = sys.argv[4:]
try:
    text = cfg_path.read_text(encoding="utf-8")
except OSError as e:
    print(f"read failed: {e}", file=sys.stderr)
    sys.exit(1)

idx = text.find(marker)
if idx != -1:
    text = text[:idx].rstrip() + "\n"
for name in owned:
    pat = re.compile(
        rf"(?ms)^\[model\.(?:\"{re.escape(name)}\"|{re.escape(name)})\]\n.*?(?=^\[|\Z)"
    )
    text = pat.sub("", text)
out_path.write_text(text.rstrip() + "\n", encoding="utf-8")
PY
  then
    die "failed preparing stripped config in temp"
  fi
  {
    cat "$TMP_OUT" || die "cannot read temp base"
    echo ""
    echo "${MARKER_BEGIN} (Model Layer v4.5 · full alias surface) ---"
    echo "# Session-auth via cli-chat-proxy (SuperGrok). Base model: grok-4.5."
    echo "# Native API IDs grok-v9-4p5-* / grok-4-auto are not public product slugs."
    echo "# Family shorts + chat-expert / multi / auto aliases all registered as pickers."
    echo "# GrokHunter: coding lab default remains grok-4.5 ([models] default)."
    printf '%s\n' "$blocks"
  } > "${TMP_OUT}.new" || die "failed writing merged temp"
  grep -q "$MARKER_BEGIN" "${TMP_OUT}.new" || die "temp config missing marker"
  grep -q '^\[model\.' "${TMP_OUT}.new" || die "temp config missing [model.*]"
  mv -f "${TMP_OUT}.new" "$CFG" || die "failed to install new config at $CFG"
  rm -f "$TMP_OUT"
  TMP_OUT=""
  chmod 600 "$CFG" 2>/dev/null || warn "could not chmod 600 $CFG"
  _verify_install
  info "Installed full Grok V9 [model.*] picker surface → $CFG"
fi

echo ""
echo "Verify with:  grok models"
echo "Switch with:  /model grok-v9 · /model chat-expert · /model multi · /model auto"
echo "Default coding model remains grok-4.5. Imagine uses grok-imagine-* separately."

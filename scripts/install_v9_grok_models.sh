#!/usr/bin/env bash
# Remove legacy GrokHunter V9 /model pickers from ~/.grok/config.toml
#
# Filename kept for back-compat. install / force / clean all mean: strip pickers.
# Default catalog model remains grok-4.6 (via NetHunter profile / ensure).
#
# Usage:
#   bash scripts/install_v9_grok_models.sh
#   bash scripts/install_v9_grok_models.sh --force
#   bash scripts/install_v9_grok_models.sh --clean
#   GROK_CONFIG=/path/to/config.toml bash scripts/install_v9_grok_models.sh
#
# Part of GrokHunter Rootless.
#
set -euo pipefail

die()  { echo "[install_v9_grok_models] ERROR: $*" >&2; exit 1; }
warn() { echo "[install_v9_grok_models] WARN: $*" >&2; }
info() { echo "[install_v9_grok_models] $*"; }

CFG="${GROK_CONFIG:-${HOME:?HOME not set}/.grok/config.toml}"
MARKER_BEGIN="# --- GrokHunter: v9 specialist models"
MARKER_BEGIN_LEGACY="# --- Grok Imagine Cinematic Studio: v9-4p5 specialist models"
BACKUP=""
TMP_OUT=""

cleanup_tmp() {
  [[ -n "${TMP_OUT:-}" && -f "${TMP_OUT}" ]] && rm -f "${TMP_OUT}" 2>/dev/null || true
}
trap cleanup_tmp EXIT

OWNED_MODELS=(
  grok-v9-4p6-chat-expert grok-v9 grok-v9-4p6 v9 v9-4p6
  chat-expert v9-4p6-chat-expert 4p6-expert grok-4.6-expert
  grok-v9-4p6-multi multi v9-4p6-multi 4p6-multi grok-4.6-multi
  grok-4-auto auto 4-auto grok-auto
  grok-v9-4p5-chat-expert grok-v9-4p5 v9-4p5
  v9-4p5-chat-expert 4p5-expert grok-4.5-expert
  grok-v9-4p5-multi v9-4p5-multi 4p5-multi grok-4.5-multi
)

for arg in "$@"; do
  case "$arg" in
    --force|-f|--clean|-c) ;; # cleanup is the only behavior
    --help|-h)
      cat <<'EOF'
Remove legacy V9 /model pickers from ~/.grok/config.toml.

  bash scripts/install_v9_grok_models.sh
  bash scripts/install_v9_grok_models.sh --force   # alias (same cleanup)
  bash scripts/install_v9_grok_models.sh --clean   # alias (same cleanup)

V9 pickers are retired. Default catalog model remains grok-4.6.
Use: grokhunter ensure / bash scripts/install_grok_profile.sh
EOF
      exit 0
      ;;
    *) die "Unknown option: $arg (try --help)" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || die "python3 is required (Termux: pkg install python)"

CFG_DIR="$(dirname "$CFG")"
mkdir -p "$CFG_DIR" || die "cannot create config dir: $CFG_DIR"
[[ -w "$CFG_DIR" ]] || die "config dir not writable: $CFG_DIR"

if [[ ! -e "$CFG" ]]; then
  info "No config at $CFG — nothing to remove"
  info "V9 /model pickers are retired. Default remains grok-4.6."
  exit 0
fi
[[ -f "$CFG" ]] || die "GROK_CONFIG is not a regular file: $CFG"
[[ -r "$CFG" && -w "$CFG" ]] || die "config not readable/writable: $CFG"

_has_legacy() {
  python3 - "$CFG" "$MARKER_BEGIN" "$MARKER_BEGIN_LEGACY" "${OWNED_MODELS[@]}" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
marker, legacy = sys.argv[2], sys.argv[3]
owned = sys.argv[4:]
try:
    text = path.read_text(encoding="utf-8")
except OSError:
    print("no")
    raise SystemExit(0)
if marker in text or legacy in text:
    print("yes")
    raise SystemExit(0)
for name in owned:
    if re.search(
        rf'(?m)^\[model\.(?:"{re.escape(name)}"|{re.escape(name)})\]\s*$',
        text,
    ):
        print("yes")
        raise SystemExit(0)
print("no")
PY
}

if [[ "$(_has_legacy)" != "yes" ]]; then
  info "No legacy V9 /model pickers in $CFG — nothing to remove"
  info "V9 pickers are retired. Default catalog model remains grok-4.6."
  exit 0
fi

BACKUP="${CFG}.bak.$(date +%Y%m%d%H%M%S 2>/dev/null || echo unknown)"
cp -a "$CFG" "$BACKUP" || die "failed to backup $CFG"
info "Backup: $BACKUP"

TMP_OUT="$(mktemp "${CFG_DIR}/.grok-v9-clean.XXXXXX")" || die "mktemp failed in $CFG_DIR"
if ! python3 - "$CFG" "$TMP_OUT" "$MARKER_BEGIN" "$MARKER_BEGIN_LEGACY" "${OWNED_MODELS[@]}" <<'PY'
from pathlib import Path
import re
import sys

cfg_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
markers = (sys.argv[3], sys.argv[4])
owned = sys.argv[5:]

try:
    text = cfg_path.read_text(encoding="utf-8")
except OSError as e:
    print(f"read failed: {e}", file=sys.stderr)
    sys.exit(1)

def strip_marker_block(src: str, m: str) -> str:
    """Strip from marker through following [model.*] tables until a non-model section or EOF."""
    idx = src.find(m)
    if idx == -1:
        return src
    # Expand start backward over blank lines immediately before the marker
    start = idx
    while start > 0 and src[start - 1] in "\n\r":
        prev_nl = src.rfind("\n", 0, start - 1)
        line_start = 0 if prev_nl < 0 else prev_nl + 1
        if src[line_start:start].strip() == "":
            start = line_start
        else:
            break

    # Walk sections after the marker; consume [model.*], stop at other [section]
    rest = src[idx:]
    end = len(src)  # default: to EOF
    # Skip past the marker line itself
    first_nl = rest.find("\n")
    scan_from = 0 if first_nl < 0 else first_nl + 1
    for match in re.finditer(r"(?m)^\[([^\]]+)\]\s*$", rest[scan_from:]):
        header = match.group(1)
        abs_start = idx + scan_from + match.start()
        if header.startswith("model."):
            continue
        # Non-model section ends the picker block (keep this section)
        end = abs_start
        break
    return src[:start].rstrip() + "\n" + src[end:]

for m in markers:
    text = strip_marker_block(text, m)

for name in owned:
    pat = re.compile(
        rf'(?ms)^\[model\.(?:"{re.escape(name)}"|{re.escape(name)})\]\n.*?(?=^\[|\Z)'
    )
    text = pat.sub("", text)

text = re.sub(r"\n{3,}", "\n\n", text).rstrip() + "\n"
out_path.write_text(text, encoding="utf-8")
PY
then
  die "failed stripping V9 pickers"
fi

mv -f "$TMP_OUT" "$CFG" || die "failed to write cleaned config at $CFG"
TMP_OUT=""
chmod 600 "$CFG" 2>/dev/null || warn "could not chmod 600 $CFG"

info "Removed legacy V9 /model pickers from $CFG"
echo ""
echo "V9 /model pickers are retired. Default catalog model remains grok-4.6."
echo "Profile:  bash scripts/install_grok_profile.sh   # or: grokhunter ensure"
echo "Status:   grokhunter models status"

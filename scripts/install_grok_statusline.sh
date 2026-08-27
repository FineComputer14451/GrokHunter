#!/usr/bin/env bash
# Install GrokHunter lab status line for the Grok Build TUI.
#
# - Copies scripts/grok-statusline.py → ~/.grok/statusline.sh (mode 755)
# - Patches ONLY [ui.status_line] when missing, builtin/disabled, or already
#   this script. Never overwrites a foreign command or other [ui] keys (theme).
#
# Usage:
#   bash scripts/install_grok_statusline.sh
#   GROK_CONFIG=/path/to/config.toml HOME=/tmp/x bash scripts/install_grok_statusline.sh
set -euo pipefail

info() { echo "[install_grok_statusline] $*" >&2; }
warn() { echo "[install_grok_statusline] WARN: $*" >&2; }
die()  { echo "[install_grok_statusline] ERROR: $*" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)" || die "cannot resolve repo root"
SRC="${GROKHUNTER_STATUSLINE_SRC:-$ROOT/scripts/grok-statusline.py}"
DEST="${GROKHUNTER_STATUSLINE_DEST:-${HOME:?HOME not set}/.grok/statusline.sh}"
CFG="${GROK_CONFIG:-${HOME}/.grok/config.toml}"
OURS="~/.grok/statusline.sh"

command -v python3 >/dev/null 2>&1 || die "python3 is required"
[[ -f "$SRC" ]] || die "Missing statusline source: $SRC"

mkdir -p "$(dirname "$DEST")" || die "cannot create $(dirname "$DEST")"
cp -f "$SRC" "$DEST" || die "cannot copy statusline to $DEST"
chmod 755 "$DEST" 2>/dev/null || true
info "installed ${DEST}"

mkdir -p "$(dirname "$CFG")" || die "cannot create $(dirname "$CFG")"
if [[ ! -f "$CFG" ]]; then
  touch "$CFG" || die "cannot create $CFG"
fi

python3 - "$CFG" "$OURS" <<'PY'
from pathlib import Path
import os
import re
import sys

cfg_path = Path(sys.argv[1])
ours = sys.argv[2]
text = cfg_path.read_text(encoding="utf-8") if cfg_path.exists() else ""

def section_span(body: str, name: str):
    m = re.search(rf"^\[{re.escape(name)}\]\s*$", body, re.M)
    if not m:
        return None
    rest = body[m.end() :]
    nxt = re.search(r"^\[", rest, re.M)
    end = m.end() + (nxt.start() if nxt else len(rest))
    return m.start(), end, body[m.end() : end]

def parse_keys(body: str) -> dict:
    keys = {}
    for line in body.splitlines():
        s = line.strip()
        if not s or s.startswith("#") or s.startswith("[") or "=" not in s:
            continue
        key, _, val = s.partition("=")
        keys[key.strip()] = val.strip().strip('"').strip("'")
    return keys

def should_patch(keys: dict) -> bool:
    t = (keys.get("type") or "").lower()
    if t in ("", "builtin", "disabled", "off", "none", "hidden"):
        return True
    if t != "command":
        return True
    cmd = keys.get("command") or ""
    expanded = os.path.expanduser(ours)
    return cmd in (ours, expanded)

span = section_span(text, "ui.status_line")
keys = parse_keys(span[2]) if span else {}
if span and not should_patch(keys):
    print("skip: foreign [ui.status_line] command")
    sys.exit(0)

block = f'[ui.status_line]\ntype = "command"\ncommand = "{ours}"\n'
if span:
    start, end, _ = span
    new_text = text[:start].rstrip() + "\n\n" + block
    tail = text[end:].lstrip("\n")
    if tail:
        new_text = new_text.rstrip() + "\n\n" + tail
    if not new_text.endswith("\n"):
        new_text += "\n"
else:
    new_text = text.rstrip() + ("\n\n" if text.strip() else "") + block
    if not new_text.endswith("\n"):
        new_text += "\n"

if new_text != text:
    bak = cfg_path.with_suffix(cfg_path.suffix + ".bak.statusline")
    try:
        bak.write_text(text, encoding="utf-8")
    except OSError:
        pass
    cfg_path.write_text(new_text, encoding="utf-8")
    try:
        cfg_path.chmod(0o600)
    except OSError:
        pass
    print(f"patched {cfg_path}")
else:
    print(f"unchanged {cfg_path}")
PY

info "Done. Restart grok so the TUI picks up [ui.status_line]."

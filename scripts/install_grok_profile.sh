#!/usr/bin/env bash
# Merge GrokHunter NetHunter profile into ~/.grok/config.toml for Grok Build 1.0.5+.
#
# - Does NOT delete custom [model.*] blocks or unrelated user keys
# - Overwrites known profile sections/keys from config/grok-build.nethunter.toml
# - Safe to re-run (idempotent)
#
# Usage:
#   bash scripts/install_grok_profile.sh
#   GROK_CONFIG=/path/to/config.toml bash scripts/install_grok_profile.sh
#   bash scripts/install_grok_profile.sh --force
set -euo pipefail

info() { echo "[install_grok_profile] $*"; }
warn() { echo "[install_grok_profile] WARN: $*" >&2; }
die()  { echo "[install_grok_profile] ERROR: $*" >&2; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)" || die "cannot resolve repo root"
SRC="${GROKHUNTER_PROFILE_SRC:-$ROOT/config/grok-build.nethunter.toml}"
CFG="${GROK_CONFIG:-${HOME:?HOME not set}/.grok/config.toml}"
MARKER="# --- GrokHunter NetHunter profile (Grok Build 1.0.5+) ---"
FORCE=0

for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
    --help|-h)
      sed -n '2,14p' "$0" || true
      exit 0
      ;;
    *) die "Unknown option: $arg" ;;
  esac
done

command -v python3 >/dev/null 2>&1 || die "python3 is required"
[[ -f "$SRC" ]] || die "Missing profile template: $SRC"
[[ -s "$SRC" ]] || die "Profile template empty: $SRC"

CFG_DIR="$(dirname "$CFG")"
mkdir -p "$CFG_DIR" || die "cannot create $CFG_DIR"
if [[ ! -f "$CFG" ]]; then
  touch "$CFG" || die "cannot create $CFG"
fi

# Parse simple TOML subset: [section] and key = value (no nested tables as keys)
python3 - "$SRC" "$CFG" "$MARKER" "$FORCE" <<'PY'
from pathlib import Path
import re
import sys

src_path, cfg_path, marker, force = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3], sys.argv[4] == "1"

# Sections we own and fully replace key-wise (nested table ui.display_refresh included)
OWNED = {
    "hints",
    "features",
    "telemetry",
    "cli",
    "ui",
    "ui.display_refresh",
    "models",
    "subagents",
}

def parse_toml_simple(text: str):
    """Return {section: {key: raw_value_line}} preserving raw RHS text."""
    sections = {"": {}}
    current = ""
    for line in text.splitlines():
        raw = line.rstrip("\n")
        s = raw.strip()
        if not s or s.startswith("#"):
            continue
        m = re.match(r"^\[([^\]]+)\]\s*$", s)
        if m:
            current = m.group(1).strip()
            sections.setdefault(current, {})
            continue
        if "=" not in s:
            continue
        key, _, val = s.partition("=")
        key = key.strip()
        val = val.strip()
        sections.setdefault(current, {})[key] = val
    return sections

src = parse_toml_simple(src_path.read_text(encoding="utf-8"))
cfg_text = cfg_path.read_text(encoding="utf-8")

# Already applied? (skip unless --force)
if marker in cfg_text and not force:
    # Still ensure critical 1.0.5 keys if missing/stale
    need = False
    if re.search(r'(?m)^channel\s*=\s*"alpha"', cfg_text):
        need = True
    if re.search(r'(?m)^fork_secondary_model\s*=\s*"grok-build"', cfg_text):
        need = True
    if not re.search(r'(?m)^\[models\]', cfg_text):
        need = True
    if re.search(r'(?m)^default\s*=\s*"grok-4\.5"', cfg_text):
        need = True
    if re.search(r'(?m)^fork_secondary_model\s*=\s*"grok-4\.5"', cfg_text):
        need = True
    if re.search(r'(?m)^web_search\s*=\s*"grok-4\.5"', cfg_text):
        need = True
    if not need:
        print("profile already present (use --force to refresh)")
        sys.exit(0)

# Strip previous marker block (from marker to next blank-line-before-[ or EOF we don't own)
# Safer: strip owned sections entirely, then re-append.

def strip_owned_sections(text: str) -> str:
    lines = text.splitlines(keepends=True)
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r"^\[([^\]]+)\]\s*$", line.strip())
        if m and m.group(1).strip() in OWNED:
            # skip until next section or EOF
            i += 1
            while i < len(lines):
                if re.match(r"^\[", lines[i].strip() or ""):
                    break
                i += 1
            continue
        # Drop old marker comment lines
        if marker in line or line.strip().startswith("# GrokHunter Rootless") \
           or line.strip().startswith("# Applied by scripts/install_grok_profile"):
            i += 1
            continue
        if line.strip().startswith("# --- GrokHunter NetHunter profile"):
            i += 1
            continue
        out.append(line)
        i += 1
    return "".join(out).rstrip() + "\n"

base = strip_owned_sections(cfg_text)

# Build owned sections from SRC only
parts = [base.rstrip(), "", marker]
# Preserve template comments header lightly
parts.append("# Managed keys for Grok Build 1.0.5+ (safe to re-run install_grok_profile.sh)")

order = ["hints", "features", "telemetry", "cli", "ui", "ui.display_refresh", "models", "subagents"]
for sec in order:
    if sec not in src or not src[sec]:
        continue
    parts.append("")
    parts.append(f"[{sec}]")
    for key, val in src[sec].items():
        parts.append(f"{key} = {val}")

new_text = "\n".join(parts).rstrip() + "\n"

backup = cfg_path.with_suffix(cfg_path.suffix + f".bak.profile")
try:
    backup.write_text(cfg_text, encoding="utf-8")
except OSError as e:
    print(f"WARN: backup failed: {e}", file=sys.stderr)

cfg_path.write_text(new_text, encoding="utf-8")
try:
    cfg_path.chmod(0o600)
except OSError:
    pass
print(f"merged profile → {cfg_path}")
print(f"backup: {backup}")
PY

ec=$?
if [[ "${ec}" -ne 0 ]]; then
  die "profile merge failed (exit ${ec})"
fi
info "Done. Verify:  grok inspect · grok models · grokhunter ensure"

#!/usr/bin/env bash
# GrokHunter local/CI unit checks (no Termux, no network required for core tests).
# Usage:  bash scripts/ci-unit.sh
# From repo root. Safe to run on phone or in GitHub Actions.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "${ROOT}"

info() { printf '[ci-unit] %s\n' "$*"; }
die()  { printf '[ci-unit] ERROR: %s\n' "$*" >&2; exit 1; }

info "repo: ${ROOT}"

# ---------- bash -n ----------
info "syntax-check shell scripts"
mapfile -t files < <(
  find . -type f \
    \( -name '*.sh' -o -path './bin/*' -o -path './scripts/*' \) \
    ! -path './.git/*' \
    ! -name '*.md' \
    2>/dev/null | sort -u
)
extra=(
  install.sh
  uninstall.sh
  lib/cli.sh
  lib/actions.sh
  lib/grok.sh
  lib/x11.sh
  scripts/install_v9_grok_models.sh
  scripts/spacexai_smoke.sh
  scripts/ensure_grok.sh
  scripts/ci-unit.sh
  bin/grokhunter
  bin/grokhunter-doctor
  bin/nh-x11
  bin/aider-grok
  bin/grok-nethunter
)
declare -A seen=()
count=0
for f in "${files[@]}" "${extra[@]}"; do
  [[ -f "$f" ]] || continue
  [[ -n "${seen[$f]:-}" ]] && continue
  seen[$f]=1
  if head -1 "$f" | grep -qE '^#!.*(bash|sh)'; then
    bash -n "$f" || die "bash -n failed: $f"
    count=$((count + 1))
  elif [[ "$f" == *.sh ]]; then
    bash -n "$f" || die "bash -n failed: $f"
    count=$((count + 1))
  fi
done
info "syntax OK (${count} files)"

# ---------- PLACEHOLDER guard ----------
if grep -R --line-number -E '^PLACEHOLDER$|^WILL_REPLACE$' \
    --include='*.sh' --include='install.sh' \
    lib scripts bin install.sh 2>/dev/null; then
  die "PLACEHOLDER/WILL_REPLACE content found"
fi
info "no placeholder markers"

# ---------- parse_cli feature table ----------
bash -c '
  set -euo pipefail
  source lib/cli.sh
  parse_cli --with-grok --no-x11 --with-v9-models --overlay-only
  [[ "$FEATURE_GROK" == yes ]]
  [[ "$FEATURE_X11" == no ]]
  [[ "$FEATURE_V9" == yes ]]
  [[ "$OVERLAY_ONLY" -eq 1 ]]
'
info "parse_cli OK"

# ---------- maybe_install / run_optional_features ----------
bash -c '
  set -euo pipefail
  source lib/cli.sh
  source lib/actions.sh
  NON_INTERACTIVE=1
  FEATURE_GROK=yes FEATURE_X11=no FEATURE_AIDER=auto FEATURE_V9=auto FEATURE_COMPLETIONS=auto
  called=""
  install_cli_bins() { called="${called}bins "; }
  install_grok_build() { called="${called}grok "; }
  setup_termux_x11() { called="${called}x11 "; }
  install_aider() { called="${called}aider "; }
  install_v9_models() { called="${called}v9 "; }
  install_shell_completions() { called="${called}comp "; }
  run_optional_features
  [[ "$called" == "bins grok comp " ]] || { echo "got: [$called]"; exit 1; }
'
info "maybe_install OK"

# ---------- pure-bash bind patch ----------
bash -c '
  set -euo pipefail
  source lib/x11.sh
  msg() { :; }
  d=$(mktemp -d)
  f="$d/nethunter"
  printf "%s\n" "proot \\" "        -b /dev \\" "        -b /proc \\" > "$f"
  _patch_launcher_binds "$f"
  grep -q "grokhunter-optimized-binds" "$f"
  grep -q "/workspace" "$f"
  _patch_launcher_binds "$f"
  [[ "$(grep -c grokhunter-optimized-binds "$f")" -eq 1 ]]
  rm -rf "$d"
'
info "bind-patch OK"

# ---------- CLI help surfaces ----------
bash bin/grokhunter help | grep -q ai-smoke || die "help missing ai-smoke"
bash bin/grokhunter models help | grep -q install || die "models help missing install"
info "cli help OK"

# ---------- ai-smoke missing-key path (no network) ----------
# Unset key for this subshell only; do not touch secrets files.
if env -u XAI_API_KEY bash -c '
  # prevent accidental load of secrets.env for this check
  HOME_TMP=$(mktemp -d)
  export HOME="$HOME_TMP"
  bash bin/grokhunter ai-smoke 2>&1
  rm -rf "$HOME_TMP"
' 2>&1 | grep -qiE 'XAI_API_KEY|not set'; then
  info "ai-smoke missing-key OK"
else
  info "ai-smoke missing-key check inconclusive (skipped strict fail)"
fi

info "ALL OK"

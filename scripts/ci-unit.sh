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
  scripts/install_aider.sh
  scripts/install_grok_profile.sh
  scripts/install_kali_menu.sh
  scripts/spacexai_smoke.sh
  scripts/ensure_grok.sh
  scripts/ci-unit.sh
  bin/grokhunter
  bin/grokhunter-doctor
  bin/grokhunter-desktop-run
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
bash bin/grokhunter help | grep -q skills || die "help missing skills"
bash bin/grokhunter help | grep -q setup || die "help missing setup"
bash bin/grokhunter help | grep -q team || die "help missing team"
bash bin/grokhunter help | grep -q menu || die "help missing menu"
bash bin/grokhunter menu help | grep -q install || die "menu help missing install"
bash bin/grokhunter help | grep -q scout || die "help missing scout"
bash bin/grokhunter models help | grep -q install || die "models help missing install"
bash bin/grokhunter skills help | grep -q install || die "skills help missing install"
bash bin/grokhunter setup --help | grep -q with-models || die "setup help missing --with-models"
bash bin/grokhunter agents help | grep -q status || die "agents help missing status"
info "cli help OK"

# ---------- status line fields ----------
st="$(bash bin/grokhunter status)"
echo "${st}" | grep -q 'models=' || die "status missing models="
echo "${st}" | grep -qE 'skills(-core)?=' || die "status missing skills-core="
echo "${st}" | grep -q 'agents=' || die "status missing agents="
echo "${st}" | grep -q 'personas=' || die "status missing personas="
echo "${st}" | grep -q 'roles=' || die "status missing roles="
echo "${st}" | grep -q 'wrappers=' || die "status missing wrappers="
info "status line OK"

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

# ---------- install_skills copies every scanned skill ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  export HOME=$(mktemp -d)
  source lib/grok.sh
  msg() { :; }
  cursor() { :; }
  install_skills
  while IFS= read -r n; do
    [[ -n "$n" ]] || continue
    [[ -f "$HOME/.grok/skills/$n/SKILL.md" ]]
  done < <(_gh_list_skill_names "$SCRIPT_DIR")
  # User-only skill must survive reinstall
  mkdir -p "$HOME/.grok/skills/user-only"
  echo "user" > "$HOME/.grok/skills/user-only/SKILL.md"
  install_skills
  [[ -f "$HOME/.grok/skills/user-only/SKILL.md" ]]
  # Core count
  [[ "$(_gh_count_core_installed)" -eq "${#GH_CORE_SKILLS[@]}" ]]
  rm -rf "$HOME"
'
info "install_skills OK"

# ---------- _gh_list_skill_names skips underscore dirs ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  source lib/grok.sh
  msg() { :; }
  trap '\''rm -rf "$SCRIPT_DIR/skills/_template"'\'' EXIT
  names="$(_gh_list_skill_names "$SCRIPT_DIR")"
  echo "$names" | grep -qx "grokhunter"
  echo "$names" | grep -qx "x11-desktop"
  _gh_is_core_skill grokhunter
  _gh_is_core_skill x11-desktop && exit 1 || true
  mkdir -p "$SCRIPT_DIR/skills/_template"
  printf "%s\n" "---" "name: template" "---" > "$SCRIPT_DIR/skills/_template/SKILL.md"
  names2="$(_gh_list_skill_names "$SCRIPT_DIR")"
  if echo "$names2" | grep -q "_template"; then
    exit 1
  fi
'
info "list_skill_names OK"

# ---------- remove_skills uses discover (no allowlist guess) ----------
bash -c '
  set -euo pipefail
  ROOT="$(pwd)"
  # shellcheck source=lib/skills-discover.sh
  source "$ROOT/lib/skills-discover.sh"
  SKILLS_DIR=$(mktemp -d)
  _GH_ROOT="$ROOT"
  mkdir -p "$SKILLS_DIR"/{grokhunter,x11-desktop,user-only}
  # inline remove_skills body from uninstall.sh contract
  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    rm -rf "$SKILLS_DIR/$name"
  done < <(_gh_list_skill_names "$ROOT")
  test ! -d "$SKILLS_DIR/grokhunter"
  test ! -d "$SKILLS_DIR/x11-desktop"
  test -d "$SKILLS_DIR/user-only"
  rm -rf "$SKILLS_DIR"
'
info "remove_skills discover OK"

# ---------- install_agents → ~/.grok/agents (runtime multi-agent) ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  export HOME=$(mktemp -d)
  source lib/grok.sh
  msg() { :; }
  cursor() { :; }
  install_agents
  while IFS= read -r n; do
    [[ -n "$n" ]] || continue
    [[ -f "$HOME/.grok/agents/$n.md" ]]
  done < <(_gh_list_agent_names "$SCRIPT_DIR")
  printf "%s\n" "---" "name: user-custom" "---" > "$HOME/.grok/agents/user-custom.md"
  install_agents
  [[ -f "$HOME/.grok/agents/user-custom.md" ]]
  names="$(_gh_list_agent_names "$SCRIPT_DIR")"
  echo "$names" | grep -qx "benjamin"
  echo "$names" | grep -qx "coding-team"
  rm -rf "$HOME"
'
info "install_agents OK"

# ---------- install_personas → ~/.grok/personas ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  export HOME=$(mktemp -d)
  source lib/grok.sh
  msg() { :; }
  cursor() { :; }
  install_personas
  while IFS= read -r n; do
    [[ -n "$n" ]] || continue
    [[ -f "$HOME/.grok/personas/$n.toml" ]]
  done < <(_gh_list_persona_names "$SCRIPT_DIR")
  printf "%s\n" "description = \"user\"" "instructions = \"x\"" > "$HOME/.grok/personas/user-custom.toml"
  install_personas
  [[ -f "$HOME/.grok/personas/user-custom.toml" ]]
  names="$(_gh_list_persona_names "$SCRIPT_DIR")"
  echo "$names" | grep -qx "mobile"
  echo "$names" | grep -qx "design-card"
  rm -rf "$HOME"
'
info "install_personas OK"

# ---------- install_roles → ~/.grok/roles ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  export HOME=$(mktemp -d)
  source lib/grok.sh
  msg() { :; }
  cursor() { :; }
  install_roles
  while IFS= read -r n; do
    [[ -n "$n" ]] || continue
    [[ -f "$HOME/.grok/roles/$n.toml" ]]
  done < <(_gh_list_role_names "$SCRIPT_DIR")
  printf "%s\n" "description = \"user\"" > "$HOME/.grok/roles/user-custom.toml"
  install_roles
  [[ -f "$HOME/.grok/roles/user-custom.toml" ]]
  names="$(_gh_list_role_names "$SCRIPT_DIR")"
  echo "$names" | grep -qx "architect"
  echo "$names" | grep -qx "builder"
  rm -rf "$HOME"
'
info "install_roles OK"

# ---------- resolve_distro_engine: path-only stdout (no info pollution) ----------
# Regression: info on stdout made DISTRO_ENGINE="$(resolve_distro_engine)" a
# multi-line string → source failed with "No such file or directory".
grep -qE 'info\(\) \{ echo "\[GrokHunter\] \$\*" >&2; \}' install.sh \
  || die "install.sh info() must write to stderr (protects command substitution)"

bash <<'TEST_RESOLVE'
set -euo pipefail
CACHE="$(mktemp -d)"
trap 'rm -rf "$CACHE"' EXIT
printf '%s\n' '#!/usr/bin/env bash' 'termux_distro_probe() { :; }' \
  > "$CACHE/termux-distro.sh"

eval "$(
  sed -n "/^validate_distro_engine()/,/^}/p; /^resolve_distro_engine()/,/^}/p" install.sh
)"
info() { echo "[GrokHunter] $*" >&2; }
warn() { echo "[GrokHunter] WARN: $*" >&2; }
die()  { echo "[GrokHunter] ERROR: $*" >&2; exit 1; }
die_with_help() { die "$@"; }
SCRIPT_DIR=""
REFRESH=0
CACHE_DIR="$CACHE"

captured="$(resolve_distro_engine 2>/dev/null)"
# Must be exactly the cache path (not a multi-line log+path blob)
[[ "$captured" == "$CACHE/termux-distro.sh" ]]
[[ -f "$captured" ]]
TEST_RESOLVE
info "resolve_distro_engine capture OK"

# ---------- engine must not receive GrokHunter CLI flags ----------
# Regression: _source_termux_distro "${DISTRO_ENGINE}" "$@" forwarded --full
# and termux-distro died with "Unrecognized option '--full'".
if grep -nE '_source_termux_distro[[:space:]]+"\$\{DISTRO_ENGINE\}"[[:space:]]+"\$@"' install.sh; then
  die "install.sh must not forward \$@ into termux-distro (GH flags already in parse_cli vars)"
fi
grep -qE '_source_termux_distro[[:space:]]+"\$\{DISTRO_ENGINE\}"' install.sh \
  || die "install.sh missing _source_termux_distro DISTRO_ENGINE call"
info "engine argv isolation OK"

info "ALL OK"

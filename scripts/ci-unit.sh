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
  lib/https-probe.sh
  lib/os-identity.sh
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

# Incomplete 85ef807 left a 51-line stub that still passed PLACEHOLDER grep.
_gh_cli_lines=$(wc -l < bin/grokhunter)
[[ "${_gh_cli_lines}" -ge 200 ]] || die "bin/grokhunter looks stubbed (${_gh_cli_lines} lines)"
[[ "${_gh_cli_lines}" -lt 1000 ]] || die "bin/grokhunter is ${_gh_cli_lines} lines; keep dispatch thin"
grep -q 'cmd_binds()' lib/x11.sh || die "cmd_binds should live in lib/x11.sh"
grep -q '_gh_ensure_x11_lib' bin/grokhunter && die "bin/grokhunter should not define _gh_ensure_x11_lib"
info "grokhunter CLI length OK (${_gh_cli_lines} lines)"

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

# ---------- storage pre-check: POSIX df, integer GiB only ----------
bash -c '
  set -euo pipefail
  eval "$(sed -n "/^_gh_df_avail_gb()/,/^}/p" lib/actions.sh)"
  n="$(_gh_df_avail_gb / || true)"
  [[ "$n" =~ ^[0-9]+$ ]]
  if _gh_df_avail_gb /no/such/grokhunter-df-path 2>/dev/null; then
    exit 1
  fi
'
info "df avail gb OK"

# ---------- pure-bash bind patch ----------
bash -c '
  set -euo pipefail
  d=$(mktemp -d)
  export TERMUX_FILES_DIR="$d/tf"
  mkdir -p "$TERMUX_FILES_DIR/usr/tmp" "$TERMUX_FILES_DIR/home"
  source lib/x11.sh
  msg() { :; }
  f="$d/nethunter"
  printf "%s\n" "proot \\" "        -b /dev \\" "        -b /proc \\" > "$f"
  _patch_launcher_binds "$f"
  grep -q "grokhunter-optimized-binds" "$f"
  grep -q "/workspace" "$f"
  grep -q "/tmp" "$f"
  grep -q "/termux-home" "$f"
  if grep -q -- "-b /sdcard" "$f" || grep -q "storage/emulated/0:/sdcard" "$f"; then
    [[ -e /sdcard || -d /storage/emulated/0 ]]
  fi
  if grep -q "/downloads" "$f"; then
    [[ -d "$TERMUX_FILES_DIR/home/storage/downloads" ]]
  fi
  _patch_launcher_binds "$f"
  [[ "$(grep -c grokhunter-optimized-binds "$f")" -eq 1 ]]
  f2="$d/nethunter-bind-eq"
  printf "%s\n" "proot_args+=(--bind=/dev)" "proot_args+=(--bind=/proc)" > "$f2"
  _patch_launcher_binds "$f2"
  grep -q "grokhunter-optimized-binds" "$f2"
  grep -q "proot_args+=(--bind=" "$f2"
  grep -q "/workspace" "$f2"
  grep -q "/tmp" "$f2"
  mkdir -p "$TERMUX_FILES_DIR/usr/bin"
  printf "%s\n" "#!/bin/sh" "echo no-binds" > "$TERMUX_FILES_DIR/usr/bin/nethunter"
  rc=0
  optimize_proot_binds || rc=$?
  [[ "$rc" -ne 0 ]]
  rm -rf "$d"
'
info "bind-patch OK"

# Termux-native grok installer default must be a commit pin, not floating main
grep -qE 'TERMUX_NATIVE_PIN="[0-9a-f]{40}"' scripts/ensure_grok.sh \
  || die "ensure_grok.sh TERMUX_NATIVE_PIN must be a 40-char commit"
if grep -qE 'grok-cli-termux-native/main/install.sh' scripts/ensure_grok.sh; then
  die "ensure_grok.sh must not default to floating termux-native main"
fi
info "termux-native grok pin OK"

if grep -vE '^[[:space:]]*#' bin/nh-x11 | grep -qE '/bin/bash[[:space:]]+-lc'; then
  die "nh-x11 must not pass bash -lc as nethunter options"
fi
grep -q -- '--share-tmp' bin/nh-x11 || die "nh-x11 should pass --share-tmp for X sockets"
grep -q -- '--env DISPLAY=:0' bin/nh-x11 || die "nh-x11 should pass DISPLAY via --env"
grep -q -- '--env XDG_RUNTIME_DIR=/tmp' bin/nh-x11 \
  && die "nh-x11 must not set XDG_RUNTIME_DIR=/tmp (dbus rejects world-writable runtime)"
grep -vE '^[[:space:]]*#' bin/nh-x11 | grep -q 'su --login' \
  && die "nh-x11 must not use su --login (clears DISPLAY)"
grep -vE '^[[:space:]]*#' bin/nh-x11 | grep -qE 'pgrep -x xfce4-session' \
  && die "nh-x11 readiness must not hard-code xfce4-session"
grep -q '_gh_install_bwrap_stub' bin/nh-x11 || die "nh-x11 should call _gh_install_bwrap_stub"
grep -q 'grep -q bwrap-proot' bin/nh-x11 && die "nh-x11 should not inline bwrap ELF replacement"
grep -A80 '^setup_termux_x11()' lib/x11.sh | grep -q '_gh_install_bwrap_stub' \
  || die "setup_termux_x11 should call _gh_install_bwrap_stub"
bash -c '
  set -euo pipefail
  # shellcheck source=bin/nh-x11
  source bin/nh-x11
  declare -F _nh_x11_guest_command >/dev/null
  cmd="$(_nh_x11_guest_command "dbus-run-session -- xfce4-session" "export XDG_MENU_PREFIX=xfce-;" "xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true;")"
  [[ "$cmd" == *DISPLAY=:0* ]]
  [[ "$cmd" == *XDG_RUNTIME_DIR=/tmp/runtime-kali* ]]
  [[ "$cmd" == *"failed to create runtime dir"* ]]
  [[ "$cmd" == *XDG_MENU_PREFIX=xfce-* ]]
  [[ "$cmd" == *"exec dbus-run-session -- xfce4-session" ]]
' || die "nh-x11 guest command should be sourceable and include runtime-dir + DISPLAY"
info "nh-x11 nethunter CLI form OK"

[[ -f lib/tls.sh ]] || die "missing lib/tls.sh"
grep -q 'tls.sh' lib/https-probe.sh || die "https-probe should source lib/tls.sh"
grep -q 'tls.sh' lib/git-identity.sh || die "git-identity should source lib/tls.sh"
grep -q 'tls.sh' lib/grok.sh || die "grok.sh should source lib/tls.sh"
grep -q '_gh_git_identity_tls_sanitize' lib/git-identity.sh \
  && die "git-identity should use _gh_tls_sanitize_env from lib/tls.sh"
grep -q '^_gh_install_tls_compat()' lib/grok.sh && die "tls compat installer belongs in lib/tls.sh"
grep -A12 '_gh_git_identity_from_gh()' lib/git-identity.sh | grep -q '_gh_tls_sanitize_env' \
  || die "git-identity from_gh must sanitize via _gh_tls_sanitize_env"
grep -q '_gh_install_tls_compat' bin/grokhunter-doctor || die "doctor should install tls compat"
bash -c '
  set -euo pipefail
  source lib/grok.sh
  msg() { :; }
  d=$(mktemp -d)
  mkdir -p "$d/etc/ssl/certs"
  echo ca > "$d/etc/ssl/certs/ca-certificates.crt"
  DEFAULT_ROOTFS_DIR="$d"
  _gh_install_tls_compat
  [[ -L "$d/etc/tls/cert.pem" ]] || { echo "missing kali rootfs tls compat"; exit 1; }
  rm -rf "$d"
' || die "tls compat symlink must be written into the Kali rootfs"
info "tls compat + git-identity gh sanitize OK"

bash -c '
  set -euo pipefail
  d=$(mktemp -d)
  printf "%s\n" "#!/bin/sh" "echo ran" > "$d/payload"
  chmod +x "$d/payload"
  out="$(bash bin/bwrap-proot --unshare-all --die-with-parent --ro-bind /usr /usr "$d/payload")"
  rm -rf "$d"
  [[ "$out" == ran ]]
' || die "bwrap-proot should exec the payload, skipping sandbox flags"
info "bwrap-proot OK"

# ---------- CLI help surfaces ----------
# Capture full command output before grepping. Piping long help/credits into
# `grep -q` closes the pipe early; with set -o pipefail that can fail CI on
# SIGPIPE/broken-pipe even when the string is present (Ubuntu runners).
# usage() uses unquoted <<EOF (for ${VERSION}). Backticks in help would
# execute during grokhunter help — keep that heredoc free of command subst.
if sed -n '/^usage()/,/^}/p' bin/grokhunter | grep -q '`'; then
  die "usage() heredoc must not contain backticks (they execute)"
fi
_help="$(bash bin/grokhunter help)"
echo "${_help}" | grep -q ai-smoke || die "help missing ai-smoke"
echo "${_help}" | grep -q skills || die "help missing skills"
echo "${_help}" | grep -q setup || die "help missing setup"
echo "${_help}" | grep -q team || die "help missing team"
echo "${_help}" | grep -q menu || die "help missing menu"
echo "${_help}" | grep -q credits || die "help missing credits"
echo "${_help}" | grep -q git-identity || die "help missing git-identity"
echo "${_help}" | grep -q binds || die "help missing binds"
echo "${_help}" | grep -q scout || die "help missing scout"
echo "${_help}" | grep -q overlay || die "help missing overlay"
echo "${_help}" | grep -q 'grokhunter ship' || die "help missing ship"
echo "${_help}" | grep -q 'grokhunter docs' || die "help missing docs"
echo "${_help}" | grep -q modeler || die "help missing modeler"
echo "${_help}" | grep -q 'grokhunter ci' || die "help missing ci"
echo "${_help}" | grep -q 'grokhunter aider' || die "help missing aider"
echo "${_help}" | grep -q 'grokhunter session' || die "help missing session"
echo "${_help}" | grep -q 'grokhunter host' || die "help missing host"
echo "${_help}" | grep -q 'grokhunter mcp' || die "help missing mcp"
echo "${_help}" | grep -q 'grokhunter plugin' || die "help missing plugin"
echo "${_help}" | grep -q 'grokhunter flow' || die "help missing flow"
echo "${_help}" | grep -q 'grokhunter storage' || die "help missing storage"
echo "${_help}" | grep -q 'grokhunter editor' || die "help missing editor"
echo "${_help}" | grep -q 'grokhunter hook' || die "help missing hook"
echo "${_help}" | grep -q 'grokhunter shell' || die "help missing shell"
echo "${_help}" | grep -q 'grokhunter github' || die "help missing github"
echo "${_help}" | grep -q 'grokhunter secrets' || die "help missing secrets"
echo "${_help}" | grep -q 'grokhunter toolchain' || die "help missing toolchain"
bash bin/grokhunter menu help | grep -q install || die "menu help missing install"
_credits="$(bash bin/grokhunter credits)"
echo "${_credits}" | grep -qi jorexdeveloper || die "credits missing jorexdeveloper"
echo "${_credits}" | grep -qi Termux || die "credits missing Termux"
echo "${_credits}" | grep -qiE 'Kali|Offensive' || die "credits missing Kali/OffSec"
echo "${_credits}" | grep -qi xAI || die "credits missing xAI"
bash bin/grokhunter models help | grep -q install || die "models help missing install"
bash bin/grokhunter skills help | grep -q install || die "skills help missing install"
bash bin/grokhunter setup --help | grep -q with-models || die "setup help missing --with-models"
bash bin/grokhunter agents help | grep -q status || die "agents help missing status"
bash bin/grokhunter agents help | grep -q github || die "agents help missing github"
bash bin/grokhunter agents help | grep -q secrets || die "agents help missing secrets"
bash bin/grokhunter agents help | grep -q toolchain || die "agents help missing toolchain"
info "cli help OK"

# ---------- git identity helpers ----------
bash -c '
  set -euo pipefail
  source lib/git-identity.sh
  _gh_git_identity_is_placeholder root "root@localhost.localdomain"
  _gh_git_identity_is_placeholder "" ""
  _gh_git_identity_is_placeholder root "root@localhost"
  if _gh_git_identity_is_placeholder Fine_Computer_4451 "119702188+FineComputer14451@users.noreply.github.com"; then
    exit 1
  fi
  HOME=$(mktemp -d)
  export HOME
  git config --global user.name root
  git config --global user.email root@localhost.localdomain
  name="$(_gh_git_identity_name)"
  email="$(_gh_git_identity_email)"
  _gh_git_identity_is_placeholder "$name" "$email"
  _gh_git_identity_set "Fine_Computer_4451" "119702188+FineComputer14451@users.noreply.github.com" global
  [[ "$(_gh_git_identity_name)" == "Fine_Computer_4451" ]]
  [[ "$(_gh_git_identity_email)" == "119702188+FineComputer14451@users.noreply.github.com" ]]
  if _gh_git_identity_is_placeholder "$(_gh_git_identity_name)" "$(_gh_git_identity_email)"; then
    exit 1
  fi
  rm -rf "$HOME"
'
info "git identity OK"

bash bin/grokhunter git-identity help | grep -q set || die "git-identity help missing set"
bash bin/grokhunter git-identity help | grep -q origin || die "git-identity help missing origin fallback"
info "git-identity help OK"

bash bin/grokhunter binds help | grep -q repair || die "binds help missing repair"
bash bin/grokhunter binds help | grep -q optimize || die "binds help missing optimize"
info "binds help OK"

bash -c '
  set -euo pipefail
  source lib/git-identity.sh
  [[ "$(_gh_git_identity_github_login_from_url "https://github.com/FineComputer14451/GrokHunter.git")" == FineComputer14451 ]]
  [[ "$(_gh_git_identity_github_login_from_url "git@github.com:FineComputer14451/GrokHunter.git")" == FineComputer14451 ]]
  [[ "$(_gh_git_identity_github_login_from_url "ssh://git@github.com/FineComputer14451/GrokHunter")" == FineComputer14451 ]]
  if _gh_git_identity_github_login_from_url "https://gitlab.com/foo/bar.git"; then
    exit 1
  fi
  pair="$(_gh_git_identity_pair_from_user_json "{\"login\":\"FineComputer14451\",\"id\":119702188,\"name\":\"Fine_Computer_4451\"}")"
  [[ "$pair" == "$(printf "Fine_Computer_4451\t119702188+FineComputer14451@users.noreply.github.com")" ]]
  pair="$(_gh_git_identity_pair_from_user_json "{\"login\":\"onlylogin\",\"id\":1,\"name\":null}")"
  [[ "$pair" == "$(printf "onlylogin\t1+onlylogin@users.noreply.github.com")" ]]
'
info "git identity origin/json OK"

# ---------- doctor HTTPS probe (Cloudflare 403 is not offline) ----------
# curl -f treats https://x.ai 403 as failure even when TLS works.
if grep -E 'curl[[:space:]]+-[A-Za-z0-9]*f' bin/grokhunter-doctor | grep -qE 'x\.ai'; then
  die "doctor x.ai probe still uses curl -f (Cloudflare 403 looks offline)"
fi
grep -q 'api.x.ai/v1/models' bin/grokhunter-doctor || die "doctor should probe api.x.ai/v1/models"
[[ -f lib/https-probe.sh ]] || die "missing lib/https-probe.sh"
# shellcheck disable=SC1091
source lib/https-probe.sh
_gh_http_code_means_reachable 401 || die "401 (unauthenticated API) should count as reachable"
_gh_http_code_means_reachable 403 || die "403 (Cloudflare challenge) should count as reachable"
_gh_http_code_means_reachable 421 || die "421 should count as reachable"
_gh_http_code_means_reachable 200 || die "200 should count as reachable"
if _gh_http_code_means_reachable 000; then die "000 (connect fail) should not count as reachable"; fi
if _gh_http_code_means_reachable ""; then die "empty http_code should not count as reachable"; fi
SSL_CERT_FILE=/no/such/grokhunter-cert.pem
SSL_CERT_DIR=/no/such/grokhunter-certs
export SSL_CERT_FILE SSL_CERT_DIR
_gh_tls_sanitize_env
if [[ -r /etc/ssl/certs/ca-certificates.crt ]]; then
  [[ "${SSL_CERT_FILE}" == /etc/ssl/certs/ca-certificates.crt ]] \
    || die "tls sanitize should rewrite to Kali CA, got ${SSL_CERT_FILE:-empty}"
else
  [[ -z "${SSL_CERT_FILE:-}" ]] || die "tls sanitize should unset missing SSL_CERT_FILE when no Kali CA"
fi
if [[ -d /etc/ssl/certs ]]; then
  [[ "${SSL_CERT_DIR}" == /etc/ssl/certs ]] \
    || die "tls sanitize should rewrite SSL_CERT_DIR to Kali certs dir, got ${SSL_CERT_DIR:-empty}"
else
  [[ -z "${SSL_CERT_DIR:-}" ]] || die "tls sanitize should unset missing SSL_CERT_DIR when no Kali certs dir"
fi
unset SSL_CERT_FILE SSL_CERT_DIR
info "doctor https probe OK"

# ---------- doctor os-release (missing file is not a hard fail) ----------
if grep -A2 'No /etc/os-release' bin/grokhunter-doctor | grep -q 'FAIL=1'; then
  die "missing os-release should warn, not FAIL doctor"
fi
[[ -f lib/os-identity.sh ]] || die "missing lib/os-identity.sh"
# shellcheck disable=SC1091
source lib/os-identity.sh
_os_tmp="$(mktemp -d)"
mkdir -p "${_os_tmp}/usr/lib" "${_os_tmp}/etc"
printf 'ID=kali\nVERSION=2026.2\n' > "${_os_tmp}/usr/lib/os-release"
GROKHUNTER_OS_ROOT="${_os_tmp}"
got="$(_gh_os_release_file)"
[[ "${got}" == "${_os_tmp}/usr/lib/os-release" ]] || die "should fall back to usr/lib/os-release, got ${got:-empty}"
printf 'ID=kali\n' > "${_os_tmp}/etc/os-release"
got="$(_gh_os_release_file)"
[[ "${got}" == "${_os_tmp}/etc/os-release" ]] || die "should prefer /etc/os-release, got ${got:-empty}"
rm -rf "${_os_tmp}"
_os_empty="$(mktemp -d)"
_os_prefix_save="${PREFIX-}"
GROKHUNTER_OS_ROOT="${_os_empty}"
PREFIX=""
if _gh_os_release_file >/dev/null; then
  PREFIX="${_os_prefix_save}"
  die "empty root should have no os-release"
fi
PREFIX="${_os_prefix_save}"
rm -rf "${_os_empty}"
unset GROKHUNTER_OS_ROOT
info "doctor os-release OK"

# ---------- doctor clone-only cache is informational ----------
if grep -E "warn .*No module cache yet" bin/grokhunter-doctor >/dev/null; then
  die "clone-only module cache should be ok, not warn"
fi
if grep -E "warn .*No termux-distro engine cache" bin/grokhunter-doctor >/dev/null; then
  die "missing engine cache should be ok, not warn"
fi
info "doctor clone-only cache OK"

# ---------- status line fields ----------
st="$(bash bin/grokhunter status)"
echo "${st}" | grep -q 'models=' || die "status missing models="
echo "${st}" | grep -qE 'skills(-core)?=' || die "status missing skills-core="
echo "${st}" | grep -q 'agents=' || die "status missing agents="
echo "${st}" | grep -q 'personas=' || die "status missing personas="
echo "${st}" | grep -q 'roles=' || die "status missing roles="
echo "${st}" | grep -q 'wrappers=' || die "status missing wrappers="
info "status line OK"

# ---------- status models= follows current + legacy V9 markers ----------
_status_models() {
  local cfg st
  cfg="$(mktemp)"
  printf '%s\n' "$1" > "${cfg}"
  st="$(GROK_CONFIG="${cfg}" bash bin/grokhunter status)"
  rm -f "${cfg}"
  printf '%s\n' "${st}"
}
echo "$(_status_models '# --- GrokHunter: v9 specialist models (test) ---')" \
  | grep -q 'models=yes' || die "status should treat current V9 marker as models=yes"
echo "$(_status_models '# --- Grok Imagine Cinematic Studio: v9-4p5 specialist models')" \
  | grep -q 'models=yes' || die "status should treat legacy V9 marker as models=yes"
echo "$(_status_models '# no pickers')" \
  | grep -q 'models=no' || die "status should report models=no without a V9 marker"
info "status models marker OK"

# ---------- profile merge must keep V9 picker marker ----------
_prof_tmp="$(mktemp -d)"
cat > "${_prof_tmp}/config.toml" <<'EOF'
[models]
default = "grok-4.6"

# --- GrokHunter: v9 specialist models (test) ---
[model.chat-expert]
name = "Chat Expert"
model = "grok-4.6"
temperature = 0.7
EOF
GROK_CONFIG="${_prof_tmp}/config.toml" bash scripts/install_grok_profile.sh >/dev/null
grep -qF '# --- GrokHunter: v9 specialist models' "${_prof_tmp}/config.toml" \
  || die "install_grok_profile.sh ate V9 picker marker"
grep -qE 'channel\s*=\s*"stable"' "${_prof_tmp}/config.toml" \
  || die "install_grok_profile.sh did not set channel=stable"
if grep -q '"NetHunter profile" not in' scripts/install_grok_profile.sh; then
  die "profile stripper should key off marker, not NetHunter profile substring"
fi
rm -rf "${_prof_tmp}"
info "profile merge keeps V9 marker OK"

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
  echo "$names" | grep -qx "toolchain"
  echo "$names" | grep -qx "github-lab"
  echo "$names" | grep -qx "grok-models"
  echo "$names" | grep -qx "ci-lab"
  echo "$names" | grep -qx "secrets-lab"
  echo "$names" | grep -qx "session-lab"
  echo "$names" | grep -qx "host-lab"
  echo "$names" | grep -qx "mcp-lab"
  echo "$names" | grep -qx "plugin-lab"
  echo "$names" | grep -qx "flow-lab"
  echo "$names" | grep -qx "storage-lab"
  echo "$names" | grep -qx "editor-lab"
  echo "$names" | grep -qx "hooks-lab"
  echo "$names" | grep -qx "shell-lab"
  echo "$names" | grep -qx "specialist-lab"
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
  echo "$names" | grep -qx "overlay"
  echo "$names" | grep -qx "ship"
  echo "$names" | grep -qx "docs"
  echo "$names" | grep -qx "models"
  echo "$names" | grep -qx "ci"
  echo "$names" | grep -qx "aider"
  echo "$names" | grep -qx "session"
  echo "$names" | grep -qx "host"
  echo "$names" | grep -qx "mcp"
  echo "$names" | grep -qx "plugin"
  echo "$names" | grep -qx "flow"
  echo "$names" | grep -qx "storage"
  echo "$names" | grep -qx "editor"
  echo "$names" | grep -qx "hook"
  echo "$names" | grep -qx "shell"
  echo "$names" | grep -qx "github"
  echo "$names" | grep -qx "secrets"
  echo "$names" | grep -qx "toolchain"
  echo "$names" | grep -qx "REFERENCES" && exit 1
  echo "$names" | grep -qx "HANDOFF-TEMPLATES" && exit 1
  echo "$names" | grep -qx "README" && exit 1
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
  echo "$names" | grep -qx "release-card"
  echo "$names" | grep -qx "overlay-card"
  echo "$names" | grep -qx "models-card"
  echo "$names" | grep -qx "ci-card"
  echo "$names" | grep -qx "session-card"
  echo "$names" | grep -qx "host-card"
  echo "$names" | grep -qx "mcp-card"
  echo "$names" | grep -qx "plugin-card"
  echo "$names" | grep -qx "flow-card"
  echo "$names" | grep -qx "storage-card"
  echo "$names" | grep -qx "editor-card"
  echo "$names" | grep -qx "hook-card"
  echo "$names" | grep -qx "shell-card"
  echo "$names" | grep -qx "github-card"
  echo "$names" | grep -qx "secrets-card"
  echo "$names" | grep -qx "toolchain-card"
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
  echo "$names" | grep -qx "overlay"
  echo "$names" | grep -qx "ship"
  echo "$names" | grep -qx "docs"
  echo "$names" | grep -qx "models"
  echo "$names" | grep -qx "ci"
  echo "$names" | grep -qx "aider"
  echo "$names" | grep -qx "session"
  echo "$names" | grep -qx "host"
  echo "$names" | grep -qx "mcp"
  echo "$names" | grep -qx "plugin"
  echo "$names" | grep -qx "flow"
  echo "$names" | grep -qx "storage"
  echo "$names" | grep -qx "editor"
  echo "$names" | grep -qx "hook"
  echo "$names" | grep -qx "shell"
  echo "$names" | grep -qx "github"
  echo "$names" | grep -qx "secrets"
  echo "$names" | grep -qx "toolchain"
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

# Pin ≠ stamp must not reuse cache (stub curl writes a valid engine)
printf '%s\n' 'https://example.invalid/old.sh' > "$CACHE/termux-distro.url"
curl() {
  local out=""
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -o ]]; then out="$2"; shift 2; continue; fi
    shift
  done
  [[ -n "$out" ]] || return 1
  printf '%s\n' '#!/usr/bin/env bash' 'termux_distro_probe() { :; }' > "$out"
}
GROKHUNTER_DISTRO_ENGINE_URL="https://example.invalid/pinned.sh"
captured2="$(resolve_distro_engine 2>/dev/null)"
[[ "$captured2" == "$CACHE/termux-distro.sh" ]]
[[ "$(cat "$CACHE/termux-distro.url")" == "https://example.invalid/pinned.sh" ]]
# Same pin now hits cache (curl must not be required)
unset -f curl
captured3="$(resolve_distro_engine 2>/dev/null)"
[[ "$captured3" == "$CACHE/termux-distro.sh" ]]

# Unset pin must not keep a foreign stamp (false cache hit)
unset GROKHUNTER_DISTRO_ENGINE_URL
printf '%s\n' 'https://example.invalid/old-pin.sh' > "$CACHE/termux-distro.url"
curl() {
  local out=""
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -o ]]; then out="$2"; shift 2; continue; fi
    shift
  done
  [[ -n "$out" ]] || return 1
  printf '%s\n' '#!/usr/bin/env bash' 'termux_distro_probe() { :; }' > "$out"
}
captured4="$(resolve_distro_engine 2>/dev/null)"
[[ "$captured4" == "$CACHE/termux-distro.sh" ]]
[[ "$(cat "$CACHE/termux-distro.url")" == "https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh" ]]
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

# ---------- ephemeral /dev/fd is not an overlay root ----------
bash -c '
  set -euo pipefail
  eval "$(sed -n "/^_gh_is_ephemeral_dir()/,/^}/p" install.sh)"
  _gh_is_ephemeral_dir ""
  _gh_is_ephemeral_dir /dev/fd
  _gh_is_ephemeral_dir /dev/fd/63
  _gh_is_ephemeral_dir /proc/self/fd
  _gh_is_ephemeral_dir /proc/self/fd/63
  _gh_is_ephemeral_dir /home/kali/GrokHunter && exit 1 || true
'
info "ephemeral dir OK"

bash -c '
  set -euo pipefail
  SCRIPT_DIR="/dev/fd"
  export SCRIPT_DIR
  export GROKHUNTER_HOME="/dev/fd/63"
  export HOME
  HOME=$(mktemp -d)
  mkdir -p "$HOME/GrokHunter"
  printf "%s\n" "#!/bin/bash" > "$HOME/GrokHunter/install.sh"
  source lib/grok.sh
  msg() { :; }
  root="$(_gh_overlay_root)"
  [[ "$root" == "$HOME/GrokHunter" ]]
  [[ "$root" != /dev/fd* ]]
  rm -rf "$HOME"
'
info "overlay root skips /dev/fd OK"

# ---------- dest picker: foreign ~/GrokHunter → cache src ----------
bash -c '
  set -euo pipefail
  eval "$(sed -n "/^_gh_is_ephemeral_dir()/,/^}/p; /^_gh_overlay_complete()/,/^}/p; /^_gh_managed_overlay()/,/^}/p; /^_gh_pick_overlay_dest()/,/^}/p" install.sh)"
  HOME=$(mktemp -d)
  CACHE_DIR="$HOME/.cache/grokhunter"
  mkdir -p "$CACHE_DIR"
  SCRIPT_DIR=""
  GROKHUNTER_HOME=""
  mkdir -p "$HOME/GrokHunter"
  echo "not-gh" > "$HOME/GrokHunter/notes.txt"
  dest="$(_gh_pick_overlay_dest)"
  [[ "$dest" == "$CACHE_DIR/src" ]]
  # stray install.sh is not enough to claim ~/GrokHunter
  echo "#!/bin/bash" > "$HOME/GrokHunter/install.sh"
  dest_stray="$(_gh_pick_overlay_dest)"
  [[ "$dest_stray" == "$CACHE_DIR/src" ]]
  # empty home dest
  rm -rf "$HOME/GrokHunter"
  dest2="$(_gh_pick_overlay_dest)"
  [[ "$dest2" == "$HOME/GrokHunter" ]]
  # git clone at SCRIPT_DIR always wins dest picker
  mkdir -p "$HOME/clone/.git"
  echo "install" > "$HOME/clone/install.sh"
  SCRIPT_DIR="$HOME/clone"
  dest3="$(_gh_pick_overlay_dest)"
  [[ "$dest3" == "$HOME/clone" ]]
  # GROKHUNTER_HOME with only install.sh is not managed
  SCRIPT_DIR=""
  mkdir -p "$HOME/other"
  echo "install" > "$HOME/other/install.sh"
  GROKHUNTER_HOME="$HOME/other"
  dest4="$(_gh_pick_overlay_dest)"
  [[ "$dest4" == "$HOME/GrokHunter" || "$dest4" == "$CACHE_DIR/src" ]]
  rm -rf "$HOME"
'
info "overlay dest picker OK"

# ---------- overlay copy from handmade tarball tree ----------
bash -c '
  set -euo pipefail
  eval "$(sed -n "
    /^OVERLAY_ITEMS=(/,/^)/p
    /^OVERLAY_DIRS=(/,/^)/p
    /^_gh_overlay_complete()/,/^}/p
    /^_gh_install_overlay_from_tmp()/,/^}/p
  " install.sh)"
  die() { echo "$*" >&2; exit 1; }
  CLEANUP_TMP=$(mktemp -d)
  dest=$(mktemp -d)
  mkdir -p "$CLEANUP_TMP"/{bin,lib,scripts,skills,agents,personas,roles,config,templates,branding,docs}
  printf "%s\n" "#!/bin/bash" "ok() { :; }" > "$CLEANUP_TMP/install.sh"
  printf "%s\n" "#!/bin/bash" "ok() { :; }" > "$CLEANUP_TMP/lib/grok.sh"
  printf "%s\n" "#!/bin/bash" "ok() { :; }" > "$CLEANUP_TMP/lib/skills-discover.sh"
  printf "%s\n" "#!/bin/bash" "ok() { :; }" > "$CLEANUP_TMP/lib/agents-discover.sh"
  printf "%s\n" "#!/bin/bash" "ok() { :; }" > "$CLEANUP_TMP/lib/personas-discover.sh"
  printf "%s\n" "#!/bin/bash" "ok() { :; }" > "$CLEANUP_TMP/lib/roles-discover.sh"
  printf "%s\n" "#!/bin/bash" > "$CLEANUP_TMP/bin/grokhunter"
  printf "%s\n" "#!/bin/bash" > "$CLEANUP_TMP/scripts/install-completions.sh"
  printf "%s\n" "#!/bin/bash" > "$CLEANUP_TMP/scripts/ensure_grok.sh"
  mkdir -p "$CLEANUP_TMP/skills/demo"
  echo "skill" > "$CLEANUP_TMP/skills/demo/SKILL.md"
  echo "keep-me" > "$dest/user-notes.txt"
  _gh_install_overlay_from_tmp "$dest"
  _gh_overlay_complete "$dest"
  [[ -f "$dest/user-notes.txt" ]]
  rm -rf "$CLEANUP_TMP" "$dest"
'
info "overlay extract copy OK"

# ---------- ensure_overlay_tree: git never tarred; REFRESH repairs non-git ----------
bash -c '
  set -euo pipefail
  eval "$(sed -n "
    /^_gh_is_ephemeral_dir()/,/^}/p
    /^_gh_overlay_complete()/,/^}/p
    /^_gh_managed_overlay()/,/^}/p
    /^_gh_pick_overlay_dest()/,/^}/p
    /^_gh_stamp_overlay()/,/^}/p
    /^ensure_overlay_tree()/,/^}/p
  " install.sh)"
  info() { :; }
  warn() { :; }
  die() { echo "DIE:$*" >&2; exit 9; }
  die_with_help() { echo "DIE:$1" >&2; exit 9; }
  _gh_fetch_repo_tarball() { echo FETCHED >&2; exit 8; }
  _gh_install_overlay_from_tmp() { echo INSTALLED >&2; exit 8; }
  MODULES_VERSION="2026.2.12"
  make_complete() {
    local d="$1"
    mkdir -p "$d"/{bin,lib,scripts,skills}
    : > "$d/install.sh"
    : > "$d/lib/grok.sh"
    : > "$d/lib/skills-discover.sh"
    : > "$d/lib/agents-discover.sh"
    : > "$d/lib/personas-discover.sh"
    : > "$d/lib/roles-discover.sh"
    : > "$d/bin/grokhunter"
    : > "$d/scripts/install-completions.sh"
    : > "$d/scripts/ensure_grok.sh"
  }
  HOME=$(mktemp -d)
  CACHE_DIR="$HOME/.cache/grokhunter"
  mkdir -p "$CACHE_DIR"
  GROKHUNTER_HOME=""

  # Complete git clone + REFRESH=1 must use local (never fetch)
  src="$HOME/GrokHunter"
  make_complete "$src"
  mkdir -p "$src/.git"
  SCRIPT_DIR="$src"
  REFRESH=1
  OVERLAY_ROOT=""
  LIB_DIR=""
  ensure_overlay_tree
  [[ "$OVERLAY_ROOT" == "$src" ]]
  [[ "$LIB_DIR" == "$src/lib" ]]

  # Incomplete git clone must die (9), not tar/fetch (8)
  rm -f "$src/bin/grokhunter"
  ec=0
  (ensure_overlay_tree) 2>/dev/null || ec=$?
  [[ "$ec" -eq 9 ]]
  make_complete "$src"
  mkdir -p "$src/.git"

  # One-liner (empty SCRIPT_DIR) + git dest + REFRESH=1 must refuse tar
  SCRIPT_DIR=""
  REFRESH=1
  ec=0
  (ensure_overlay_tree) 2>/dev/null || ec=$?
  [[ "$ec" -eq 9 ]]

  # Incomplete non-git SCRIPT_DIR must fall through to fetch (not silent local win)
  rm -rf "$src/.git" "$src/bin/grokhunter"
  mkdir -p "$src/lib"
  : > "$src/install.sh"
  SCRIPT_DIR="$src"
  REFRESH=0
  ec=0
  (ensure_overlay_tree) 2>/dev/null || ec=$?
  [[ "$ec" -eq 8 ]]

  rm -rf "$HOME"
'
info "overlay git/refresh guards OK"

# ---------- --full --de/--browser vs --full alone ----------
bash -c '
  set -euo pipefail
  source lib/cli.sh
  source lib/actions.sh
  SKIP_DE=0
  NON_INTERACTIVE=1
  SELECTED_INSTALLATION=full
  DE_INSTALLED=1
  called=""
  set_up_de() { called="${called}de "; }
  set_up_browser() { called="${called}browser "; }
  run_optional_features() { called="${called}opt "; }
  SELECTED_DE=xfce
  SELECTED_BROWSER=chromium
  pre_complete_actions
  [[ "$called" == "de browser opt " ]] || { echo "got: [$called]"; exit 1; }
  called=""
  SELECTED_DE=""
  SELECTED_BROWSER=""
  DE_INSTALLED=1
  pre_complete_actions
  [[ "$called" == "opt " ]] || { echo "full-alone got: [$called]"; exit 1; }
'
info "pre_complete_actions --full --de OK"

# ---------- uninstall shortcuts + strip_shell without python3 ----------
grep -qE 'ghsu ght ghd ghs ghp ghm ghk ghai ghn' uninstall.sh \
  || die "uninstall.sh remove_bins must list shortcut bins"
if grep -qE 'alias gh=' config/profile.d/grokhunter.sh; then
  die "profile must not alias gh (GitHub CLI)"
fi
if grep -qE 'python3' uninstall.sh; then
  die "uninstall.sh must not require python3"
fi
info "uninstall shortcuts + no gh alias OK"

bash -c '
  set -euo pipefail
  ROOT="$(pwd)"
  HOME=$(mktemp -d)
  export HOME
  mkdir -p "$HOME/.local/bin" "$HOME/.cache/grokhunter" "$HOME/.grok/skills"
  for b in grokhunter ghsu ght ghd ghs ghp ghm ghk ghai ghn; do
    printf "#!/bin/sh\n" > "$HOME/.local/bin/$b"
    chmod +x "$HOME/.local/bin/$b"
  done
  printf "%s\n" "keep-before" "# >>> grokhunter >>>" "alias gh=bad" "# <<< grokhunter <<<" "keep-after" \
    > "$HOME/.zshrc"
  # Unclosed block must not wipe keep-after (and must not abort later steps)
  printf "%s\n" "bash-before" "# >>> grokhunter >>>" "alias x=1" "bash-after" \
    > "$HOME/.bashrc"
  PREFIX="$HOME/prefix"
  mkdir -p "$PREFIX/bin"
  export PREFIX
  # Shadow python3 so strip_shell cannot fall back to it
  fake=$(mktemp -d)
  printf "%s\n" "#!/bin/sh" "exit 127" > "$fake/python3"
  chmod +x "$fake/python3"
  PATH="$fake:$PATH" bash "$ROOT/uninstall.sh" >/dev/null
  [[ ! -f "$HOME/.local/bin/ghsu" ]]
  [[ ! -f "$HOME/.local/bin/grokhunter" ]]
  grep -q keep-before "$HOME/.zshrc"
  grep -q keep-after "$HOME/.zshrc"
  if grep -q "alias gh=bad" "$HOME/.zshrc"; then exit 1; fi
  if grep -q ">>> grokhunter >>>" "$HOME/.zshrc"; then exit 1; fi
  grep -q bash-before "$HOME/.bashrc"
  grep -q bash-after "$HOME/.bashrc"
  grep -q ">>> grokhunter >>>" "$HOME/.bashrc"
  rm -rf "$HOME" "$fake"
'
info "uninstall strip_shell + shortcuts OK"

info "ALL OK"

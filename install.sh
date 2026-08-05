#!/usr/bin/env bash
# GrokHunter installer — Kali NetHunter × Grok Build overlay
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(tr -d '[:space:]' < "${ROOT}/VERSION" 2>/dev/null || echo "1.0.0")"
MIN_GROK="${GROKHUNTER_MIN_GROK:-0.2.93}"
INSTALL_META_DIR="${HOME}/.grokhunter"
BIN_DIR="${HOME}/.local/bin"
SKILLS_DIR="${HOME}/.grok/skills"
GROK_HOME="${HOME}/.grok"
MARKER_BEGIN="# >>> grokhunter >>>"
MARKER_END="# <<< grokhunter <<<"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[1;36m'
NC=$'\033[0m'

log()  { printf "${GREEN}[+]${NC} %s\n" "$*"; }
info() { printf "${CYAN}[*]${NC} %s\n" "$*"; }
warn() { printf "${YELLOW}[!]${NC} %s\n" "$*"; }
die()  { printf "${RED}[x]${NC} %s\n" "$*" >&2; exit 1; }

banner() {
  if [[ -t 1 && -f "${ROOT}/branding/banner.txt" ]]; then
    cat "${ROOT}/branding/banner.txt"
  else
    echo "=== GrokHunter v${VERSION} ==="
  fi
  echo "  Kali NetHunter powered by Grok Build"
  echo
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

detect_env() {
  info "Detecting environment…"
  ARCH="$(uname -m)"
  case "$ARCH" in
    aarch64|arm64|x86_64|amd64) log "Arch: $ARCH" ;;
    *) warn "Unusual arch $ARCH — Grok Build may not ship a binary" ;;
  esac
  if [[ -r /etc/os-release ]]; then
    # Do not source os-release into this shell — it clobbers VERSION=
    local os_pretty
    os_pretty=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-$ID}")
    log "OS: ${os_pretty}"
  fi
  if [[ -x /system/bin/getprop ]] || command -v getprop >/dev/null 2>&1; then
    log "Android host signals detected (NetHunter-class)"
  fi
}

ensure_dirs() {
  mkdir -p "$BIN_DIR" "$SKILLS_DIR" "$GROK_HOME" "$INSTALL_META_DIR"
  mkdir -p "${GROK_HOME}/bin"
}

ensure_grok() {
  info "Ensuring Grok Build CLI (≥ ${MIN_GROK})…"
  export PATH="${GROK_HOME}/bin:${BIN_DIR}:${PATH}"
  local need=1
  if command -v grok >/dev/null 2>&1; then
    local gver
    gver=$(grok --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
    if [[ -n "$gver" ]] && printf '%s\n%s\n' "$MIN_GROK" "$gver" | sort -V | head -1 | grep -qx "$MIN_GROK"; then
      log "Grok Build ${gver} OK"
      need=0
    else
      warn "Grok Build ${gver:-unknown} below min — upgrading"
    fi
  fi
  if [[ "$need" -eq 1 || "${CINEMATIC_FORCE_GROK_CLI:-${GROKHUNTER_FORCE_GROK:-}}" == "1" ]]; then
    need_cmd curl
    curl -fsSL https://x.ai/cli/install.sh | bash || die "Grok install failed"
    export PATH="${GROK_HOME}/bin:${BIN_DIR}:${PATH}"
    command -v grok >/dev/null 2>&1 || die "grok still not on PATH after install"
    log "Installed: $(grok --version 2>/dev/null | head -1)"
  fi
}

install_bins() {
  info "Installing launchers → ${BIN_DIR}"
  for b in grokhunter grok-nethunter grokhunter-doctor; do
    install -m 0755 "${ROOT}/bin/${b}" "${BIN_DIR}/${b}"
    log "  ${b}"
  done
  # Keep legacy name in sync if present as older thin wrapper
  if [[ -L "${BIN_DIR}/gh" ]]; then
    rm -f "${BIN_DIR}/gh"
  fi
}

install_skills() {
  info "Installing skills → ${SKILLS_DIR}"
  for s in grokhunter nethunter-recon; do
    mkdir -p "${SKILLS_DIR}/${s}"
    cp -a "${ROOT}/skills/${s}/." "${SKILLS_DIR}/${s}/"
    log "  skill: ${s}"
  done
}

# Lightweight TOML key upsert for simple flat keys under a section
# Avoids full TOML rewrite so custom [model.*] blocks survive.
merge_config() {
  info "Merging NetHunter profile into ~/.grok/config.toml"
  local cfg="${GROK_HOME}/config.toml"
  local snippet="${ROOT}/config/grok-build.nethunter.toml"
  if [[ ! -f "$cfg" ]]; then
    cp "$snippet" "$cfg"
    log "Created config.toml from NetHunter snippet"
    return 0
  fi
  local bak="${cfg}.bak.grokhunter-$(date +%Y%m%d-%H%M%S)"
  cp -a "$cfg" "$bak"
  log "Backup: $bak"

  # Merge NetHunter UI/model keys without wiping custom [model.*] blocks
  if ! python3 - "$cfg" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()

def ensure_section(text, section, keys):
    sec_pat = re.compile(rf"(?m)^\[{re.escape(section)}\]\s*$")
    m = sec_pat.search(text)
    if not m:
        block = f"\n[{section}]\n" + "\n".join(f"{k} = {v}" for k, v in keys) + "\n"
        return text.rstrip() + "\n" + block
    start = m.end()
    nxt = re.search(r"(?m)^\[", text[start:])
    end = start + nxt.start() if nxt else len(text)
    body = text[start:end]
    for k, v in keys:
        line_re = re.compile(rf"(?m)^(\s*{re.escape(k)}\s*=\s*).*$")
        if line_re.search(body):
            body = line_re.sub(rf"\1{v}", body, count=1)
        else:
            body = body.rstrip() + f"\n{k} = {v}\n"
    return text[:start] + body + text[end:]

text = ensure_section(text, "ui", [
    ("screen_mode", '"fullscreen"'),
    ("max_thoughts_width", "100"),
    ("compact_mode", "true"),
    ("permission_mode", '"always-approve"'),
    ("theme", '"groknight"'),
    ("fork_secondary_model", '"grok-build"'),
    ("combine_queued_prompts", "true"),
])
text = ensure_section(text, "models", [
    ("default", '"grok-4.5"'),
    ("default_reasoning_effort", '"high"'),
])
text = ensure_section(text, "features", [
    ("telemetry", "false"),
])
open(path, "w", encoding="utf-8").write(text)
print("merged")
PY
  then
    warn "Python merge failed — leaving config as-is (backup kept)"
    return 0
  fi
  log "Config keys merged (custom models preserved)"
}

inject_shell() {
  local profile_src="${ROOT}/config/profile.d/grokhunter.sh"

  inject_file() {
    local target="$1"
    [[ -f "$target" ]] || touch "$target"
    python3 -c '
import re, sys
path = sys.argv[1]
block_path = sys.argv[2]
text = open(path, encoding="utf-8").read()
block = open(block_path, encoding="utf-8").read().rstrip() + "\n"
begin, end = "# >>> grokhunter >>>", "# <<< grokhunter <<<"
pat = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n?", re.S)
if pat.search(text):
    text = pat.sub(block, text)
    action = "updated"
else:
    text = text.rstrip() + "\n\n" + block + "\n"
    action = "appended"
open(path, "w", encoding="utf-8").write(text)
print(action)
' "$target" "$profile_src" >/dev/null
    log "Shell profile ready: $target"
  }

  inject_file "${HOME}/.zshrc"
  inject_file "${HOME}/.bashrc"
}

install_motd() {
  local src="${ROOT}/config/motd.d/99-grokhunter"
  local dest="/etc/update-motd.d/99-grokhunter"
  if [[ "$(id -u)" -eq 0 ]]; then
    install -m 0755 "$src" "$dest"
    log "MOTD installed: $dest"
  elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    sudo install -m 0755 "$src" "$dest" && log "MOTD installed via sudo: $dest" || warn "MOTD skip (sudo failed)"
  else
    # User-local fallback
    mkdir -p "${HOME}/.grokhunter"
    install -m 0755 "$src" "${HOME}/.grokhunter/99-grokhunter.motd"
    info "MOTD fragment saved to ~/.grokhunter/99-grokhunter.motd (no root for /etc)"
  fi
}

copy_agents() {
  # Workspace AGENTS for home when missing
  if [[ ! -f "${HOME}/AGENTS.md" ]]; then
    cp "${ROOT}/AGENTS.md" "${HOME}/AGENTS.md"
    log "Installed ~/AGENTS.md"
  else
    # Keep user AGENTS; drop a copy under .grokhunter
    cp "${ROOT}/AGENTS.md" "${INSTALL_META_DIR}/AGENTS.md"
    info "Existing ~/AGENTS.md kept; GrokHunter copy at ~/.grokhunter/AGENTS.md"
  fi
  # Always keep repo AGENTS as source of truth inside project
  :
}

write_meta() {
  cat > "${INSTALL_META_DIR}/install.meta" <<EOF
version=${VERSION}
installed_at=$(date -Iseconds)
root=${ROOT}
min_grok=${MIN_GROK}
host=$(hostname 2>/dev/null || echo unknown)
arch=$(uname -m)
EOF
  # Version stamp for profile
  echo "$VERSION" > "${INSTALL_META_DIR}/version"
  log "Wrote ${INSTALL_META_DIR}/install.meta"
}

link_home_project() {
  # Ensure GROKHUNTER_HOME points at this tree
  if [[ "$ROOT" != "${HOME}/GrokHunter" && ! -e "${HOME}/GrokHunter" ]]; then
    ln -s "$ROOT" "${HOME}/GrokHunter" && log "Symlinked ~/GrokHunter → $ROOT" || true
  fi
}

main() {
  banner
  need_cmd curl
  need_cmd python3
  detect_env
  ensure_dirs
  ensure_grok
  install_bins
  install_skills
  merge_config
  inject_shell
  install_motd
  copy_agents
  link_home_project
  write_meta

  # secrets template hint
  if [[ ! -f "${GROK_HOME}/secrets.env" ]]; then
    cp "${ROOT}/templates/secrets.env.example" "${GROK_HOME}/secrets.env.example"
    info "No secrets.env yet — copy example: cp ~/.grok/secrets.env.example ~/.grok/secrets.env"
  fi

  echo
  log "GrokHunter v${VERSION} installed"
  echo
  export PATH="${GROK_HOME}/bin:${BIN_DIR}:${PATH}"
  "${BIN_DIR}/grokhunter" status || true
  echo
  info "Open a new shell (or: source ~/.zshrc) then run:"
  echo "    grokhunter doctor"
  echo "    grokhunter"
  echo
  if [[ -z "${XAI_API_KEY:-}" && ! -r "${GROK_HOME}/secrets.env" ]]; then
    warn "Set XAI_API_KEY for headless/mobile auth:"
    echo "    printf 'export XAI_API_KEY=%q\\n' 'xai-...' > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env"
  fi
}

main "$@"

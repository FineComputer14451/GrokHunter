#!/usr/bin/env bash
# Grok Build Connect — one-shot bootstrap (Termux or desktop).
#   curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/grok-build-connect/scripts/bootstrap.sh | bash -s -- --tunnel
set -euo pipefail

REPO_URL="${GROKHUNTER_REPO_URL:-https://github.com/FineComputer14451/GrokHunter.git}"
BRANCH="${GROKHUNTER_BRANCH:-main}"
TARGET_DIR="${GROKHUNTER_DIR:-$HOME/GrokHunter}"
START_MCP=1
START_TUNNEL=0
START_FOREGROUND=0
REGISTER_MARKETPLACE=1
PORT="${GROK_BUILD_CONNECT_PORT:-8766}"

usage() {
  cat <<'U'
GrokHunter Grok Build Connect bootstrap (Termux + desktop)

Options:
  --dir PATH        Clone/update location (default: ~/GrokHunter)
  --tunnel          Also start Cloudflare quick tunnel (tmux session: gbc-tun)
  --no-start        Do not auto-start MCP in tmux
  --start           Start MCP in the foreground (blocks; skips tmux)
  --no-marketplace  Skip grok plugin marketplace add
  -h, --help        Show help

Env:
  GROKHUNTER_DIR, GROKHUNTER_REPO_URL, GROKHUNTER_BRANCH, GROK_BUILD_CONNECT_PORT
U
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) TARGET_DIR="$2"; shift 2 ;;
    --tunnel) START_TUNNEL=1; shift ;;
    --no-start) START_MCP=0; shift ;;
    --start) START_FOREGROUND=1; START_MCP=0; shift ;;
    --no-marketplace) REGISTER_MARKETPLACE=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }
}
need git
need python3
need bash

SCRIPTS=""
resolve_scripts() {
  if [[ -f "$TARGET_DIR/skills/grok-build-connect/scripts/install.sh" ]]; then
    SCRIPTS="$TARGET_DIR/skills/grok-build-connect/scripts"
  elif [[ -f "$TARGET_DIR/plugins/grokhunter-grok-build-connect/skills/grok-build-connect/scripts/install.sh" ]]; then
    SCRIPTS="$TARGET_DIR/plugins/grokhunter-grok-build-connect/skills/grok-build-connect/scripts"
  else
    return 1
  fi
}

echo "==> Ensuring GrokHunter at $TARGET_DIR ($BRANCH)"
if [[ -d "$TARGET_DIR/.git" ]]; then
  git -C "$TARGET_DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$TARGET_DIR" checkout -B "$BRANCH" "origin/$BRANCH" 2>/dev/null \
    || { git -C "$TARGET_DIR" checkout "$BRANCH" 2>/dev/null || true; git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH" || true; }
else
  mkdir -p "$(dirname "$TARGET_DIR")"
  if [[ -e "$TARGET_DIR" ]] && [[ ! -d "$TARGET_DIR/.git" ]]; then
    echo "Path exists but is not a git repo: $TARGET_DIR" >&2
    exit 1
  fi
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

if ! resolve_scripts; then
  echo "grok-build-connect scripts not found in $TARGET_DIR" >&2
  exit 1
fi

echo "==> Installing Grok Build Connect MCP"
bash "$SCRIPTS/install.sh"

echo "==> Ensuring cloudflared"
bash "$SCRIPTS/ensure-cloudflared.sh" || echo "WARN: cloudflared ensure failed" >&2

if [[ "$REGISTER_MARKETPLACE" -eq 1 ]] && command -v grok >/dev/null 2>&1; then
  grok plugin marketplace add FineComputer14451/GrokHunter 2>/dev/null || true
  grok plugin install grokhunter-grok-build-connect --trust 2>/dev/null \
    || grok plugin install "$TARGET_DIR/plugins/grokhunter-grok-build-connect" --trust 2>/dev/null \
    || echo "WARN: plugin install skipped" >&2
fi

PREFIX_DIR="${GROK_BUILD_CONNECT_HOME:-$HOME/.grokhunter-grok-build-connect}"

if [[ "$START_FOREGROUND" -eq 1 ]]; then
  exec "$PREFIX_DIR/start.sh"
fi

if [[ "$START_MCP" -eq 1 ]]; then
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux missing — start manually: $PREFIX_DIR/start.sh" >&2
  else
    tmux has-session -t gbc 2>/dev/null && tmux kill-session -t gbc
    echo "==> Starting MCP in tmux session 'gbc'"
    tmux new-session -d -s gbc "$PREFIX_DIR/start.sh"
    for i in $(seq 1 20); do
      curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null 2>&1 && break
      sleep 0.5
    done
    if curl -fsS "http://127.0.0.1:${PORT}/healthz"; then
      echo
      echo "MCP healthy on :$PORT"
    else
      echo "WARN: MCP healthz not ready — tmux attach -t gbc" >&2
    fi
  fi
fi

if [[ "$START_TUNNEL" -eq 1 ]]; then
  if ! curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null 2>&1; then
    echo "Cannot start tunnel — MCP unhealthy" >&2
    exit 1
  fi
  if command -v tmux >/dev/null 2>&1; then
    tmux has-session -t gbc-tun 2>/dev/null && tmux kill-session -t gbc-tun
    echo "==> Starting Cloudflare tunnel in tmux session 'gbc-tun'"
    tmux new-session -d -s gbc-tun "bash '$SCRIPTS/tunnel-cloudflare.sh'"
    echo "Attach: tmux attach -t gbc-tun"
  else
    exec bash "$SCRIPTS/tunnel-cloudflare.sh"
  fi
fi

cat <<EOF

Done.
  MCP:     $PREFIX_DIR/start.sh   (tmux: gbc)
  Tunnel:  bash $SCRIPTS/tunnel-cloudflare.sh   (tmux: gbc-tun)
  Health:  curl -s http://127.0.0.1:${PORT}/healthz
  URL:     https://<tunnel-host>/mcp
  Token:   $PREFIX_DIR/token  (do not paste into chat)
EOF

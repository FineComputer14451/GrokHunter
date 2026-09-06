#!/usr/bin/env bash
# GrokHunter Termux Connect — one-shot bootstrap.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/termux-connect/scripts/bootstrap.sh | bash
#   bash bootstrap.sh [--tunnel] [--dir ~/GrokHunter] [--no-start]
set -euo pipefail

REPO_URL="${GROKHUNTER_REPO_URL:-https://github.com/FineComputer14451/GrokHunter.git}"
BRANCH="${GROKHUNTER_BRANCH:-main}"
TARGET_DIR="${GROKHUNTER_DIR:-$HOME/GrokHunter}"
START_MCP=1
START_TUNNEL=0
START_FOREGROUND=0
REGISTER_MARKETPLACE=1
PORT="${TERMUX_CONNECT_PORT:-8765}"

usage() {
  cat <<'U'
GrokHunter Termux Connect bootstrap

Options:
  --dir PATH        Clone/update location (default: ~/GrokHunter)
  --tunnel          Also start Cloudflare quick tunnel (tmux session: tun)
  --no-start        Do not auto-start MCP in tmux
  --start           Start MCP in the foreground (blocks; skips tmux)
  --no-marketplace  Skip grok plugin marketplace add
  -h, --help        Show help

Env:
  GROKHUNTER_DIR, GROKHUNTER_REPO_URL, GROKHUNTER_BRANCH, TERMUX_CONNECT_PORT
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
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing dependency: $1" >&2
    exit 1
  }
}

need git
need python3
need bash

SCRIPTS=""
resolve_scripts() {
  if [[ -f "$TARGET_DIR/skills/termux-connect/scripts/install.sh" ]]; then
    SCRIPTS="$TARGET_DIR/skills/termux-connect/scripts"
  elif [[ -f "$TARGET_DIR/plugins/grokhunter-termux-connect/skills/termux-connect/scripts/install.sh" ]]; then
    SCRIPTS="$TARGET_DIR/plugins/grokhunter-termux-connect/skills/termux-connect/scripts"
  else
    return 1
  fi
}

echo "==> Ensuring GrokHunter at $TARGET_DIR ($BRANCH)"

if [[ -d "$TARGET_DIR/.git" ]]; then
  git -C "$TARGET_DIR" fetch --depth 1 origin "$BRANCH"
  if git -C "$TARGET_DIR" rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
    git -C "$TARGET_DIR" checkout -B "$BRANCH" "origin/$BRANCH"
  else
    git -C "$TARGET_DIR" checkout "$BRANCH" 2>/dev/null || git -C "$TARGET_DIR" checkout -b "$BRANCH" "origin/$BRANCH"
    git -C "$TARGET_DIR" pull --ff-only origin "$BRANCH" || true
  fi
else
  mkdir -p "$(dirname "$TARGET_DIR")"
  if [[ -e "$TARGET_DIR" ]] && [[ ! -d "$TARGET_DIR/.git" ]]; then
    echo "Path exists but is not a git repo: $TARGET_DIR" >&2
    echo "Move it aside or pass --dir ~/GrokHunter-new" >&2
    exit 1
  fi
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

if ! resolve_scripts; then
  echo "termux-connect scripts not found in $TARGET_DIR" >&2
  echo "Is this an old checkout? Try: rm -rf $TARGET_DIR && re-run bootstrap." >&2
  exit 1
fi

echo "==> Installing Termux Connect MCP"
bash "$SCRIPTS/install.sh"

echo "==> Ensuring cloudflared"
bash "$SCRIPTS/ensure-cloudflared.sh" || {
  echo "WARN: cloudflared ensure failed — tunnel step may need a manual install" >&2
}

# tmux for background MCP
if ! command -v tmux >/dev/null 2>&1; then
  if command -v pkg >/dev/null 2>&1; then
    echo "==> Installing tmux"
    pkg install -y tmux || true
  fi
fi

if [[ "$REGISTER_MARKETPLACE" -eq 1 ]] && command -v grok >/dev/null 2>&1; then
  echo "==> Registering GrokHunter marketplace (best-effort)"
  grok plugin marketplace add FineComputer14451/GrokHunter 2>/dev/null \
    || grok plugin marketplace add "$REPO_URL" 2>/dev/null \
    || true
  grok plugin install grokhunter-termux-connect --trust 2>/dev/null \
    || grok plugin install "$TARGET_DIR/plugins/grokhunter-termux-connect" --trust 2>/dev/null \
    || true
fi

PREFIX_DIR="${TERMUX_CONNECT_HOME:-$HOME/.grokhunter-termux-connect}"

health() {
  curl -fsS "http://127.0.0.1:${PORT}/healthz" 2>/dev/null || return 1
}

start_mcp_tmux() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux missing — start manually: $PREFIX_DIR/start.sh" >&2
    return 1
  fi
  if health >/dev/null; then
    echo "==> MCP already healthy on :$PORT"
    return 0
  fi
  tmux has-session -t tc 2>/dev/null && tmux kill-session -t tc 2>/dev/null || true
  echo "==> Starting MCP in tmux session 'tc'"
  tmux new-session -d -s tc "$PREFIX_DIR/start.sh"
  for i in $(seq 1 30); do
    if health >/dev/null; then
      echo "==> Health OK: $(health)"
      return 0
    fi
    sleep 1
  done
  echo "MCP did not become healthy — attach to see logs:" >&2
  echo "  tmux attach -t tc" >&2
  return 1
}

if [[ "$START_FOREGROUND" -eq 1 ]]; then
  echo "==> Starting MCP server (Ctrl-C to stop)"
  exec "$PREFIX_DIR/start.sh"
fi

if [[ "$START_MCP" -eq 1 ]]; then
  start_mcp_tmux || true
fi

if [[ "$START_TUNNEL" -eq 1 ]]; then
  if ! health >/dev/null; then
    echo "Cannot start tunnel — MCP unhealthy" >&2
    exit 1
  fi
  if command -v tmux >/dev/null 2>&1; then
    tmux has-session -t tun 2>/dev/null && tmux kill-session -t tun 2>/dev/null || true
    echo "==> Starting Cloudflare tunnel in tmux session 'tun'"
    echo "    Attach to copy the https URL: tmux attach -t tun"
    tmux new-session -d -s tun "bash '$SCRIPTS/tunnel-cloudflare.sh'"
  else
    echo "==> Starting Cloudflare tunnel (foreground)"
    exec bash "$SCRIPTS/tunnel-cloudflare.sh"
  fi
fi

cat <<MSG

==> Termux Connect status
  Repo:    $TARGET_DIR
  MCP:     $PREFIX_DIR/start.sh
  Port:    $PORT
  Health:  $(health || echo 'NOT UP — tmux attach -t tc')
  Token:   $PREFIX_DIR/token  (mode 600 — do NOT paste into chat)

Next:
  tmux attach -t tc     # MCP logs
  bash $SCRIPTS/tunnel-cloudflare.sh
  # or re-run: bash $SCRIPTS/bootstrap.sh --tunnel

Grok Bot → Plugins → custom connector:
  URL:  https://<tunnel-host>/mcp
  Auth: Bearer <token from file above>

MSG

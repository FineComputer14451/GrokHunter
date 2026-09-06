#!/usr/bin/env bash
# GrokHunter Termux Connect — one-shot bootstrap (clone/update + MCP install).
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/termux-connect/scripts/bootstrap.sh | bash
#   bash bootstrap.sh [--start] [--dir ~/GrokHunter]
set -euo pipefail

REPO_URL="${GROKHUNTER_REPO_URL:-https://github.com/FineComputer14451/GrokHunter.git}"
BRANCH="${GROKHUNTER_BRANCH:-main}"
TARGET_DIR="${GROKHUNTER_DIR:-$HOME/GrokHunter}"
START=0
REGISTER_MARKETPLACE=1

usage() {
  cat <<'U'
GrokHunter Termux Connect bootstrap

Options:
  --dir PATH     Clone/update location (default: ~/GrokHunter)
  --start        After install, start the MCP server in the foreground
  --no-marketplace  Skip `grok plugin marketplace add`
  -h, --help     Show help

Env:
  GROKHUNTER_DIR, GROKHUNTER_REPO_URL, GROKHUNTER_BRANCH
U
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) TARGET_DIR="$2"; shift 2 ;;
    --start) START=1; shift ;;
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

echo "==> Ensuring GrokHunter at $TARGET_DIR ($BRANCH)"

if [[ -d "$TARGET_DIR/.git" ]]; then
  git -C "$TARGET_DIR" fetch --depth 1 origin "$BRANCH"
  # prefer updating current checkout to origin/BRANCH
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

INSTALL_SH="$TARGET_DIR/skills/termux-connect/scripts/install.sh"
if [[ ! -f "$INSTALL_SH" ]]; then
  # plugin layout fallback
  INSTALL_SH="$TARGET_DIR/plugins/grokhunter-termux-connect/skills/termux-connect/scripts/install.sh"
fi
if [[ ! -f "$INSTALL_SH" ]]; then
  echo "termux-connect install.sh not found in $TARGET_DIR" >&2
  echo "Is this an old checkout? Try: rm -rf $TARGET_DIR && re-run bootstrap." >&2
  exit 1
fi

echo "==> Installing Termux Connect MCP"
bash "$INSTALL_SH"

if [[ "$REGISTER_MARKETPLACE" -eq 1 ]] && command -v grok >/dev/null 2>&1; then
  echo "==> Registering GrokHunter marketplace (best-effort)"
  grok plugin marketplace add FineComputer14451/GrokHunter 2>/dev/null \
    || grok plugin marketplace add "$REPO_URL" 2>/dev/null \
    || echo "(marketplace add skipped — run manually if needed)"
  grok plugin install grokhunter-termux-connect --trust 2>/dev/null \
    || grok plugin install "$TARGET_DIR/plugins/grokhunter-termux-connect" --trust 2>/dev/null \
    || echo "(plugin install via grok skipped — scripts install already done)"
elif [[ "$REGISTER_MARKETPLACE" -eq 1 ]]; then
  echo "(grok CLI not on PATH — skipped marketplace register)"
fi

PREFIX_DIR="${TERMUX_CONNECT_HOME:-$HOME/.grokhunter-termux-connect}"
TUNNEL_CF="$TARGET_DIR/skills/termux-connect/scripts/tunnel-cloudflare.sh"
[[ -f "$TUNNEL_CF" ]] || TUNNEL_CF="$TARGET_DIR/plugins/grokhunter-termux-connect/skills/termux-connect/scripts/tunnel-cloudflare.sh"

cat <<MSG

==> Termux Connect ready

Start MCP (tmux recommended):
  tmux new -s tc '$PREFIX_DIR/start.sh'

Tunnel (other pane):
  bash $TUNNEL_CF

Then in Grok Bot → Plugins → Add custom connector:
  URL:  https://<tunnel-host>/mcp
  Auth: Bearer  (token file: $PREFIX_DIR/token — do NOT paste into chat)

Health check:
  curl -s http://127.0.0.1:8765/healthz

MSG

if [[ "$START" -eq 1 ]]; then
  echo "==> Starting MCP server (Ctrl-C to stop)"
  exec "$PREFIX_DIR/start.sh"
fi

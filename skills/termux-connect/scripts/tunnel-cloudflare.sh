#!/usr/bin/env bash
# Cloudflare quick tunnel (ephemeral hostname) in front of local MCP.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PORT="${TERMUX_CONNECT_PORT:-8765}"

ensure_log="$(mktemp)"
bash "$ROOT/ensure-cloudflared.sh" | tee "$ensure_log"
CF=""
if command -v cloudflared >/dev/null 2>&1; then
  CF="$(command -v cloudflared)"
elif [[ -x "$HOME/.grokhunter-termux-connect/bin/cloudflared" ]]; then
  CF="$HOME/.grokhunter-termux-connect/bin/cloudflared"
else
  CF="$(grep '^CF_BIN=' "$ensure_log" | tail -n1 | cut -d= -f2- || true)"
fi
rm -f "$ensure_log"

if [[ -z "${CF:-}" || ! -x "$CF" ]]; then
  echo "cloudflared still missing" >&2
  exit 1
fi

for i in $(seq 1 15); do
  if curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done
if ! curl -fsS "http://127.0.0.1:${PORT}/healthz" >/dev/null 2>&1; then
  echo "MCP not healthy on :${PORT} — start it first (tmux attach -t tc)" >&2
  exit 1
fi

echo "Starting quick tunnel → http://127.0.0.1:${PORT}"
echo "Copy the https://….trycloudflare.com URL, append /mcp"
echo "Bearer token file: ~/.grokhunter-termux-connect/token (do not paste into chat)"
exec "$CF" tunnel --url "http://127.0.0.1:${PORT}"

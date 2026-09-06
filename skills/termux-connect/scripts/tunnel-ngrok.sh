#!/usr/bin/env bash
# ngrok tunnel (ephemeral unless you have a reserved domain).
set -euo pipefail
PORT="${TERMUX_CONNECT_PORT:-8765}"
if ! command -v ngrok >/dev/null 2>&1; then
  echo "Install ngrok (https://ngrok.com) or use tunnel-cloudflare.sh"
  exit 1
fi
echo "Starting ngrok → http://127.0.0.1:${PORT}"
echo "Copy the https URL, append /mcp, Bearer token from ~/.grokhunter-termux-connect/token"
exec ngrok http "$PORT"

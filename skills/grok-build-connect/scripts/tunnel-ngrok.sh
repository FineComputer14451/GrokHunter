#!/usr/bin/env bash
set -euo pipefail
PORT="${GROK_BUILD_CONNECT_PORT:-8766}"
if ! command -v ngrok >/dev/null 2>&1; then
  echo "Install ngrok or use tunnel-cloudflare.sh"
  exit 1
fi
echo "Starting ngrok → http://127.0.0.1:${PORT}"
echo "Copy the https URL, append /mcp, Bearer from ~/.grokhunter-grok-build-connect/token"
exec ngrok http "$PORT"

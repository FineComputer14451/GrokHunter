#!/usr/bin/env bash
# Cloudflare quick tunnel (ephemeral hostname) in front of local MCP.
set -euo pipefail
PORT="${TERMUX_CONNECT_PORT:-8765}"
if ! command -v cloudflared >/dev/null 2>&1; then
  echo "Install cloudflared first (Termux: check avail / github.com/cloudflare/cloudflared releases)."
  echo "For a stable hostname, create a named tunnel on your Cloudflare account instead."
  exit 1
fi
echo "Starting quick tunnel → http://127.0.0.1:${PORT}"
echo "Copy the https://….trycloudflare.com URL, append /mcp, use Bearer token from ~/.grokhunter-termux-connect/token"
exec cloudflared tunnel --url "http://127.0.0.1:${PORT}"

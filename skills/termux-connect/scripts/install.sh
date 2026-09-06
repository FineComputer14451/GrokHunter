#!/usr/bin/env bash
# Install GrokHunter Termux Connect MCP into a user venv (Termux / proot / desktop).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PREFIX_DIR="${TERMUX_CONNECT_HOME:-$HOME/.grokhunter-termux-connect}"
VENV="$PREFIX_DIR/venv"
TOKEN_FILE="$PREFIX_DIR/token"
ENV_FILE="$PREFIX_DIR/env"

mkdir -p "$PREFIX_DIR"
python3 -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -U pip
pip install -r "$ROOT/requirements.txt"
cp -f "$ROOT/server.py" "$PREFIX_DIR/server.py"
chmod +x "$PREFIX_DIR/server.py"

if [[ ! -f "$TOKEN_FILE" ]]; then
  python3 -c 'import secrets; print(secrets.token_urlsafe(32))' >"$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
fi
TOKEN="$(cat "$TOKEN_FILE")"

cat >"$ENV_FILE" <<EOF
# sourced by start.sh — do not commit
export TERMUX_CONNECT_TOKEN='$TOKEN'
export TERMUX_CONNECT_HOST='127.0.0.1'
export TERMUX_CONNECT_PORT='8765'
export TERMUX_CONNECT_SHELL='allowlist'
EOF
chmod 600 "$ENV_FILE"

cat >"$PREFIX_DIR/start.sh" <<'EOS'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$DIR/venv/bin/activate"
# shellcheck disable=SC1091
source "$DIR/env"
exec python3 "$DIR/server.py"
EOS
chmod +x "$PREFIX_DIR/start.sh"

cat >"$PREFIX_DIR/print-connector.txt" <<EOF
Grok Bot → Settings → Plugins → Add custom connector
  URL:  https://<YOUR-TUNNEL-HOST>/mcp
  Auth: Bearer (paste token from $TOKEN_FILE — never chat it)

Start server:  $PREFIX_DIR/start.sh
Tunnel:        bash $(dirname "$0")/tunnel-cloudflare.sh   # or tunnel-ngrok.sh
Health:        curl -s http://127.0.0.1:8765/healthz
EOF

echo "Installed → $PREFIX_DIR"
echo "Token file (mode 600): $TOKEN_FILE"
echo "Start: $PREFIX_DIR/start.sh"
echo "Then expose with tunnel-*.sh and register the HTTPS URL in Grok Bot Plugins."

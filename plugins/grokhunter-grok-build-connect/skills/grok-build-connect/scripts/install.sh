#!/usr/bin/env bash
# Install Grok Build Connect MCP (Termux or desktop).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PREFIX_DIR="${GROK_BUILD_CONNECT_HOME:-$HOME/.grokhunter-grok-build-connect}"
VENV="$PREFIX_DIR/venv"
TOKEN_FILE="$PREFIX_DIR/token"
ENV_FILE="$PREFIX_DIR/env"
PORT="${GROK_BUILD_CONNECT_PORT:-8766}"

mkdir -p "$PREFIX_DIR"
python3 -m venv "$VENV"
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -U pip
pip install -r "$ROOT/requirements.txt"
cp -f "$ROOT/server.py" "$PREFIX_DIR/server.py"
chmod +x "$PREFIX_DIR/server.py"

if [[ ! -f "$TOKEN_FILE" ]] || [[ "$(wc -c <"$TOKEN_FILE" | tr -d ' ')" -lt 24 ]]; then
  python3 -c 'import secrets; print(secrets.token_urlsafe(32))' >"$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"
fi
TOKEN="$(tr -d '[:space:]' <"$TOKEN_FILE")"

cat >"$ENV_FILE" <<EOF
# sourced by start.sh — do not commit
export GROK_BUILD_CONNECT_TOKEN='$TOKEN'
export GROK_BUILD_CONNECT_HOST='127.0.0.1'
export GROK_BUILD_CONNECT_PORT='$PORT'
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
if ! command -v grok >/dev/null 2>&1; then
  echo "WARN: grok not on PATH — install Grok Build before using ask/plugin tools" >&2
fi
exec python3 "$DIR/server.py"
EOS
chmod +x "$PREFIX_DIR/start.sh"

cat >"$PREFIX_DIR/print-connector.txt" <<EOF
Grok Bot → Add custom connector (or ask GrokHunter in chat)
  URL:  https://<YOUR-TUNNEL-HOST>/mcp
  Auth: Bearer (from $TOKEN_FILE — never chat it)
  Port: $PORT (default; Termux Connect uses 8765)

Start:   $PREFIX_DIR/start.sh
Tunnel:  bash $ROOT/tunnel-cloudflare.sh
Health:  curl -s http://127.0.0.1:${PORT}/healthz
EOF

echo "Installed → $PREFIX_DIR"
echo "Token file (mode 600): $TOKEN_FILE"
echo "Start: $PREFIX_DIR/start.sh"
echo "Works on Termux and desktop. Expose with tunnel-*.sh, register HTTPS URL in Grok Bot."

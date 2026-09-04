#!/usr/bin/env bash
# Rootless Tookie-OSINT CLI for GrokHunter (no sudo).
# Upstream: https://github.com/Alfredredbird/tookie-osint (MIT)
# Does not vendor brib.py. Scoped OSINT only.
set -euo pipefail

DEST="${GROKHUNTER_TOOKIE_HOME:-${HOME}/.grok/tools/tookie-osint}"
BIN_DIR="${HOME}/.local/bin"
UPSTREAM="https://github.com/Alfredredbird/tookie-osint.git"

echo "Tookie-OSINT → ${DEST}"

if [[ ! -f "${DEST}/brib.py" ]]; then
  mkdir -p "$(dirname "${DEST}")"
  git clone --depth 1 "${UPSTREAM}" "${DEST}"
fi

if [[ ! -x "${DEST}/venv/bin/python" ]]; then
  python3 -m venv "${DEST}/venv"
fi

"${DEST}/venv/bin/pip" install --index-url https://pypi.org/simple \
  --upgrade-strategy only-if-needed \
  -r "${DEST}/requirements.txt"

mkdir -p "${BIN_DIR}"
cat > "${BIN_DIR}/tookie-osint" <<EOF
#!/usr/bin/env sh
exec "${DEST}/venv/bin/python" "${DEST}/brib.py" "\$@"
EOF
chmod +x "${BIN_DIR}/tookie-osint"

echo "Installed CLI: ${BIN_DIR}/tookie-osint"
"${BIN_DIR}/tookie-osint" -h | head -20
echo
echo "Agent: grok --agent tookie   or   tookie -p 'authorized username check HANDLE'"
echo "Keep PATH: ${BIN_DIR}"

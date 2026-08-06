#!/usr/bin/env bash
# SpaceXAI (xAI) API smoke test — Responses API with grok-4.5
# Usage:
#   bash scripts/spacexai_smoke.sh
#   bash scripts/spacexai_smoke.sh "your prompt"
#
# Requires XAI_API_KEY (env or ~/.grok/secrets.env). Never prints the key.
set -euo pipefail

info() { echo "[spacexai_smoke] $*"; }
die()  { echo "[spacexai_smoke] ERROR: $*" >&2; exit 1; }

if [[ -z "${XAI_API_KEY:-}" && -r "${HOME}/.grok/secrets.env" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/.grok/secrets.env"
fi

if [[ -z "${XAI_API_KEY:-}" ]]; then
  die "XAI_API_KEY not set. Create a key at https://console.x.ai then:
  printf 'export XAI_API_KEY=%q\\n' \"xai-...\" > ~/.grok/secrets.env && chmod 600 ~/.grok/secrets.env"
fi

MODEL="${SPACEXAI_MODEL:-${AIDER_MODEL:-grok-4.5}}"
BASE="${OPENAI_API_BASE:-https://api.x.ai/v1}"
PROMPT="${1:-Say hello from GrokHunter in one short sentence.}"

command -v curl >/dev/null 2>&1 || die "curl required"
command -v python3 >/dev/null 2>&1 || die "python3 required (JSON parse)"

info "POST ${BASE}/responses  model=${MODEL}"
# Body via python so the prompt is safely JSON-escaped
BODY="$(PROMPT="$PROMPT" MODEL="$MODEL" python3 - <<'PY'
import json, os
print(json.dumps({"model": os.environ["MODEL"], "input": os.environ["PROMPT"]}))
PY
)"

HTTP_CODE=0
RESP_FILE="$(mktemp)"
trap 'rm -f "${RESP_FILE}"' EXIT

set +e
HTTP_CODE=$(curl -sS -o "${RESP_FILE}" -w '%{http_code}' \
  --connect-timeout 15 --max-time 90 \
  -X POST "${BASE}/responses" \
  -H "Authorization: Bearer ${XAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "${BODY}")
CURL_RC=$?
set -e

if [[ "${CURL_RC}" -ne 0 ]]; then
  die "curl failed (rc=${CURL_RC}) — network / DNS?"
fi

if [[ "${HTTP_CODE}" != "200" ]]; then
  ERR_SNIP="$(python3 - <<PY
import json, pathlib
raw = pathlib.Path("${RESP_FILE}").read_text(errors="replace")
try:
    d = json.loads(raw)
    msg = d.get("error", d)
    if isinstance(msg, dict):
        print(msg.get("message") or msg.get("type") or str(msg)[:240])
    else:
        print(str(msg)[:240])
except Exception:
    print(raw[:240].replace("\\n", " "))
PY
)"
  die "HTTP ${HTTP_CODE}: ${ERR_SNIP}"
fi

TEXT="$(python3 - <<PY
import json, pathlib
d = json.loads(pathlib.Path("${RESP_FILE}").read_text())
if d.get("output_text"):
    print(d["output_text"])
    raise SystemExit(0)
parts = []
for item in d.get("output") or []:
    if item.get("type") == "message":
        for c in item.get("content") or []:
            if c.get("type") in ("output_text", "text") and c.get("text"):
                parts.append(c["text"])
    elif item.get("type") == "output_text" and item.get("text"):
        parts.append(item["text"])
print("".join(parts) if parts else json.dumps(d)[:400])
PY
)"

info "OK (HTTP ${HTTP_CODE})"
printf '%s\n' "${TEXT}"

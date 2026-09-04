#!/usr/bin/env bash
# Print the best Tookie-OSINT invoke command for this host.
set -euo pipefail

OFFICIAL="${GROKHUNTER_HOME:-$HOME/GrokHunter}/bin/tookie-osint"
if [[ -x "$OFFICIAL" ]]; then
  echo "$OFFICIAL"
  exit 0
fi

if command -v tookie-osint >/dev/null 2>&1; then
  echo "tookie-osint"
  exit 0
fi

SEARCH_ROOTS=()
[[ -n "${HOME:-}" ]] && SEARCH_ROOTS+=("$HOME")
[[ -d /home/workdir ]] && SEARCH_ROOTS+=("/home/workdir")
[[ -d "$PWD" ]] && SEARCH_ROOTS+=("$PWD")

for root in "${SEARCH_ROOTS[@]}"; do
  found="$(find "$root" -maxdepth 4 -name brib.py -type f 2>/dev/null | head -n 1 || true)"
  if [[ -n "$found" ]]; then
    dir="$(dirname "$found")"
    if [[ -x "$dir/venv/bin/python" ]]; then
      echo "$dir/venv/bin/python $found"
      exit 0
    fi
    if [[ -x "$dir/.venv/bin/python" ]]; then
      echo "$dir/.venv/bin/python $found"
      exit 0
    fi
    echo "python3 $found"
    exit 0
  fi
done

echo "MISSING" >&2
exit 1

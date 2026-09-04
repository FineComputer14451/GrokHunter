#!/usr/bin/env bash
# Accept a single public handle. Reject path traversal and junk.
# Usage: safe-username.sh HANDLE
set -euo pipefail

u="${1:-}"
if [[ -z "$u" ]]; then
  echo "usage: safe-username.sh HANDLE" >&2
  exit 2
fi

if [[ "$u" == *"/"* || "$u" == *"\\"* || "$u" == *".."* ]]; then
  echo "rejected: path characters in username" >&2
  exit 1
fi

if [[ "$u" =~ [[:space:][:cntrl:]] ]]; then
  echo "rejected: whitespace or control characters" >&2
  exit 1
fi

u="${u#@}"
if [[ ! "$u" =~ ^[A-Za-z0-9._-]{1,64}$ ]]; then
  echo "rejected: use 1-64 of A-Z a-z 0-9 . _ -" >&2
  exit 1
fi

printf '%s\n' "$u"

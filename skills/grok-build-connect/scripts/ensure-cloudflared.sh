#!/usr/bin/env bash
# Ensure cloudflared is on PATH (Termux pkg or GitHub release binary).
set -euo pipefail

if command -v cloudflared >/dev/null 2>&1; then
  echo "cloudflared: $(command -v cloudflared)"
  exit 0
fi

BIN_DIR="${TERMUX_CONNECT_BIN:-$HOME/.grokhunter-termux-connect/bin}"
mkdir -p "$BIN_DIR"
TARGET="$BIN_DIR/cloudflared"

if command -v pkg >/dev/null 2>&1; then
  echo "==> Trying: pkg install cloudflared"
  if pkg install -y cloudflared 2>/dev/null; then
    if command -v cloudflared >/dev/null 2>&1; then
      echo "cloudflared: $(command -v cloudflared)"
      exit 0
    fi
  fi
fi

arch="$(uname -m)"
case "$arch" in
  aarch64|arm64) asset="cloudflared-linux-arm64" ;;
  armv7l|armv8l|arm) asset="cloudflared-linux-arm" ;;
  x86_64|amd64) asset="cloudflared-linux-amd64" ;;
  i686|i386) asset="cloudflared-linux-386" ;;
  *)
    echo "Unsupported arch for cloudflared binary: $arch" >&2
    echo "Install manually: https://github.com/cloudflare/cloudflared/releases" >&2
    exit 1
    ;;
esac

url="https://github.com/cloudflare/cloudflared/releases/latest/download/${asset}"
echo "==> Downloading $url"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL -o "$TARGET" "$url"
elif command -v wget >/dev/null 2>&1; then
  wget -q -O "$TARGET" "$url"
else
  echo "Need curl or wget to fetch cloudflared" >&2
  exit 1
fi
chmod +x "$TARGET"

# prepend bin dir for this shell / recommend PATH
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) export PATH="$BIN_DIR:$PATH" ;;
esac

# persist hint
profile_snip="$HOME/.grokhunter-termux-connect/path.sh"
cat >"$profile_snip" <<P
# added by termux-connect ensure-cloudflared
export PATH="$BIN_DIR:\$PATH"
P
if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'grokhunter-termux-connect/path.sh' "$HOME/.bashrc" 2>/dev/null; then
  echo "[ -f \"$profile_snip\" ] && . \"$profile_snip\"" >>"$HOME/.bashrc"
fi

if ! command -v cloudflared >/dev/null 2>&1; then
  echo "Installed to $TARGET — add to PATH: export PATH=\"$BIN_DIR:\$PATH\"" >&2
  # still usable via absolute path; create shim if ~/bin exists
fi
echo "cloudflared: $TARGET"
echo "CF_BIN=$TARGET"

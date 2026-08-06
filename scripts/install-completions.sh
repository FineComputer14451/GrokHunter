#!/usr/bin/env bash
# Install GrokHunter shell completions (zsh + bash) into ~/.grok/completions
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
DEST_ZSH="${HOME}/.grok/completions/zsh"
DEST_BASH="${HOME}/.grok/completions/bash"

die() { echo "[install-completions] ERROR: $*" >&2; exit 1; }
info() { echo "[install-completions] $*"; }

mkdir -p "$DEST_ZSH" "$DEST_BASH"

[[ -f "$ROOT/config/completions/zsh/_grokhunter" ]] || die "missing config/completions/zsh/_grokhunter"
cp -f "$ROOT/config/completions/zsh/_grokhunter" "$DEST_ZSH/"
info "Installed zsh: $DEST_ZSH/_grokhunter"

if [[ -f "$ROOT/config/completions/zsh/_nh-x11" ]]; then
  cp -f "$ROOT/config/completions/zsh/_nh-x11" "$DEST_ZSH/"
  info "Installed zsh: $DEST_ZSH/_nh-x11"
fi

if [[ -f "$ROOT/config/completions/bash/grokhunter.bash" ]]; then
  cp -f "$ROOT/config/completions/bash/grokhunter.bash" "$DEST_BASH/"
  info "Installed bash: $DEST_BASH/grokhunter.bash"
fi

PROFILE_SRC="$ROOT/config/profile.d/grokhunter.sh"
PROFILE_DST="${HOME}/.grok/profile.sh"
if [[ -f "$PROFILE_SRC" ]]; then
  cp -f "$PROFILE_SRC" "$PROFILE_DST"
  info "Profile snippet: $PROFILE_DST"
fi

cat <<'EOF'

Add to ~/.zshrc (if not already):

  [[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
  autoload -Uz compinit && compinit

Or for bash ~/.bashrc:

  [[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh

Then:  source ~/.zshrc   # or open a new shell
EOF

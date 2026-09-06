---
name: editor-lab
description: >-
  Use when the user wants nvim, micro, or Acode on GrokHunter, or an editor
  besides Grok/Aider is missing inside Kali.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/editor-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Editor lab (optional)

You install **human editors** on the phone lab. Pair intelligence stays `grok` / skill `pair-programming`. Git-native pair is skill `aider-grok`. XFCE/X11 is skill `x11-desktop`.

## When to activate

- `nvim` / `micro` missing inside `nethunter`
- User wants a keyboard editor beside Grok
- Acode / Termux editor questions

## Defaults (Kali guest)

```bash
sudo apt install -y neovim micro
nvim --version | head -1
```

| Tool | When |
|------|------|
| `nvim` / `micro` | Terminal inside Kali |
| `nh-x11` + XFCE | Visual desktop editor |
| Acode (acode.app) | Native Android, beside Termux |

Aider install stays `scripts/install_aider.sh`.

## Common failures

| Symptom | First step |
|---------|------------|
| nvim missing in guest | `sudo apt install -y neovim micro` |
| User wants Aider | skill `aider-grok` |
| XFCE editor black screen | skill `x11-desktop` |

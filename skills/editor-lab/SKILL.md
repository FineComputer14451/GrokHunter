---
name: editor-lab
description: >-
  Terminal and Android editors on GrokHunter: nvim, micro, Acode. Use when the
  user wants a text editor besides Grok/Aider, or nvim is missing inside Kali.
  Optional skill — not part of skills-core N/3.
---

# Editor lab (optional)

You install **human editors** on the phone lab. Pair intelligence stays `grok` / skill `pair-programming`. Git-native pair is skill `aider-grok` / agent `aider`. XFCE/X11 is skill `x11-desktop`.

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
| [Acode](https://acode.app) | Native Android, beside Termux |

Do not copy `docs/EDITORS.md` here. Aider install stays `scripts/install_aider.sh`.

## Common failures

| Symptom | First step |
|---------|------------|
| nvim missing in guest | `sudo apt install -y neovim micro` |
| User wants Aider | skill `aider-grok` |
| XFCE editor black screen | skill `x11-desktop` |

## Verify

```bash
nvim --version | head -1
```

## Cross-links

- Agent `editor`
- Aider: skill `aider-grok`
- Desktop: skill `x11-desktop`
- Apt generally: skill `toolchain`
---

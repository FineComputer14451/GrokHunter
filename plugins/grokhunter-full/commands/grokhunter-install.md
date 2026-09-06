---
name: grokhunter-install
description: Paste-ready Termux install / overlay-only for GrokHunter Rootless
---

Give Termux-only install instructions from F-Droid/GitHub Termux (not Play Store).

Coding-only:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh) --yes
```

Full stack:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh) \
  --full --de xfce --browser chromium \
  --with-grok --with-x11 --with-aider --with-v9-models --with-completions
```

Credit CREDITS.md pillars. Never claim affiliation with xAI/OffSec/Termux/jorexdeveloper.

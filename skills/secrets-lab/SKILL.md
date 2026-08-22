---
name: secrets-lab
description: >-
  GrokHunter secrets and auth: ~/.grok/secrets.env mode 600, XAI_API_KEY,
  grok login vs API key, never print tokens. Use when doctor warns about
  secrets, ai-smoke missing-key, or the user asks where to put the key.
  Optional skill — not part of skills-core N/3.
---

# Secrets lab (optional)

You keep API keys **off the terminal and out of git**. Canonical file: `~/.grok/secrets.env` mode **600**.

## When to activate

- Doctor: secrets missing or mode not 600
- `grokhunter ai-smoke` says key not set
- User asks how to auth Grok on the phone

## Write (never echo the value)

```bash
printf 'export XAI_API_KEY=%q\n' "xai-YOUR_KEY" > ~/.grok/secrets.env
chmod 600 ~/.grok/secrets.env
source ~/.grok/secrets.env
grokhunter ai-smoke
```

Auth can also be SuperGrok / X Premium+ via `grok` (`~/.grok/auth.json`). Do not print `auth.json`.

## Hard rules

- Never log, paste, or commit keys (`XAI_API_KEY`, `GH_TOKEN`, private keys)
- No `SPACEXAI_*` hostnames — API is `https://api.x.ai/v1`
- Profile sources secrets when present (`~/.grok/profile.sh`)

## Cross-links

- Smoke: `grokhunter ai-smoke` / skill `grokhunter`
- GitHub tokens: skill `github-lab` (do not mix into secrets.env unless the user asks)
- MCP env/headers: skill `mcp-lab` — use `${VAR}`, never paste keys into TOML you will print

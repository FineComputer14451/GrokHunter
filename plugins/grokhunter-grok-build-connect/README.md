# grokhunter-grok-build-connect

Bridge **Grok Bot → local Grok Build (`grok` CLI)** via authenticated HTTP MCP + tunnel.
Works on **Termux and desktop**. Not affiliated with xAI / OffSec / Termux / jorexdeveloper.

## Why

Grok Bot’s native Local Computer is Mac/Windows. This plugin exposes your installed
`grok` CLI (phone or desktop) over HTTPS MCP so the Bot can call version/plugins/ask tools.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/grok-build-connect/scripts/bootstrap.sh | bash -s -- --tunnel
```

Default port **8766** (keeps Termux Connect on 8765 free).

## Security

- Listens on `127.0.0.1` only
- Bearer token required (min 24 chars)
- Path jail: `$HOME` (+ `$PREFIX` on Termux)
- Never commit `~/.grokhunter-grok-build-connect/token`

## Credits

See [CREDITS.md](https://github.com/FineComputer14451/GrokHunter/blob/main/CREDITS.md).

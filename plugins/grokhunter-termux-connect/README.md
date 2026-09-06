# grokhunter-termux-connect

Bridge Grok Bot to GrokHunter on Termux via authenticated HTTP MCP + tunnel. Not a native Local Computer (Android unsupported); exposes scoped shell/files/doctor. Not affiliated with xAI / OffSec / Termux / jorexdeveloper.

## Why not native Local Computer?

Grok Bot local execution is **Mac/Windows desktop**. Android/Termux is not a registered `ListMachines` host. This plugin bridges with **HTTP MCP + tunnel**.

## Quick start (Termux)

```bash
curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/termux-connect/scripts/bootstrap.sh | bash
```


```bash
grok plugin marketplace add FineComputer14451/GrokHunter
grok plugin install grokhunter-termux-connect --trust

# or from a checkout:
bash plugins/grokhunter-termux-connect/skills/termux-connect/scripts/install.sh
~/.grokhunter-termux-connect/start.sh
# other pane:
bash plugins/grokhunter-termux-connect/skills/termux-connect/scripts/tunnel-cloudflare.sh
```

Grok Bot → Plugins → custom connector → `https://<tunnel>/mcp` + Bearer token.

## Security

- Listens on `127.0.0.1` only; tunnel is the public edge
- Bearer token required (min 24 chars)
- Path jail: `$HOME` + `$PREFIX`
- Shell allowlist by default
- Never commit `~/.grokhunter-termux-connect/token`

## Credits

Not affiliated with xAI, Offensive Security, Termux, or jorexdeveloper. See [CREDITS.md](https://github.com/FineComputer14451/GrokHunter/blob/main/CREDITS.md).

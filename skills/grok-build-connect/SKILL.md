---
name: grok-build-connect
description: >-
  Use when bridging Grok Bot to the local Grok Build (`grok`) CLI via HTTP MCP +
  Cloudflare/ngrok tunnel on Termux or desktop.
---
# Grok Build Connect (MVP)

Expose the **local `grok` CLI** to Grok Bot through an authenticated **HTTP MCP**
(and a tunnel). Works on **Termux and desktop**. Port default **8766** (Termux
Connect uses 8765).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/grok-build-connect/scripts/bootstrap.sh | bash -s -- --tunnel
```

Or from a checkout:

```bash
bash skills/grok-build-connect/scripts/install.sh
~/.grokhunter-grok-build-connect/start.sh
bash skills/grok-build-connect/scripts/tunnel-cloudflare.sh
```

## Grok Bot connector

1. Add custom connector (chat / desktop / grok.com/connectors)
2. URL: `https://<tunnel-host>/mcp`
3. Auth: Bearer from `~/.grokhunter-grok-build-connect/token` — never paste in chat

## Tools

`grok_version`, `grok_plugin_list`, `grok_mcp_list`, `grok_mcp_doctor`, `grok_ask`, `list_dir`, `read_file`

## Hard rules

- Never print the bearer token or secrets.env
- Not Magisk/root; not native Android Local Computer
- Coding lab only

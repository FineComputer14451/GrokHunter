---
name: termux-connect-tunnel
description: Expose Termux Connect MCP with Cloudflare or ngrok and register in Grok Bot
---

With the MCP server already running on `127.0.0.1:8765`:

```bash
bash plugins/grokhunter-termux-connect/skills/termux-connect/scripts/tunnel-cloudflare.sh
# or: bash …/tunnel-ngrok.sh
```

Register in Grok Bot: Plugins → Add custom connector → `https://<host>/mcp` + Bearer token (secret UI only).

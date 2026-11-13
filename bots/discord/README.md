# GrokHunter Discord Bot

Minimal presence for **The Intelligent Playground** server.

Slash commands + mention replies. Speaks as Coding Team Leader. Knowledge of the GrokHunter agent roster is hardcoded from the repo.

## Setup

1. **Create the bot** (Discord Developer Portal)
   - New Application → Bot → Reset Token (copy once).
   - Privileged Gateway Intents: enable **Message Content Intent**.
   - OAuth2 → URL Generator: scopes `bot` + `applications.commands`.
   - Permissions: Send Messages, Embed Links, Read Message History (minimal).
   - Invite the bot to the server.

2. **Local run**
   ```bash
   cd bots/discord
   python3 -m venv .venv
   source .venv/bin/activate   # or .venv\Scripts\activate on Windows
   pip install -r requirements.txt
   cp .env.example .env
   # edit .env — paste DISCORD_TOKEN (never commit .env)
   # optional: set GUILD_ID for faster slash sync
   python bot.py
   ```

3. **Commands**
   - `/ping` — latency
   - `/status` — version, links, install one-liner
   - `/agents` — Coding Team + lab roster
   - `/credits` — upstream attribution
   - Mention the bot → short help

## Notes

- Token stays in `.env` only. Add `.env` to `.gitignore` if you commit from this tree.
- Slash commands are global by default (up to ~1h to appear). Set `GUILD_ID` for instant guild sync.
- No live lab proxy, no XAI_API_KEY usage, no always-on hosting instructions here.
- Rootless / coding-lab only. Credit stack: jorexdeveloper, Termux, Kali/OffSec, xAI.

Not affiliated with xAI, Offensive Security, Termux, or jorexdeveloper.

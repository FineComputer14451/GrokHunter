---
name: termux-connect
description: >-
  Bridge Grok Bot to GrokHunter on Termux via authenticated HTTP MCP +
  Cloudflare/ngrok tunnel. Use when the user wants the phone lab as a remote
  "local computer", Termux Connect install/tunnel, or custom connector setup.
  Not native ListMachines (Android unsupported).
---

# Termux Connect (MVP)

Grok Bot’s native **Local Computer** is Mac/Windows only. This skill runs an
**HTTP MCP** on the phone and exposes it through a **tunnel** so the Bot can
call scoped tools (`grokhunter_doctor`, files, allowlisted shell).

## When to activate

- User asks to connect Termux / GrokHunter as a local computer
- `/termux-connect-install` or `/termux-connect-tunnel`
- Custom connector setup for the phone lab

## Install (on the phone)

## One-shot bootstrap (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/skills/termux-connect/scripts/bootstrap.sh | bash
```

Adds `cloudflared` (pkg or release binary), starts MCP in `tmux` session `tc`, health-checks. Add `--tunnel` to also start Cloudflare in session `tun`.


Or from a checkout: `bash skills/termux-connect/scripts/bootstrap.sh` (optional `--start`).


```bash
# from a GrokHunter checkout (or plugin unpack)
bash plugins/grokhunter-termux-connect/skills/termux-connect/scripts/install.sh
~/.grokhunter-termux-connect/start.sh
```

Keep the server in `tmux` (skill `session-lab`).

## Tunnel

```bash
bash plugins/grokhunter-termux-connect/skills/termux-connect/scripts/tunnel-cloudflare.sh
# or tunnel-ngrok.sh
```

Prefer a **named Cloudflare tunnel** for a stable hostname (quick tunnels rotate).

## Grok Bot connector

1. Settings → Plugins → Add custom connector  
2. URL: `https://<tunnel-host>/mcp`  
3. Auth header: `Authorization: Bearer <token>` — enter via secure secret UI; **never paste the token in chat**  
4. Token file on phone: `~/.grokhunter-termux-connect/token` (mode 600)

## Tools (server)

| Tool | Purpose |
|------|---------|
| `grokhunter_status` | `grokhunter status` |
| `grokhunter_doctor` | `grokhunter doctor` |
| `list_dir` / `read_file` / `write_file` | Jail under `$HOME` + `$PREFIX` |
| `shell` | Allowlisted commands only (default) |

Env: `TERMUX_CONNECT_SHELL=allowlist|open|off`, `TERMUX_CONNECT_ROOTS`, `TERMUX_CONNECT_PORT`.

## Hard rules

- Never print the bearer token or `secrets.env`
- Do not claim Magisk/root or native Android Local Computer
- `--trust` / connector only for a source the **user** named
- Coding lab only; credit jorexdeveloper / Termux / Kali / xAI (`CREDITS.md`)

## Verify

```bash
curl -s http://127.0.0.1:8765/healthz
# from Bot: call grokhunter_status via the connector
```

## Cross-links

- Skill `mcp-lab` — Grok Build MCP on phone  
- Skill `plugin-lab` — `grok plugin`  
- Skill `session-lab` — tmux keep-alive  
- Skill `host-lab` — Termux vs Kali  

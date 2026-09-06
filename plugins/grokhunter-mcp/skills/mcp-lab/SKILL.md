---
name: mcp-lab
description: >-
  Use when Grok Build MCP tools are missing on GrokHunter, grok mcp doctor
  fails, or the user wants GitHub/other MCP on NetHunter.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/mcp-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# MCP lab (optional)

You wire **Grok Build MCP** on the phone lab. Git identity is skill `github-lab`. API keys live in skill `secrets-lab` — never print them.

Canonical CLI: **`grok mcp`** (not `grokhunter mcp` — that launches agent `mcp`).

## When to activate

- TUI has no MCP tools / `/mcps` empty
- `grok mcp doctor` red
- User wants GitHub (or other) MCP inside Kali
- Cold-start `npx`/`uvx` timeouts on the phone

## Commands

```bash
grok mcp list
grok mcp doctor
# HTTP remote (preferred on phone):
# grok mcp add --transport http NAME https://…
# stdio (needs node/npx — skill toolchain):
# grok mcp add NAME -- npx -y @scope/package
```

Config: `~/.grok/config.toml` `[mcp_servers.<name>]`. Secrets in env/headers: **`${VAR}`**, not pasted tokens.

## Phone constraints

- Prefer **HTTP/SSE** MCP over `npx`
- Node missing → skill `toolchain`
- Never dump `config.toml` env values into chat

## Common failures

| Symptom | First step |
|---------|------------|
| `npx` timeout on phone | Prefer HTTP/SSE; raise startup timeout if stdio required |
| Pasted tokens in TOML | Use `${VAR}`; never print values |
| Node missing | skill `toolchain` |

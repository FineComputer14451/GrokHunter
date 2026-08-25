---
name: mcp-lab
description: >-
  Grok Build MCP servers on the GrokHunter phone lab: grok mcp list/add/doctor,
  config.toml [mcp_servers], HTTP vs npx/stdio. Use when MCP tools are missing,
  grok mcp doctor fails, or the user wants GitHub/other MCP on NetHunter.
  Optional skill — not part of skills-core N/3.
---

# MCP lab (optional)

You wire **Grok Build MCP** on this phone. Git identity is skill `github-lab`. API keys live in skill `secrets-lab` — never print them.

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
# HTTP remote (preferred on phone — no npx download):
# grok mcp add --transport http NAME https://…
# stdio (needs node/npx — skill toolchain):
# grok mcp add NAME -- npx -y @scope/package
```

Config: `~/.grok/config.toml` `[mcp_servers.<name>]`. Project: `.grok/config.toml`.

Secrets in env/headers: **`${VAR}`**, not pasted tokens. Do not commit keys. `npx` first-run: raise `MCP_TIMEOUT` (ms) or `GROK_MCP_STARTUP_TIMEOUT_SECS`.

## Phone constraints

- Prefer **HTTP/SSE** MCP over `npx` (disk, CPU, startup)
- Node missing → skill `toolchain` (`apt install nodejs npm`)
- `grok mcp doctor` before editing TOML by hand
- Never dump `config.toml` env values into chat

## Common failures

| Symptom | First step |
|---------|------------|
| `npx` timeout on phone | Prefer HTTP/SSE; raise startup timeout if stdio is required |
| Pasted tokens in TOML | Use `${VAR}`; never print env/header values |
| Node missing | skill `toolchain` |

## Verify

```bash
grok mcp doctor
```

## Cross-links

- Grok user guide: `~/.grok/docs/user-guide/07-mcp-servers.md`
- Tokens file: skill `secrets-lab`
- GitHub commits: skill `github-lab`
- Agent `mcp` for add/doctor playbooks
- Plugins that bundle MCP: skill `plugin-lab` (`grok plugin`)
---

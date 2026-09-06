---
name: plugin-lab
description: >-
  Use when a Grok Build plugin skill is missing on GrokHunter, marketplace is
  empty, or the user wants plugins inside NetHunter.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/plugin-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Plugin lab (optional)

You install and trust **Grok Build plugins**. Canonical CLI: **`grok plugin`**. `grokhunter plugin` launches agent `plugin` only. MCP servers not bundled in a plugin stay skill `mcp-lab`.

## When to activate

- `/plugins` empty or a plugin skill vanished
- User asks to add a marketplace / GitHub plugin
- Plugin hooks or MCP look blocked (untrusted)

## Commands

```bash
grok plugin list
grok plugin marketplace list
# grok plugin marketplace add owner/repo
# grok plugin install <source> --trust   # only if the user named the source
grok plugin details <name>
```

TUI: `/plugins` · `Ctrl+L`.

## Phone rules

- `--trust` only for a source the **user named**
- Plugins clone git + may start MCP — watch disk (skill `storage-lab`)
- Never print plugin env/tokens
- Prefer HTTP MCP inside plugins on the phone (skill `mcp-lab`)

## Common failures

| Symptom | First step |
|---------|------------|
| Marketplace empty | `grok plugin marketplace list` (network) |
| `--trust` on unknown source | Trust only a source the user named |
| Product skill missing | `grokhunter skills install` — not `grok plugin` |

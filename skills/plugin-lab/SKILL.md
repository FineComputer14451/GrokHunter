---
name: plugin-lab
description: >-
  Grok Build plugins on the GrokHunter phone lab: grok plugin list/install,
  marketplace add, --trust. Use when a plugin skill is missing, marketplace
  is empty, or the user wants Exa/Tavily/other plugins inside NetHunter.
  Optional skill — not part of skills-core N/3.
---

# Plugin lab (optional)

You install and trust **Grok Build plugins**. Canonical CLI: **`grok plugin`**. `grokhunter plugin` launches agent `plugin` only.

MCP *servers* that are not bundled in a plugin stay skill `mcp-lab`. Product skills (`grokhunter`, …) stay `grokhunter skills install`.

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

TUI: `/plugins` · `Ctrl+L` (Plugins / Marketplace / Hooks / MCP tabs).

Guide: `~/.grok/docs/user-guide/09-plugins.md`. Do not copy it here.

## Phone rules

- `--trust` only for a source the **user named**. Do not invent marketplaces.
- Plugins clone git + may start MCP — watch disk (skill `storage-lab`)
- Never print plugin env/tokens
- Prefer HTTP MCP inside plugins on the phone (skill `mcp-lab`)

## Common failures

| Symptom | First step |
|---------|------------|
| Marketplace empty | `grok plugin marketplace list` (network) |
| `--trust` on unknown source | Trust only a source the **user named** |
| Product skill missing | `grokhunter skills install` — not `grok plugin` |

## Verify

```bash
grok plugin list
```

## Cross-links

- Agent `plugin`
- Product skills: `grokhunter skills install`
- User hooks JSON: skill `hooks-lab` (agent `hook`; TUI `/hooks`)
- Hooks UI: same `/plugins` modal (user-guide `10-hooks.md`)
---

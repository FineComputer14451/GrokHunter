---
name: hooks-lab
description: >-
  Grok Build hooks on the GrokHunter lab: ~/.grok/hooks, /hooks, SessionStart
  and PreToolUse. Use when a hook did not fire, the user wants a safety or
  notify hook, or /hooks-trust is needed. Optional skill — not part of
  skills-core N/3.
---

# Hooks lab (optional)

You wire **Grok lifecycle hooks**. Canonical UI: **`/hooks`** (Plugins modal, Hooks tab). `grokhunter hook` launches agent `hook` only.

Plugin-bundled hooks stay skill `plugin-lab`. Permission *modes* are Grok `/settings` — do not re-document all modes here.

Guide: `~/.grok/docs/user-guide/10-hooks.md`.

## When to activate

- Hook did not run
- User wants SessionStart / PreToolUse / Stop
- Project hooks skipped until `/hooks-trust`

## Locations

| Scope | Path |
|-------|------|
| User | `~/.grok/hooks/*.json` (always trusted) |
| Project | `.grok/hooks/*.json` (needs folder trust) |

```bash
mkdir -p ~/.grok/hooks
# restart grok, then TUI /hooks
```

Project hooks need `/hooks-trust` (same folder-trust store as MCP). Do not `--trust` a repo the user did not name.

## Phone rules

- Keep hook commands tiny (echo / short script) — not apt or long builds
- Never print secrets from hook stdout
- PreToolUse can deny; do not invent root/Magisk guards

## Common failures

| Symptom | First step |
|---------|------------|
| `/hooks` empty | `~/.grok/hooks/*.json`; restart grok |
| Project hook skipped | `/hooks-trust` only if the user wants this repo trusted |
| Long apt in a hook | Keep commands tiny (echo / short script) |

## Verify

TUI `/hooks`. Agent: `hook`.

## Cross-links

- Agent `hook`
- Plugins that ship hooks: skill `plugin-lab`
- MCP trust: skill `mcp-lab`
---

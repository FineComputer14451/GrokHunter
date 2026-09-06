---
name: hooks-lab
description: >-
  Use when a Grok Build hook on GrokHunter did not fire, the user wants
  SessionStart/PreToolUse hooks, or /hooks-trust is needed.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/hooks-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Hooks lab (optional)

You wire **Grok lifecycle hooks**. Canonical UI: `/hooks`. `grokhunter hook` launches agent `hook` only. Plugin-bundled hooks stay skill `plugin-lab`.

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

Project hooks need `/hooks-trust`. Do not `--trust` a repo the user did not name.

## Phone rules

- Keep hook commands tiny (echo / short script)
- Never print secrets from hook stdout
- PreToolUse can deny; do not invent root/Magisk guards

## Common failures

| Symptom | First step |
|---------|------------|
| `/hooks` empty | `~/.grok/hooks/*.json`; restart grok |
| Project hook skipped | `/hooks-trust` only if the user wants this repo trusted |
| Long apt in a hook | Keep commands tiny |

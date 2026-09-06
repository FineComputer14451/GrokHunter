---
name: flow-lab
description: >-
  Use when the user wants Grok Build .rhai workflows on GrokHunter,
  /create-workflow, /workflows, or a saved workflow will not run.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/flow-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Flow lab (optional)

You author and run **Grok Build workflows** (Rhai scripts). GitHub Actions Smoke is skill `ci-lab` — not this.

`grokhunter flow` launches agent `flow`. TUI: `/workflow <name>` · `/workflows`.

## When to activate

- User says workflow, `/create-workflow`, fan-out, or `/workflows`
- A saved `.rhai` fails to start
- Need a phone-sized agent budget

## Where files live

| Scope | Path |
|-------|------|
| This repo | `.grok/workflows/<name>.rhai` |
| User (all projects) | `~/.grok/workflows/<name>.rhai` |

`meta.name` = lowercase, digits, hyphens. First statement: literal `let meta = #{ ... };`.

## Phone constraints

- Keep `agent_budget` small (try **8–32**, not 128)
- Prefer one phase + few `agent()` over huge `parallel()` panels
- Smoke-check with `validate_only` before a real run
- Coding Team specialists (`benjamin` / `lucas` / …) can be `agent_type` when installed

## Common failures

| Symptom | First step |
|---------|------------|
| `agent_budget` too large | Keep **8–32** on phone |
| Actions YAML vs `.rhai` | Actions → skill `ci-lab` |
| Workflow will not start | Fix `meta.name` + first `let meta`; `validate_only` |

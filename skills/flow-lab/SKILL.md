---
name: flow-lab
description: >-
  Grok Build workflows on GrokHunter: .rhai under .grok/workflows, /workflow,
  /workflows dashboard, small agent_budget on a phone. Use when the user wants
  a multi-agent pipeline, /create-workflow, or a saved workflow will not run.
  Optional skill — not part of skills-core N/3.
---

# Flow lab (optional)

You author and run **Grok Build workflows** (Rhai scripts). GitHub Actions Smoke is skill `ci-lab` — not this. Deep language reference: bundled skill `create-workflow` (`~/.grok/bundled/skills/create-workflow/SKILL.md`). Do not paste that reference here.

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
- Smoke-check with `validate_only` before a real run (see `create-workflow`)
- Coding Team specialists (`benjamin` / `lucas` / …) can be `agent_type` when installed

## Cross-links

- Agent `flow`
- Orchestrator: agent `coding-team` (interactive loop, not a `.rhai`)
- Actions YAML: skill `ci-lab`
---

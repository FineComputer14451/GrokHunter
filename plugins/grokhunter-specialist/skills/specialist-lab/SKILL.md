---
name: specialist-lab
description: >-
  Use when adding a new GrokHunter lab specialist — skill-only or agent+skill
  (Wave 6), CLI, completions, ci-unit, Coding Team routing.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/specialist-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Specialist lab (optional)

You mint **new lab playbooks and spawnable specialists**. Canonical recipe: `agents/README.md` — Adding a specialist. Do not copy that checklist here.

## When to activate

- User says add an agent, add a skill, new specialist, Wave 7, `/specialist-lab`
- Coding Team is about to create `agents/<name>.md` or `skills/<name>/SKILL.md`
- User asks how to wire `grokhunter <name>` / completions / ci-unit

## First step

Read the recipe. Then pick **skill-only** (nothing to spawn) or **agent + skill** (Wave 6 shape). Gold copies: `toolchain.md`, `github.md`, `secrets-lab`, `overlay.md`.

## Hard stops

- No `binds` agent — Desktop owns `grokhunter binds`
- Do not promote `nethunter-recon` to a product default
- Do not add to `GH_CORE_SKILLS` / `skills=N/3`
- `bin/grokhunter` `usage()` has no backticks; file stays under 1000 lines
- Install scan does not wire CLI, completions, or Coding Team routing

## Common failures

| Symptom | First step |
|---------|------------|
| Copied the 13 steps into a new file | Point at `agents/README.md`; delete the duplicate |
| Doctor N/3 broke | New skills are optional — not core |
| Help grep fails | No backticks in `usage()` |

## Verify

```bash
bash scripts/ci-unit.sh
grokhunter help | grep <name>
grokhunter skills install
```

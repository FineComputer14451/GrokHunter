---
name: specialist-lab
description: >-
  Add a GrokHunter lab specialist using the Wave 6 recipe: skill-only or
  agent plus skill, role, persona, CLI, completions, ci-unit, Coding Team
  routing. Use when the user wants a new agent, new *-lab skill, add a
  specialist, Wave 7, or runs /specialist-lab. Optional skill — not part of
  skills-core N/3.
---

# Specialist lab (optional)

You mint **new lab playbooks and spawnable specialists**. Canonical recipe: [`agents/README.md` — Adding a specialist](../../agents/README.md#adding-a-specialist). Do not copy that checklist here.

**Not affiliated** with xAI, Offensive Security, Termux, or jorexdeveloper.

## When to activate

- User says add an agent, add a skill, new specialist, Wave 7, `/specialist-lab`
- Coding Team is about to create `agents/<name>.md` or `skills/<name>/SKILL.md`
- User asks how to wire `grokhunter <name>` / completions / ci-unit

## First step

Read the recipe. Then pick **skill-only** (nothing to spawn) or **agent + skill** (Wave 6 shape).

Gold copies live in that README: `toolchain.md`, `github.md`, `secrets-lab`, `overlay.md`.

## Hard stops

- No `binds` agent — Desktop owns `grokhunter binds`
- Do not promote `nethunter-recon` to a product default
- Do not add to `GH_CORE_SKILLS` / `skills=N/3`
- `bin/grokhunter` `usage()` has **no backticks**; file stays under 1000 lines
- Install scan does **not** wire CLI, completions, or Coding Team routing

## Common failures

| Symptom | First step |
|---------|------------|
| Copied the 13 steps into a new file | Point at `agents/README.md`; delete the duplicate |
| `grokhunter <name>` steals `models` / `git-identity` / `grok mcp` | Use `modeler` / `github` / document agent vs CLI |
| Doctor N/3 broke | New skills are optional — not core |
| Help grep fails | No backticks in `usage()`; `grep -q 'grokhunter <name>'` |

## Verify

```bash
bash scripts/ci-unit.sh
grokhunter help | grep <name>    # agent path only
grokhunter skills install
```

## Cross-links

- Recipe: `agents/README.md` (SSOT)
- Protocol: `docs/CODING-TEAM.md`
- Indexes: `skills/README.md`, `skills/PLAYBOOKS.md`, both REFERENCES
- Hard rules: `skills/REFERENCES.md`

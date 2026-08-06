# Coding Team — Design → Build → Harden (runtime agents)

GrokHunter ships four **Grok Build agents** under `agents/`. They are **system prompts for agent types**, loaded at runtime when selected or spawned—not AGENTS.md project rules.

| Agent type | Role |
|------------|------|
| `benjamin` | Architecture, security, mobile constraints — design only (plan mode) |
| `lucas` | Implementation in small shippable increments |
| `harper` | Tests, edge cases, hardening |
| `coding-team` | Orchestrates the loop |

## Install for runtime discovery

```bash
grokhunter skills install
# → ~/.grok/agents/{benjamin,lucas,harper,coding-team}.md
```

Also works if you place the same files under project `.grok/agents/`.

## Loop

```text
Clarify goal + constraints
        ↓
   [benjamin] design
        ↓  design accepted
   [lucas] build increment
        ↓  working increment
   [harper] harden / test
        ↓
   criteria met? ──no──→ loop
        yes
      done
```

## Mobile constraints checklist

- Offline / intermittent network?
- Battery / long build?
- Storage (internal vs SD)?
- Security / secrets?
- Shell-only vs X11 desktop?

## Handoff templates

### Design card (benjamin → lucas)

```markdown
## Goal
## Constraints
## Approach
## Critical files
## Acceptance criteria
## Out of scope
## Security notes
```

### Build card (lucas → harper)

```markdown
## Files changed
## How to run / smoke
## Known gaps
```

### Harden card (harper)

```markdown
## Risks (blocker / important / minor)
## Repro steps
## Pass / fail
## Send back
```

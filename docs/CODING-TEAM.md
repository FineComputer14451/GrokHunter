# Coding Team — Design → Build → Harden (runtime agents)

GrokHunter ships **Grok Build agent definitions** under `agents/`. They are system prompts for agent types, loaded when selected or spawned—not AGENTS.md project rules.

Compatible with **Grok Build 1.0.5+** (`~/.grok/agents/`, `/config-agents`, `spawn_subagent`).

## Roster

### Core loop

| Agent type | Mode | Role |
|------------|------|------|
| `benjamin` | plan / read-only | Architecture, security, mobile constraints |
| `lucas` | full | Implementation in small shippable increments |
| `harper` | full | Tests, edge cases, hardening |
| `coding-team` | full | Orchestrates the loop + specialists |

### Specialists

| Agent type | Mode | Role |
|------------|------|------|
| `scout` | plan / read-only | Fast map of codebases / install flows |
| `review` | plan / read-only | Diff and change review |
| `fix` | full | One-bug surgical patches |
| `desktop` | full | Termux:X11, nh-x11, proot binds |

Built-ins still available: `plan`, `explore`, `general-purpose`.

## Install for runtime discovery

```bash
grokhunter skills install
# → ~/.grok/agents/{benjamin,lucas,harper,coding-team,scout,review,fix,desktop}.md
```

Project-local: copy the same files under `.grok/agents/`.

```bash
grok inspect   # should list user agents
```

## Loop

```text
Clarify goal + constraints
        ↓
   [scout] map (optional, unfamiliar tree)
        ↓
   [benjamin] design
        ↓  design accepted
   [lucas] build  —or—  [fix] tiny bug
        ↓  working increment
   [harper] harden / test
        ↓  optional
   [review] independent pass
        ↓
   criteria met? ──no──→ loop
        yes
      done
```

Desktop-only issues can go straight to **`desktop`**.

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

### Map card (scout)

```markdown
## Question
## Answer
## Key paths
## Suggested next agent
```

### Review card (review)

```markdown
## Summary
## Findings (blocker / important / minor)
## Suggested next agent
```

### Fix card (fix)

```markdown
## Failure
## Root cause
## Patch
## Smoke
```

## Personas (subagent overlays)

Personas shape **tone and output contracts** without changing agent type.  
Product files: `personas/*.toml` → `~/.grok/personas/` via `grokhunter skills install`.

| Persona | Focus |
|---------|--------|
| `mobile` | NetHunter / Termux constraints |
| `concise` | Short mobile-friendly output |
| `shell-first` | Scripts / lab tooling |
| `pair` | Pair-programming tone |
| `security-lab` | Secrets + installer safety |
| `design-card` | Design card structure |
| `build-card` | Build card structure |
| `harden-card` | Harden card structure |

TUI: `/personas` (or Personas tab under `/config-agents`).  
Details: [personas/README.md](../personas/README.md).

## Roles (capability defaults)

Roles set **capability mode** and **reasoning effort** for subagent resolution.

| Role | Capability | Aligns with |
|------|------------|-------------|
| `architect` | read-only | benjamin |
| `builder` | all | lucas |
| `reliability` | all | harper |
| `mapper` | read-only | scout |
| `code-review` | all | review |
| `surgical` | all | fix |
| `x11-desktop` | all | desktop |

Install: `personas/` + `roles/` both via `grokhunter skills install` → `~/.grok/roles/`.  
Details: [roles/README.md](../roles/README.md).

```text
agent  = who          (benjamin, lucas, …)
role   = capabilities (architect, builder, …)
persona = tone/cards  (mobile, design-card, …)
```

## CLI examples (1.0.5)

```bash
grok --agent coding-team
grok --agent benjamin -p "Design overlay-only Aider repair"
grok --agent scout -p "Map install_aider and ensure_grok"
grok --agent review -p "Review uncommitted changes"
grok --agent fix -p "ci-unit fails on bind-patch"
grok --agent desktop -p "nh-x11 black screen"
```

In TUI: `/config-agents` or `/agents` · personas: `/personas`.

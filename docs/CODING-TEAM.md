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
| `overlay` | full | install.sh, overlay-only, cache, PATH wrappers |
| `ship` | full | VERSION, changelog, site, tag / release notes |
| `docs` | plan / read-only | README, FAQ, website copy |
| `models` | full | grok-4.6 / V9 pickers (`grokhunter modeler`) |
| `ci` | full | ci-unit.sh / Smoke |
| `aider` | full | aider-grok install / uv 3.12 |
| `session` | full | tmux persist / grok resume |
| `host` | full | Termux host vs Kali guest |
| `mcp` | full | grok mcp list / add / doctor |
| `plugin` | full | grok plugin / marketplace |
| `flow` | full | Grok .rhai workflows (`grokhunter flow`) |
| `storage` | full | df / cache / --mini |
| `editor` | full | nvim / micro |
| `hook` | full | Grok ~/.grok/hooks / /hooks |
| `shell` | full | profile.sh / completions |

Built-ins still available: `plan`, `explore`, `general-purpose`.

## Install for runtime discovery

```bash
grokhunter skills install
# → ~/.grok/agents/ (core + specialists; grokhunter skills install)
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

Desktop-only issues can go straight to **`desktop`**. Installer/PATH/cache → **`overlay`**. Version/tag → **`ship`**. Doc-only → **`docs`**. Pickers/profile → **`models`**. ci-unit/Smoke → **`ci`**. Aider install → **`aider`**. tmux / grok resume → **`session`**. Termux vs Kali → **`host`**. MCP servers → **`mcp`**. Plugins → **`plugin`**. Grok `.rhai` workflows → **`flow`**. Disk/SD → **`storage`**. nvim/micro → **`editor`**. Grok hooks → **`hook`**. profile/completions → **`shell`**.

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

### Overlay card (overlay)

```markdown
## Symptom
## Overlay root / cache
## Commands
## Verify
## Escalate
```

### Ship card (ship)

```markdown
## Version
## Files bumped
## Overlay cache
## Upgrade snippet
## Tag / release notes
```

### Docs card (docs)

```markdown
## Question / drift
## Canonical home
## Files to change
## Suggested copy
```

### Session card (session)

```markdown
## Symptom
## Host / guest / tmux
## Commands
## Verify
```

### Host card (host)

```markdown
## Symptom
## Host or guest
## Commands
## Verify
## Escalate
```

### MCP card (mcp)

```markdown
## Symptom
## Servers / transport
## Commands
## Verify (grok mcp doctor)
```

### Plugin card (plugin)

```markdown
## Symptom
## Marketplace / plugin
## Commands
## Verify (grok plugin list)
```

### Flow card (flow)

```markdown
## Goal
## Path (.rhai)
## Budget
## How to run
```

### Storage card (storage)

```markdown
## Symptom
## df / hot dirs
## Commands
## Verify
```

### Editor card (editor)

```markdown
## Symptom
## Tool
## Commands
## Verify
```

### Hook card (hook)

```markdown
## Symptom
## Scope (user / project)
## Commands
## Verify (/hooks)
```

### Shell card (shell)

```markdown
## Symptom
## rc / profile
## Commands
## Verify (type ghd / TAB)
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
| `release-card` | Ship card structure |
| `overlay-card` | Overlay card structure |
| `models-card` | Models card structure |
| `ci-card` | CI card structure |
| `session-card` | Session card structure |
| `host-card` | Host card structure |
| `mcp-card` | MCP card structure |
| `plugin-card` | Plugin card structure |
| `flow-card` | Flow card structure |
| `storage-card` | Storage card structure |
| `editor-card` | Editor card structure |
| `hook-card` | Hook card structure |
| `shell-card` | Shell card structure |

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
| `overlay` | all | overlay |
| `ship` | all | ship |
| `docs` | read-only | docs |
| `models` | all | models |
| `ci` | all | ci |
| `aider` | all | aider |
| `session` | all | session |
| `host` | all | host |
| `mcp` | all | mcp |
| `plugin` | all | plugin |
| `flow` | all | flow |
| `storage` | all | storage |
| `editor` | all | editor |
| `hook` | all | hook |
| `shell` | all | shell |

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
grok --agent session -p "Termux killed grok, resume tmux"
grok --agent host -p "grokhunter missing inside nethunter"
grok --agent mcp -p "grok mcp doctor red for github"
grok --agent plugin -p "list installed plugins"
grok --agent flow -p "small review workflow for this repo"
grok --agent storage -p "df full after overlay-only"
grok --agent editor -p "install nvim in Kali"
grok --agent hook -p "SessionStart hook did not fire"
grok --agent shell -p "ghd not found in new zsh"
```

In TUI: `/config-agents` or `/agents` · personas: `/personas`.

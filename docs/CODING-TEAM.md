# Coding Team — Design → Build → Harden (runtime agents)

GrokHunter ships **Grok Build agent definitions** under `agents/`. They are system prompts for agent types, loaded when selected or spawned—not `AGENTS.md` project rules.

Compatible with **Grok Build 1.0.5+** (`~/.grok/agents/`, `/config-agents`, `spawn_subagent`).

| Related | Path |
|---------|------|
| Agent roster / CLI | [agents/README.md](../agents/README.md) |
| Add a specialist | [agents/README.md](../agents/README.md#adding-a-specialist) |
| Cross-index | [agents/REFERENCES.md](../agents/REFERENCES.md) |
| All handoff cards | [agents/HANDOFF-TEMPLATES.md](../agents/HANDOFF-TEMPLATES.md) |
| Session style | skill `pair-programming` |
| Personas / roles | [personas/README.md](../personas/README.md) · [roles/README.md](../roles/README.md) |

## Core roster

| Agent type | Mode | Role |
|------------|------|------|
| `benjamin` | plan / read-only | Architecture, security, mobile constraints |
| `lucas` | full | Implementation in small shippable increments |
| `harper` | full | Tests, edge cases, hardening |
| `coding-team` | full | Orchestrates the loop + specialists |

Full specialist roster (scout, review, fix, desktop, overlay, ship, …): [agents/README.md](../agents/README.md).

Built-ins still available: `plan`, `explore`, `general-purpose`.

## Install for runtime discovery

```bash
grokhunter skills install
# → ~/.grok/agents/ (core + specialists)
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

### Specialist routing

| Issue class | Agent |
|-------------|--------|
| Unfamiliar tree / install-flow map | `scout` |
| Diff / PR review only | `review` |
| One-bug surgical patch | `fix` |
| Installer / PATH / cache / wrappers | `overlay` |
| Termux:X11 / nh-x11 / proot desktop | `desktop` (`grokhunter binds`, bwrap/glycin) |
| Termux host vs Kali guest | `host` |
| VERSION / changelog / tag | `ship` |
| README / FAQ / site copy | `docs` |
| V9 pickers / grok-4.6 profile | `models` |
| ci-unit / Smoke | `ci` |
| Aider install / uv 3.12 | `aider` |
| tmux / `grok --resume` | `session` |
| `grok mcp` | `mcp` |
| `grok plugin` / marketplace | `plugin` |
| Grok `.rhai` / `/workflow` | `flow` |
| Disk / SD / cache / `--mini` | `storage` |
| nvim / micro | `editor` |
| `~/.grok/hooks` / `/hooks` | `hook` |
| profile.sh / completions / `ghd` | `shell` |
| git-identity / invalid-email | `github` (CLI is `grokhunter git-identity`) |
| secrets.env / missing API key | `secrets` |
| apt / gcc / python / node | `toolchain` (Aider uv stays `aider`) |
| TLS / `SSL_CERT_FILE` / CA | `tls` (overlay still writes the install symlink) |
| x.ai offline / `http_code=000` / DNS | `net` (401/403 = reachable; CA stays `tls`) |
| Authorized public username footprint | `tookie` (hits are leads; not a product default) |
| New lab agent / `*-lab` skill | skill `specialist-lab` (not a new agent type) |

### When not to use the full loop

| Situation | Prefer |
|-----------|--------|
| One-line bug | `fix` |
| Installer / PATH / cache | `overlay` |
| X11 black screen / lag / binds / bwrap | `desktop` |
| “Am I in Termux or Kali?” | `host` |
| Version / tag only | `ship` (after Harper if code changed) |
| Doc-only drift | `docs` |
| GitHub invalid-email | `github` |
| secrets.env / ai-smoke key | `secrets` |
| Compilers missing | `toolchain` |
| curl/gh SSL / missing CA | `tls` |
| Doctor offline / no route to x.ai | `net` |
| Authorized public username lookup | `tookie` |
| Add a specialist | skill `specialist-lab` |

## Mobile constraints checklist

- Offline / intermittent network?
- Battery / long build?
- Storage (internal vs SD)?
- Security / secrets?
- Shell-only vs X11 desktop?

## Core handoff cards

Canonical skeletons for **all** agents (including specialists): [agents/HANDOFF-TEMPLATES.md](../agents/HANDOFF-TEMPLATES.md). Agent defs may require extra fields (e.g. handoff target, tests run).

### Design card (benjamin → lucas)

```markdown
## Goal
## Constraints (offline / battery / storage / security / shell-vs-X11)
## Approach
## Critical files
## Acceptance criteria
## Out of scope
## Security notes
## Handoff → Lucas | Harper | scout
```

### Build card (lucas → harper)

```markdown
## Files changed
- path — what / why
## How to run / smoke
## Known gaps
## Handoff → harper | benjamin | fix
```

### Harden card (harper)

```markdown
## Risks
- blocker: …
- important: …
- minor: …
## Repro steps
## Pass / fail
## Send back → lucas | benjamin | fix
## Tests added / run
```

## Personas & roles

- **Personas** shape tone and card contracts without changing agent type → [personas/README.md](../personas/README.md) · TUI `/personas`
- **Roles** set capability mode and reasoning effort for subagent resolution → [roles/README.md](../roles/README.md)

Both install via `grokhunter skills install` (`~/.grok/personas/`, `~/.grok/roles/`).

Canonical agent / role / persona model: [roles/README.md](../roles/README.md).

## CLI examples (1.0.5+)

```bash
grok --agent coding-team
grok --agent benjamin -p "Design overlay-only Aider repair"
grok --agent scout -p "Map install_aider and ensure_grok"
grok --agent review -p "Review uncommitted changes"
grok --agent fix -p "ci-unit fails on bind-patch"
grok --agent desktop -p "nh-x11 black screen"
grok --agent overlay -p "grokhunter not on PATH after overlay-only"
grok --agent host -p "am I in Termux or Kali?"
grok --agent session -p "Termux killed grok, resume tmux"
grok --agent mcp -p "grok mcp doctor red for github"
grok --agent plugin -p "list installed plugins"
grok --agent flow -p "small review workflow for this repo"
grok --agent storage -p "df full after overlay-only"
grok --agent editor -p "install nvim in Kali"
grok --agent hook -p "SessionStart hook did not fire"
grok --agent shell -p "ghd not found in new zsh"
grok --agent github -p "commits show invalid-email-address"
grok --agent secrets -p "ai-smoke missing-key"
grok --agent toolchain -p "gcc missing in nethunter"
```

In TUI: `/config-agents` or `/agents` · personas: `/personas`.

# GrokHunter agents (Grok Build 1.0.5+)

These are **Grok Build agent definitions**. Grok loads the matching file as the agent system prompt when you:

- select the agent in `/config-agents` (alias `/agents`), or
- spawn `subagent_type: <name>` from a parent agent / Coding Team

**Expanded roster** (v1.0.9+): each agent includes domain ownership, process steps, common failures, required handoff cards, and explicit references to skills/docs.

## Supporting files

| File | Purpose |
|------|---------|
| [REFERENCES.md](REFERENCES.md) | Master cross-index of skills, docs, agents, hard rules |
| [HANDOFF-TEMPLATES.md](HANDOFF-TEMPLATES.md) | All card templates in one place |
| [../docs/CODING-TEAM.md](../docs/CODING-TEAM.md) | Full Design → Build → Harden protocol |

## Coding Team core

| File | Type | Mode | Role |
|------|------|------|------|
| `benjamin.md` | `benjamin` | plan / read-only | Senior Architect |
| `lucas.md` | `lucas` | full | Rapid Builder |
| `harper.md` | `harper` | full | Reliability |
| `coding-team.md` | `coding-team` | full | Orchestrator (Design → Build → Harden) |

## Lab specialists

| File | Type | Mode | Role |
|------|------|------|------|
| `scout.md` | `scout` | plan / read-only | Fast codebase / install-flow map |
| `review.md` | `review` | plan / read-only | Diff / change review |
| `fix.md` | `fix` | full | Surgical one-bug patches |
| `desktop.md` | `desktop` | full | Termux:X11 / nh-x11 / proot desktop |
| `overlay.md` | `overlay` | full | install.sh / overlay cache / PATH wrappers |
| `ship.md` | `ship` | full | VERSION / changelog / tag / release notes |
| `docs.md` | `docs` | plan / read-only | README / FAQ / website copy |
| `models.md` | `models` | full | grok-4.6 / V9 pickers (`grokhunter modeler`) |
| `ci.md` | `ci` | full | ci-unit / Smoke |
| `aider.md` | `aider` | full | aider-grok install / uv 3.12 |
| `session.md` | `session` | full | tmux persist / grok resume |
| `host.md` | `host` | full | Termux host vs Kali guest |
| `mcp.md` | `mcp` | full | grok mcp list / add / doctor |
| `plugin.md` | `plugin` | full | grok plugin / marketplace |
| `flow.md` | `flow` | full | Grok .rhai workflows |
| `storage.md` | `storage` | full | df / cache / --mini |
| `editor.md` | `editor` | full | nvim / micro |
| `hook.md` | `hook` | full | Grok hooks / /hooks |
| `shell.md` | `shell` | full | profile.sh / completions |
| `github.md` | `github` | full | git-identity (`grokhunter github`; CLI is `git-identity`) |
| `secrets.md` | `secrets` | full | secrets.env mode 600 |
| `toolchain.md` | `toolchain` | full | apt / compilers |

## Install (user discovery)

```bash
grokhunter skills install
# copies agents/*.md → ~/.grok/agents/
```

Also works from project `.grok/agents/`.

Verify:

```bash
grok inspect
# Agents: … editor, hook, shell, github, secrets, toolchain (+ builtins)
```

## Use

```text
/config-agents                 # pick coding-team, benjamin, scout, …
/agents

# Headless examples
grok --agent scout -p "Map how install_aider works"
grok --agent review -p "Review the uncommitted diff"
grok --agent fix -p "bash -n fails on scripts/ensure_grok.sh"
grok --agent desktop -p "Black screen after nh-x11"
grok --agent overlay -p "grokhunter not on PATH after overlay-only"
grok --agent ship -p "Cut 1.0.10 from Unreleased"
grok --agent docs -p "FAQ still says git-identity needs gh"
grok --agent models -p "models=no after overlay-only"
grokhunter modeler -p "Install V9 pickers"
grok --agent ci -p "ci-unit failed on git-identity help"
grok --agent aider -p "aider-grok missing on Kali 3.13"
grok --agent session -p "Termux killed grok"
grokhunter session -p "tmux attach lab"
grok --agent host -p "am I in Termux or Kali?"
grokhunter host -p "grokhunter not on PATH"
grok --agent mcp -p "add GitHub MCP over HTTP"
grokhunter mcp -p "grok mcp doctor"   # agent; CLI is grok mcp
grok --agent plugin -p "marketplace list"
grokhunter plugin -p "grok plugin list"  # agent; CLI is grok plugin
grok --agent flow -p "author a tiny review.rhai"
grokhunter flow -p "phone-sized agent_budget"
grok --agent storage -p "what can I delete"
grokhunter storage -p "df -h"
grok --agent editor -p "install nvim"
grokhunter editor -p "micro vs nvim"
grok --agent hook -p "/hooks empty"
grokhunter hook -p "add SessionStart hook"
grok --agent shell -p "TAB complete missing"
grokhunter shell -p "source profile.sh"
grok --agent github -p "invalid-email-address"
grokhunter github -p "git-identity set"  # agent; CLI is grokhunter git-identity
grok --agent secrets -p "secrets.env mode"
grokhunter secrets -p "ai-smoke missing-key"
grok --agent toolchain -p "install gcc"
grokhunter toolchain -p "python3 missing"
grokhunter plan "…"            # built-in plan agent (not benjamin)
```

## Adding a specialist

One home for this recipe. Copy a gold file; do not invent a parallel checklist. Grok playbook: skill `specialist-lab` (`/specialist-lab`).

| Kind | Gold copy |
|------|-----------|
| Normal lab agent | [`toolchain.md`](toolchain.md) |
| Agent whose CLI name is taken | [`github.md`](github.md) (`grokhunter github` vs `git-identity`) |
| Skill playbook | [`secrets-lab/SKILL.md`](../skills/secrets-lab/SKILL.md) |
| Common failures / Do not steal | [`overlay.md`](overlay.md), [`session.md`](session.md) |

**Do not add** a `binds` agent (Desktop owns `grokhunter binds`). **Do not** promote `nethunter-recon` to a product default. Core health stays `skills=N/3` (`grokhunter`, `pair-programming`, `aider-grok`).

### Skill-only

If there is nothing to spawn, stop at a playbook:

1. `skills/<name>/SKILL.md` — YAML `name` + `description` with trigger words; optional, not N/3
2. When to activate, first commands, **Common failures** (3–6 rows), **Verify**, cross-link
3. [`skills/PLAYBOOKS.md`](../skills/PLAYBOOKS.md) + [`skills/README.md`](../skills/README.md) + both REFERENCES indexes
4. `grokhunter skills install` (scan-based; skip `_` dirs)

### Agent + skill (Wave 6 shape)

Use this when Coding Team should `spawn_subagent` / `grokhunter <name>`:

1. **Name** — kebab `agents/<name>.md`. Must not steal: `binds`, `models` (use `modeler`), `git-identity` (use `github`), `mcp`/`plugin` (those CLIs are `grok …`).
2. **Agent file** — frontmatter `name`, `description`, `prompt_mode: full`, `permission_mode: default` (or `plan` if read-only), `agents_md: true`. Body: ownership sentence, Domain, Do not steal, Process, Common failures, card, References, Activation.
3. **Skill** — pair `skills/<name>/` or `skills/<name>-lab/` (existing pattern). Point at the agent; do not copy Domain tables.
4. **Role** — `roles/<name>.toml` (`default_capability_mode`, `reasoning_effort`).
5. **Persona** — `personas/<name>-card.toml` emitting the same card as [`HANDOFF-TEMPLATES.md`](HANDOFF-TEMPLATES.md).
6. **Card** — add the skeleton to `HANDOFF-TEMPLATES.md`.
7. **CLI** — `bin/grokhunter`: one `usage()` line (**no backticks** — ci-unit greps the heredoc) and append `<name>` to the specialist `case` arm. Keep the file **under 1000 lines**. Collision: `modeler` → agent `models`; `github` → CLI `git-identity`; `mcp`/`plugin` → `grok mcp` / `grok plugin`.
8. **Completions** — `config/completions/zsh/_grokhunter` and `config/completions/bash/grokhunter.bash`.
9. **ci-unit** — `grep -q 'grokhunter <name>'` on help; `grep -qx "<name>"` in install_agents / install_roles / install_personas (`<name>-card`).
10. **Coding Team** — roster row, routing rule, spawn list, speaker label `[Name]`, activation line in `agents/coding-team.md` + `docs/CODING-TEAM.md`.
11. **Indexes** — this roster table, [`REFERENCES.md`](REFERENCES.md), [`skills/REFERENCES.md`](../skills/REFERENCES.md), PLAYBOOKS escalate map, README + `website/index.html` CLI row, FAQ one-liner, CHANGELOG Unreleased.
12. **Neighbors** — Do not steal rows on the agents you almost collided with (Wave 6: ship vs github, aider vs toolchain, secrets vs mcp).
13. **Verify** — `bash scripts/ci-unit.sh`; `grokhunter help | grep <name>`; `grokhunter skills install`.

Install copies are scan-based (`lib/agents-discover.sh`, `lib/skills-discover.sh`). CLI, completions, and Coding Team routing are **not**.

## Loop

```text
[scout] map (optional)
    ↓
[benjamin] design
    ↓
[lucas] or [fix] implement
    ↓
[harper] harden  ·  [review] optional pass
    ↓
done
```

Personas (tone overlays): [personas/README.md](../personas/README.md) · install via `grokhunter skills install`  
Roles (capability defaults): [roles/README.md](../roles/README.md)  
Protocol: [docs/CODING-TEAM.md](../docs/CODING-TEAM.md)  
References: [REFERENCES.md](REFERENCES.md) · Templates: [HANDOFF-TEMPLATES.md](HANDOFF-TEMPLATES.md)

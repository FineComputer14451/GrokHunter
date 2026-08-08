# GrokHunter agents (Grok Build 1.0.0+)

These are **Grok Build agent definitions**. Grok loads the matching file as the agent system prompt when you:

- select the agent in `/config-agents` (alias `/agents`), or
- spawn `subagent_type: <name>` from a parent agent / Coding Team

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

## Install (user discovery)

```bash
grokhunter skills install
# copies agents/*.md → ~/.grok/agents/
```

Also works from project `.grok/agents/`.

Verify:

```bash
grok inspect
# Agents: benjamin, lucas, harper, coding-team, scout, review, fix, desktop (+ builtins)
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
grokhunter plan "…"            # built-in plan agent (not benjamin)
```

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
Protocol: [docs/CODING-TEAM.md](../docs/CODING-TEAM.md)

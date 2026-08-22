# GrokHunter agents (Grok Build 1.0.5+)

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

## Install (user discovery)

```bash
grokhunter skills install
# copies agents/*.md → ~/.grok/agents/
```

Also works from project `.grok/agents/`.

Verify:

```bash
grok inspect
# Agents: … plugin, flow, storage, editor, hook, shell (+ builtins)
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

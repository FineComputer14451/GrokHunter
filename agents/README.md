# GrokHunter Coding Team agents (runtime)

These are **Grok Build agent definitions**. At runtime Grok loads the matching file as the agent system prompt when:

- you select the agent in `/config-agents` (alias `/agents`), or
- a parent spawns `subagent_type: benjamin|lucas|harper|coding-team`

| File | Agent type | Role | Tools |
|------|------------|------|-------|
| `benjamin.md` | `benjamin` | Senior Architect | plan / read-only |
| `lucas.md` | `lucas` | Rapid Builder | full |
| `harper.md` | `harper` | Reliability | full |
| `coding-team.md` | `coding-team` | Orchestrator | full |

## Install (user discovery path)

```bash
grokhunter skills install
# copies agents/*.md → ~/.grok/agents/
```

Grok discovers user agents from `~/.grok/agents/` and project agents from `.grok/agents/`.

## Use

```text
/config-agents          # pick coding-team, benjamin, …
# or spawn: subagent_type = benjamin | lucas | harper | coding-team
```

Protocol: [docs/CODING-TEAM.md](../docs/CODING-TEAM.md)

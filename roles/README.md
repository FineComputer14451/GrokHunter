# GrokHunter roles (Grok Build 1.0.0+)

**Roles** set capability mode, reasoning effort, and related defaults for subagent resolution.  
They pair with **agents** (session type) and **personas** (tone/output).

Discovered from:

1. `.grok/roles/*.toml` (project)
2. `~/.grok/roles/*.toml` (user) ← install target
3. Bundled roles (lowest)

## Product roles

| File | Role | Capability | Aligns with |
|------|------|------------|-------------|
| `architect.toml` | `architect` | read-only | benjamin + design-card |
| `builder.toml` | `builder` | all | lucas + build-card |
| `reliability.toml` | `reliability` | all | harper + harden-card |
| `mapper.toml` | `mapper` | read-only | scout |
| `code-review.toml` | `code-review` | all | review |
| `surgical.toml` | `surgical` | all | fix |
| `x11-desktop.toml` | `x11-desktop` | all | desktop |

## Install

```bash
grokhunter skills install
# → ~/.grok/roles/*.toml
```

## Mental model

```text
agent type  = who (benjamin / lucas / …)
role        = capabilities + effort defaults
persona     = tone + card contracts (mobile, concise, …)
```

TUI: `/config-agents` · see also [personas/README.md](../personas/README.md) and [docs/CODING-TEAM.md](../docs/CODING-TEAM.md).

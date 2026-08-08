# GrokHunter personas (Grok Build 1.0.0+)

Personas are **behavioral overlays** for subagents. They do not replace agent types (`benjamin`, `lucas`, …). Grok injects persona instructions as a system reminder when a role/resolution selects them.

Discovered from (priority):

1. `.grok/personas/*.toml` (project)
2. `~/.grok/personas/*.toml` (user) ← install target
3. Bundled personas (lowest)

TUI: `/personas` or Personas tab under `/config-agents`.

## Product personas

| File | Persona | Use |
|------|---------|-----|
| `mobile.toml` | `mobile` | NetHunter/Termux constraints |
| `concise.toml` | `concise` | Short mobile-friendly output |
| `shell-first.toml` | `shell-first` | Scripts / lab tooling bias |
| `pair.toml` | `pair` | Pair-programming tone |
| `security-lab.toml` | `security-lab` | Secrets + installer safety |
| `design-card.toml` | `design-card` | Design card shape (Benjamin) |
| `build-card.toml` | `build-card` | Build card shape (Lucas) |
| `harden-card.toml` | `harden-card` | Harden card shape (Harper) |

## Install

```bash
grokhunter skills install
# copies personas/*.toml → ~/.grok/personas/
```

```bash
grok inspect
# Personas section (when listed) / TUI /personas
```

## With agents

| Agent | Helpful personas |
|-------|------------------|
| benjamin | `design-card`, `mobile`, `security-lab` |
| lucas | `build-card`, `shell-first`, `pair` |
| harper | `harden-card`, `security-lab` |
| scout | `mobile`, `concise` |
| review | `security-lab`, `concise` |
| fix | `shell-first`, `concise` |
| desktop | `mobile`, `concise` |

Personas are applied via **role / resolution**, not a `spawn_subagent` parameter. Use the Personas tab or roles that reference them.

See [docs/CODING-TEAM.md](../docs/CODING-TEAM.md) and Grok user guide *Subagents*.

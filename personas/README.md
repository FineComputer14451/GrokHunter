# GrokHunter personas (Grok Build 1.0.5+)

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
| `release-card.toml` | `release-card` | Ship card shape |
| `overlay-card.toml` | `overlay-card` | Overlay card shape |
| `models-card.toml` | `models-card` | Models card shape |
| `ci-card.toml` | `ci-card` | CI card shape |
| `session-card.toml` | `session-card` | Session card shape |
| `host-card.toml` | `host-card` | Host card shape |
| `mcp-card.toml` | `mcp-card` | MCP card shape |
| `plugin-card.toml` | `plugin-card` | Plugin card shape |
| `flow-card.toml` | `flow-card` | Flow card shape |
| `storage-card.toml` | `storage-card` | Storage card shape |
| `editor-card.toml` | `editor-card` | Editor card shape |
| `hook-card.toml` | `hook-card` | Hook card shape |
| `shell-card.toml` | `shell-card` | Shell card shape |
| `github-card.toml` | `github-card` | GitHub card shape |
| `secrets-card.toml` | `secrets-card` | Secrets card shape |
| `toolchain-card.toml` | `toolchain-card` | Toolchain card shape |
| `tls-card.toml` | `tls-card` | TLS card shape |
| `net-card.toml` | `net-card` | Net card shape |

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
| overlay | `overlay-card`, `shell-first`, `mobile` |
| ship | `release-card`, `concise` |
| docs | `concise`, `mobile` |
| models | `models-card`, `concise` |
| ci | `ci-card`, `shell-first` |
| aider | `shell-first`, `pair` |
| session | `session-card`, `mobile`, `concise` |
| host | `host-card`, `mobile`, `shell-first` |
| mcp | `mcp-card`, `security-lab`, `concise` |
| plugin | `plugin-card`, `security-lab`, `concise` |
| flow | `flow-card`, `concise`, `mobile` |
| storage | `storage-card`, `mobile`, `shell-first` |
| editor | `editor-card`, `concise`, `mobile` |
| hook | `hook-card`, `security-lab`, `concise` |
| shell | `shell-card`, `shell-first`, `mobile` |
| github | `github-card`, `security-lab`, `concise` |
| secrets | `secrets-card`, `security-lab`, `concise` |
| toolchain | `toolchain-card`, `shell-first`, `mobile` |
| tls | `tls-card`, `security-lab`, `concise` |
| net | `net-card`, `concise`, `mobile` |

Personas are applied via **role / resolution**, not a `spawn_subagent` parameter. Use the Personas tab or roles that reference them.

See [docs/CODING-TEAM.md](../docs/CODING-TEAM.md) and Grok user guide *Subagents*. New specialist persona: [agents/README.md — Adding a specialist](../agents/README.md#adding-a-specialist).

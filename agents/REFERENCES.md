# Agents — References Index

Canonical cross-links for every GrokHunter agent. Keep agent files lean; put shared maps here. Prefer this index over copying maps into agent prompts.

**Product version:** 1.0.9 · Overlay cache: 2026.2.18 · Grok Build: ≥ 1.0.5 · Default model: grok-4.6

| Related | Path |
|---------|------|
| Roster / CLI | [README.md](README.md) |
| Add a specialist | [README.md](README.md#adding-a-specialist) |
| Handoff cards | [HANDOFF-TEMPLATES.md](HANDOFF-TEMPLATES.md) |
| Skills index | [skills/REFERENCES.md](../skills/REFERENCES.md) |
| Skills roster | [skills/README.md](../skills/README.md) |
| Symptom → skill | [skills/PLAYBOOKS.md](../skills/PLAYBOOKS.md) |
| Protocol | [docs/CODING-TEAM.md](../docs/CODING-TEAM.md) |

## Core documents

| Doc | Use |
|-----|-----|
| `AGENTS.md` | Project rules for any agent session |
| `docs/CODING-TEAM.md` | Full Design → Build → Harden protocol + handoff cards |
| `docs/ARCHITECTURE.md` | Overlay layers, PATH, proot model |
| `docs/INSTALL.md` | Install flags, overlay-only, one-liner |
| `docs/TROUBLESHOOTING.md` | PATH, doctor, identity, X11 |
| `docs/FAQ.md` | Short answers (identity, overlay, models) |
| `docs/GROK-BUILD-1.0.md` | 1.0.5 compatibility |
| `docs/GROK-46.md` | Model catalog / pickers |
| `docs/EDITORS.md` | Aider, nvim, micro |
| `docs/SHELL.md` | profile.sh, completions, aliases |
| `docs/PROOT.md` | Binds, /tmp, storage placement |
| `docs/X11-PERFORMANCE.md` | Desktop lag / black screen |
| `CREDITS.md` | Four pillars — never weaken |

## Skills (playbooks)

| Skill | Paired agent(s) | Notes |
|-------|-----------------|-------|
| `grokhunter` | overlay (partial) | Install, doctor, PATH, models, skills CLI |
| `pair-programming` | coding-team, lucas | Session style for Grok 4.6 |
| `aider-grok` | aider | uv + Python 3.12 helper |
| `x11-desktop` | desktop | Black screen / lag triage |
| `github-lab` | github | `git-identity` playbook (ship still cuts releases) |
| `toolchain` | toolchain | apt, compilers, space |
| `grok-models` | models | V9 pickers / profile |
| `ci-lab` | ci | ci-unit + Smoke |
| `secrets-lab` | secrets | secrets.env mode 600 |
| `session-lab` | session | tmux + `grok --resume` |
| `host-lab` | host | Termux vs Kali detection |
| `mcp-lab` | mcp | `grok mcp` |
| `plugin-lab` | plugin | `grok plugin` |
| `flow-lab` | flow | `.rhai` workflows |
| `storage-lab` | storage | df / cache / --mini |
| `editor-lab` | editor | nvim / micro |
| `hooks-lab` | hook | `~/.grok/hooks` |
| `shell-lab` | shell | profile + completions |
| `nethunter-recon` | — | Optional, authorized scope only |

Full skill roster + decision tree: [skills/README.md](../skills/README.md) · [skills/PLAYBOOKS.md](../skills/PLAYBOOKS.md)

## Agent → skill / docs quick map

| Agent | Primary skill | Key docs |
|-------|---------------|----------|
| benjamin | — | CODING-TEAM, ARCHITECTURE |
| lucas | pair-programming | CODING-TEAM |
| harper | — | CODING-TEAM, ci-unit |
| coding-team | pair-programming | CODING-TEAM |
| scout | — | ARCHITECTURE, INSTALL |
| review | — | CODING-TEAM |
| fix | — | CODING-TEAM |
| desktop | x11-desktop | X11-PERFORMANCE, PROOT, `grokhunter binds` |
| overlay | grokhunter | INSTALL, TROUBLESHOOTING, `lib/tls.sh` |
| ship | github-lab (release notes only) | CHANGELOG, VERSION, FAQ |
| github | github-lab | FAQ, `grokhunter git-identity` |
| secrets | secrets-lab | secrets.env mode 600 |
| toolchain | toolchain | EDITORS, PROOT |
| docs | — | README, FAQ, website |
| models | grok-models | GROK-46, GROK-BUILD-1.0 |
| ci | ci-lab | smoke.yml, ci-unit.sh |
| aider | aider-grok | EDITORS |
| session | session-lab | SHELL |
| host | host-lab | PROOT, SHELL |
| mcp | mcp-lab | `~/.grok/docs/user-guide/07-mcp-servers.md` (Grok Build) |
| plugin | plugin-lab | `~/.grok/docs/user-guide/09-plugins.md` (Grok Build) |
| flow | flow-lab | create-workflow (bundled) |
| storage | storage-lab | PROOT, INSTALL |
| editor | editor-lab | EDITORS |
| hook | hooks-lab | `~/.grok/docs/user-guide/10-hooks.md` (Grok Build) |
| shell | shell-lab | SHELL |

## Shared hard rules (all agents)

Canonical copy for agent prompts. Skills index may summarize or link here.

- Never log, echo, or commit `XAI_API_KEY`, tokens, or private keys
- Prefer small, reversible changes; confirm before destructive ops
- Do not claim affiliation with xAI, Offensive Security, Termux, or jorexdeveloper
- Always credit the four pillars (CREDITS.md / `grokhunter credits`)
- Coding lab only — not a platform for unauthorized offensive activity
- Respect rootless / proot limits; do not invent Magisk, HID, or firmware capabilities
- Mobile-first output: short, paste-ready commands

## Personas & roles

See [personas/README.md](../personas/README.md) and [roles/README.md](../roles/README.md).  
Canonical agent / role / persona model: [roles/README.md](../roles/README.md).

Install agents + skills + personas + roles via `grokhunter skills install`.

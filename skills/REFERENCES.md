# Skills — References Index

Canonical cross-links for every GrokHunter skill. Keep individual `SKILL.md` files lean; put shared maps here.

**Product version:** 1.0.10 · Overlay cache: 2026.8.27 · Grok Build: ≥ 1.0.5 · Default model: grok-4.6

Paired index: [agents/REFERENCES.md](../agents/REFERENCES.md).

## Core documents

| Doc | Use |
|-----|-----|
| `AGENTS.md` | Project rules for any session |
| `docs/CODING-TEAM.md` | Design → Build → Harden + handoff cards |
| `docs/ARCHITECTURE.md` | Overlay layers, PATH, proot |
| `docs/INSTALL.md` | Install flags, overlay-only, one-liner |
| `docs/TROUBLESHOOTING.md` | PATH, doctor, identity, X11 |
| `docs/FAQ.md` | Short answers |
| `docs/GROK-BUILD-1.0.md` | 1.0.5 compatibility |
| `docs/GROK-46.md` | Model catalog / pickers |
| `docs/EDITORS.md` | Aider, nvim, micro |
| `docs/SHELL.md` | profile.sh, completions |
| `docs/PROOT.md` | Binds, /tmp, storage placement |
| `docs/X11-PERFORMANCE.md` | Desktop lag / black screen |
| `CREDITS.md` | Four pillars — never weaken |

## Skill → agent / docs map

| Skill | Primary agent(s) | Key docs / CLI |
|-------|------------------|----------------|
| `grokhunter` | overlay (partial) | INSTALL, TROUBLESHOOTING, `grokhunter doctor` |
| `pair-programming` | coding-team, lucas | CODING-TEAM, GROK-46 |
| `aider-grok` | aider | EDITORS, `scripts/install_aider.sh` |
| `x11-desktop` | desktop | X11-PERFORMANCE, PROOT, `grokhunter binds` |
| `github-lab` | github | FAQ, `grokhunter git-identity` |
| `toolchain` | toolchain | EDITORS, PROOT |
| `grok-models` | models | GROK-46, GROK-BUILD-1.0 |
| `ci-lab` | ci | `scripts/ci-unit.sh`, smoke.yml |
| `secrets-lab` | secrets | secrets.env mode 600 |
| `session-lab` | session | SHELL |
| `host-lab` | host | PROOT, SHELL |
| `mcp-lab` | mcp | user-guide/07-mcp-servers |
| `plugin-lab` | plugin | user-guide/09-plugins |
| `flow-lab` | flow | create-workflow (bundled) |
| `storage-lab` | storage | PROOT, INSTALL |
| `editor-lab` | editor | EDITORS |
| `hooks-lab` | hook | user-guide/10-hooks |
| `shell-lab` | shell | SHELL |
| `nethunter-recon` | — | Authorized scope only |
| `specialist-lab` | — (meta) | `agents/README.md` add recipe |
| `tls-lab` | tls | TROUBLESHOOTING, `lib/tls.sh` |
| `net-lab` | net | TROUBLESHOOTING (Network), `lib/https-probe.sh` |
| `tookie-osint` | tookie | Scoped username OSINT; `grokhunter tookie`; hits are leads |

## Skills-core vs optional

`grokhunter status` reports **skills N/3** for the core set used by doctor:

| Slot | Typical skill |
|------|----------------|
| 1 | `grokhunter` |
| 2 | `pair-programming` |
| 3 | `aider-grok` (or another installed lab skill depending on overlay) |

All other skills are **optional** — install via the same `grokhunter skills install` (full tree) or by copying individual folders.

## Shared hard rules (all skills)

- Never log, echo, or commit `XAI_API_KEY`, tokens, or private keys
- Prefer small, reversible changes; confirm before destructive ops
- Do not claim affiliation with xAI, Offensive Security, Termux, or jorexdeveloper
- Always credit the four pillars (CREDITS.md / `grokhunter credits`)
- Coding lab only by default
- Respect rootless / proot limits; do not invent Magisk, HID, or firmware capabilities
- Mobile-first output: short, paste-ready commands

## Install paths

| Scope | Path |
|-------|------|
| User (default) | `~/.grok/skills/<name>/SKILL.md` |
| Project | `.grok/skills/<name>/SKILL.md` |
| Repo source | `skills/<name>/SKILL.md` |

```bash
grokhunter skills install
grokhunter skills status
grok inspect
```

## Related trees

| Tree | Role |
|------|------|
| `agents/` | Runtime agent system prompts — add recipe in [agents/README.md](../agents/README.md#adding-a-specialist) |
| `personas/` | Tone + card contracts |
| `roles/` | Capability mode + reasoning effort |
| `config/` | Completions, desktop entries, profile |
| `docs/` | Operator-facing documentation |

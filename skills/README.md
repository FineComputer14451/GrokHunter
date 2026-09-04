# GrokHunter skills (Grok Build 1.0.5+)

These are **Grok Build skill definitions** (playbooks). Grok loads `SKILL.md` when the skill is discovered under `~/.grok/skills/` or project `.grok/skills/`.

**Product version:** 1.0.10 · Grok Build ≥ 1.0.5 · Default model: **grok-4.6**

Skills are **playbooks** (how to do a thing). Agents are **runtime specialists** (who does it). See [agents/README.md](../agents/README.md). Full agent / role / persona map: [roles/README.md](../roles/README.md) · [agents/REFERENCES.md](../agents/REFERENCES.md). Adding a new specialist: [agents/README.md — Adding a specialist](../agents/README.md#adding-a-specialist).

## Supporting files

| File | Purpose |
|------|---------|
| [REFERENCES.md](REFERENCES.md) | Cross-index: skills ↔ agents ↔ docs, hard rules |
| [PLAYBOOKS.md](PLAYBOOKS.md) | Decision tree — which skill for which symptom |
| [../agents/REFERENCES.md](../agents/REFERENCES.md) | Agent-side index (paired) |
| [../docs/CODING-TEAM.md](../docs/CODING-TEAM.md) | Multi-agent protocol |

## Layers

| Layer | Skills | Role |
|-------|--------|------|
| **Core** | `grokhunter`, `pair-programming` | Lab orchestrator + coding session style |
| **Primary tools** | `aider-grok`, `x11-desktop` | Aider + Termux:X11 desktop |
| **Optional lab** | 17 `*-lab` / toolchain skills | Narrow phone-environment playbooks |
| **Scoped** | `nethunter-recon`, `tookie-osint` | Authorized recon / public username OSINT — not product default |

## Roster

### Core

| Skill | Activate for |
|-------|----------------|
| [`grokhunter`](grokhunter/SKILL.md) | Install, doctor, PATH, models, skills CLI, overlay-only, SpaceXAI smoke |
| [`pair-programming`](pair-programming/SKILL.md) | Writing / debugging / reviewing code with Grok 4.6 |

### Primary tools

| Skill | Activate for |
|-------|----------------|
| [`aider-grok`](aider-grok/SKILL.md) | Aider + xAI / uv Python 3.12 |
| [`x11-desktop`](x11-desktop/SKILL.md) | Black screen, lag, nh-x11 recovery |

### Optional lab specialists

| Skill | Activate for |
|-------|----------------|
| [`github-lab`](github-lab/SKILL.md) | Git identity / invalid-email-address |
| [`toolchain`](toolchain/SKILL.md) | apt, compilers, Aider Python, space |
| [`grok-models`](grok-models/SKILL.md) | V9 pickers / profile / models=no |
| [`ci-lab`](ci-lab/SKILL.md) | ci-unit.sh / Smoke red |
| [`secrets-lab`](secrets-lab/SKILL.md) | secrets.env / XAI_API_KEY |
| [`session-lab`](session-lab/SKILL.md) | tmux / grok --resume |
| [`host-lab`](host-lab/SKILL.md) | Termux host vs Kali guest |
| [`mcp-lab`](mcp-lab/SKILL.md) | grok mcp list / doctor |
| [`plugin-lab`](plugin-lab/SKILL.md) | grok plugin / marketplace |
| [`flow-lab`](flow-lab/SKILL.md) | .rhai workflows / /workflow |
| [`storage-lab`](storage-lab/SKILL.md) | df / cache / --mini |
| [`editor-lab`](editor-lab/SKILL.md) | nvim / micro |
| [`hooks-lab`](hooks-lab/SKILL.md) | ~/.grok/hooks / /hooks |
| [`shell-lab`](shell-lab/SKILL.md) | profile.sh / completions / ghd |
| [`specialist-lab`](specialist-lab/SKILL.md) | Add a lab agent/skill (recipe in agents/README) |
| [`tls-lab`](tls-lab/SKILL.md) | Kali CA / `SSL_CERT_FILE` |
| [`net-lab`](net-lab/SKILL.md) | x.ai probe / guest DNS |

### Scoped / legacy

| Skill | Activate for |
|-------|----------------|
| [`nethunter-recon`](nethunter-recon/SKILL.md) | **Authorized** lab/CTF/engagement only — not the default mission |
| [`tookie-osint`](tookie-osint/SKILL.md) | **Authorized** public username discovery (Tookie-OSINT) — leads not identity |

## Install

```bash
grokhunter skills install
# → ~/.grok/skills/{name}/SKILL.md
# also installs agents + personas + roles

grokhunter skills status
grok inspect    # Skills: grokhunter, pair-programming, …
```

Project-local: copy the same trees under `.grok/skills/`.

## Decision tree

See [PLAYBOOKS.md](PLAYBOOKS.md) for symptom → skill routing.

Quick path:

```text
Lab broken / install / PATH     → grokhunter
Writing code                    → pair-programming (+ coding-team agents)
Aider missing / Python 3.13     → aider-grok
X11 black / lag / binds / bwrap → x11-desktop (`grokhunter binds`)
GitHub invalid-email            → github-lab (agent `github`)
models=no / pickers             → grok-models
Termux vs Kali confusion        → host-lab
Disk full                       → storage-lab
TAB / ghd missing               → shell-lab
New lab agent / skill           → specialist-lab
TLS / SSL_CERT_FILE / CA        → tls-lab (agent `tls`)
x.ai offline / DNS              → net-lab (agent `net`)
Authorized username footprint   → tookie-osint (agent `tookie`)
```

## Hard rules (all skills)

- Never log, echo, or commit secrets
- Prefer small, reversible changes
- Do not claim affiliation with xAI, Offensive Security, Termux, or jorexdeveloper
- Always credit the four pillars (`CREDITS.md` / `grokhunter credits`)
- Coding lab only by default — `nethunter-recon` and `tookie-osint` require explicit authorized scope
- Respect rootless / proot limits; no Magisk/HID/firmware claims

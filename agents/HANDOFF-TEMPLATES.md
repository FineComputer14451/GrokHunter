# Agents — Handoff Card Templates

Keep cards short on mobile. Copy the section you need; fill only the relevant lines.

Canonical protocol: `docs/CODING-TEAM.md`.

---

## Design card (benjamin → lucas)

```markdown
## Goal
## Constraints (offline / battery / storage / security / shell-vs-X11)
## Approach
## Critical files
## Acceptance criteria
## Out of scope
## Security notes
## Handoff → Lucas | Harper | scout
```

---

## Build card (lucas → harper)

```markdown
## Files changed
- path — what / why
## How to run / smoke
## Known gaps
## Handoff → harper | benjamin | fix
```

---

## Harden card (harper)

```markdown
## Risks
- blocker: …
- important: …
- minor: …
## Repro steps
## Pass / fail
## Send back → lucas | benjamin | fix
## Tests added / run
```

---

## Map card (scout)

```markdown
## Question
## Answer (short)
## Key paths
- path — why it matters
## Call / data flow (if relevant)
## Risks / surprises
## Suggested next agent
benjamin | lucas | harper | review | fix | desktop | overlay | host | coding-team
```

---

## Review card (review)

```markdown
## Summary
## Findings
### Blocker
- file:line — issue — suggested direction
### Important
- …
### Minor
- …
## What looks good
## Suggested next agent
lucas | fix | harper | benjamin
```

---

## Fix card (fix)

```markdown
## Failure (1 line)
## Root cause
## Patch
- files touched
## Smoke
## Residual risk
## Handoff (if any)
harper | lucas | benjamin | none
```

---

## Desktop card (desktop)

```markdown
## Symptom
## Diagnosis
## Fix applied / recommended commands
## Verify
grokhunter binds status / nh-x11
## Escalate
lucas (script bugs) | benjamin (design) | harper (regressions) | overlay (install patch)
```

---

## Overlay card (overlay)

```markdown
## Symptom
## Overlay root / cache
## Commands
## Verify (doctor / which grokhunter)
## Escalate
desktop | lucas | ship | benjamin | tls
```

---

## Ship card (ship)

```markdown
## Version
## Files bumped
## Overlay cache
## Upgrade snippet
## Tag / release notes
## Blockers
```

---

## Docs card (docs)

```markdown
## Question / drift
## Canonical home
## Files to change (or none)
## Suggested copy (short)
## Escalate
ship | overlay | lucas
```

---

## Models card (models)

```markdown
## Symptom
## Binary / profile / pickers
## Commands
## Verify
```

---

## CI card (ci)

```markdown
## Failure
## Local / Actions
## Patch
## Re-run command
```

---

## Aider card (aider)

```markdown
## Symptom
## Python / uv / helper
## Commands
## Verify
```

---

## Session card (session)

```markdown
## Symptom
## Host / guest / tmux
## Commands
## Verify
```

---

## Host card (host)

```markdown
## Symptom
## Host or guest
## Commands
## Verify
## Escalate
overlay | desktop | toolchain
```

---

## MCP card (mcp)

```markdown
## Symptom
## Servers / transport
## Commands
## Verify (grok mcp doctor)
```

---

## Plugin card (plugin)

```markdown
## Symptom
## Marketplace / plugin
## Commands
## Verify (grok plugin list)
```

---

## Flow card (flow)

```markdown
## Goal
## Path (.rhai)
## Budget
## How to run
```

---

## Storage card (storage)

```markdown
## Symptom
## df / hot dirs
## Commands
## Verify
```

---

## Editor card (editor)

```markdown
## Symptom
## Tool
## Commands
## Verify
```

---

## Hook card (hook)

```markdown
## Symptom
## Scope (user / project)
## Commands
## Verify (/hooks)
```

---

## Shell card (shell)

```markdown
## Symptom
## rc / profile
## Commands
## Verify (type ghd / TAB)
```

---

## GitHub card (github)

```markdown
## Symptom
## Identity
## Commands
## Verify (grokhunter git-identity)
```

---

## Secrets card (secrets)

```markdown
## Symptom
## File / mode
## Commands
## Verify (ai-smoke — never print the key)
```

---

## Toolchain card (toolchain)

```markdown
## Symptom
## Packages
## Commands
## Verify
```

---

## TLS card (tls)

```markdown
## Symptom
## Env / CA
## Commands
## Verify (doctor TLS — never print certs)
```

---

## Net card (net)

```markdown
## Symptom
## http_code / DNS
## Commands
## Verify (doctor x.ai — never print bodies)
```

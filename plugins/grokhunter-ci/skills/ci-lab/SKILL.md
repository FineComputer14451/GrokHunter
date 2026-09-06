---
name: ci-lab
description: >-
  Use when GrokHunter ci-unit.sh fails, GitHub Actions Smoke is red, or before
  pushing overlay changes.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/ci-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI; no unauthorized offensive activity.

# CI lab (optional)

You run and interpret **local unit checks** and **GitHub Actions Smoke** for the GrokHunter overlay. Product tests live in `scripts/ci-unit.sh` — do not invent a second runner.

## When to activate

- `ci-unit` fails or was not run
- Smoke workflow red on `main`
- User asks “are tests green?” before a push

## Local (always first)

```bash
bash scripts/ci-unit.sh
```

Covers: `bash -n`, CLI help, git-identity, doctor probes, overlay extract, skills/agents install.

## GitHub

- Smoke: `.github/workflows/smoke.yml` (push/PR `main`)
- Site: `.github/workflows/deploy-website.yml` on `website/**`

`GITHUB_TOKEN` pushes from Actions do not retrigger workflows. Dispatch Smoke manually if a bot push skipped it. Do not invent credentials; see skill `github-lab`.

## Common failures

| Symptom | First step |
|---------|------------|
| Red locally | `bash scripts/ci-unit.sh` first |
| Smoke skipped on bot push | Dispatch Smoke |
| No HTTPS push on this lab | skill `github-lab` |

## Cross-links

- Agent `ci` for failing jobs
- Agent `harper` for product test design
- Agent `ship` after green CI on a release

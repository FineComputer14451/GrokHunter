---
name: ci-lab
description: >-
  GrokHunter CI: scripts/ci-unit.sh, GitHub Actions smoke.yml, website
  deploy-website.yml. Use when unit checks fail, Smoke is red, or before
  pushing overlay changes. Optional skill — not part of skills-core N/3.
---

# CI lab (optional)

You run and interpret **local unit checks** and **GitHub Actions Smoke** for this overlay. Product tests live in `scripts/ci-unit.sh` — do not invent a second runner.

## When to activate

- `ci-unit` fails or was not run
- Smoke workflow red on `main`
- User asks “are tests green?” before a push
- SIGPIPE / bash -n / find syntax in CI

## Local (always first)

```bash
bash scripts/ci-unit.sh
```

Covers: `bash -n`, CLI help, git-identity, doctor probes, overlay extract, skills/agents install. No network required for core checks.

## GitHub

- Smoke: `.github/workflows/smoke.yml` (push/PR `main`) — runs `ci-unit.sh`
- Site: `.github/workflows/deploy-website.yml` on `website/**`

`GITHUB_TOKEN` pushes from Actions **do not** retrigger workflows. Dispatch Smoke manually if a bot push skipped it.

This lab often cannot `git push` over HTTPS. Do not invent credentials; see skill `github-lab`.

## Cross-links

- Agent `ci` for failing jobs / adding assertions
- Agent `harper` for product test design
- Agent `ship` after green CI on a release

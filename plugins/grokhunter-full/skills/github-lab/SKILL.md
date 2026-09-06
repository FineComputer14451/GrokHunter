---
name: github-lab
description: >-
  Use when GrokHunter git commits show as root/kali@localhost,
  invalid-email-address, or GitHub cannot map the author — git-identity and
  noreply fixes.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/github-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# GitHub lab (optional)

You keep this lab's git author **attached to a GitHub account**. Identity algorithm lives in `lib/git-identity.sh` and the `grokhunter` skill — do not re-specify resolution order here.

## When to activate

- GitHub shows `invalid-email-address` or `root`
- `git identity: unset` / doctor placeholder warning
- `gh: command not found` but the user still needs attributable commits
- First commit from a fresh proot

## First command

```bash
grokhunter git-identity set
grokhunter git-identity
grokhunter doctor
```

Sources (first match): `--name/--email`, `GROKHUNTER_GIT_NAME` / `GROKHUNTER_GIT_EMAIL`, `gh api user`, `GH_TOKEN` / `GITHUB_TOKEN`, GitHub `origin` owner.

## Noreply

From GitHub settings/emails: `ID+LOGIN@users.noreply.github.com`

`.mailmap` in the overlay maps leftover `root@localhost` locally only.

## `gh` is optional

Identity does not require GitHub CLI. Origin fallback is enough on a clone of `github.com/OWNER/repo`. Install `gh` only if the user needs PRs/releases from the phone. Never print tokens.

## Common failures

| Symptom | First step |
|---------|------------|
| `invalid-email-address` / `root` | `grokhunter git-identity set` |
| `gh api` TLS / missing CA | skill `tls-lab` |
| No `gh` CLI | Origin fallback is enough |

## Hard rules

- Never log or commit `XAI_API_KEY`, `GH_TOKEN`, or private keys
- Prefer `git config --global` so every repo on the lab is attributable
- Do not rewrite published history unless the user explicitly asks

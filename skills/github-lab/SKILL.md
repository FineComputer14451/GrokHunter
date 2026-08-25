---
name: github-lab
description: >-
  GitHub-attributable commits on the GrokHunter lab: invalid-email-address,
  git-identity, noreply addresses, optional gh CLI. Use when commits show as
  root/kali@localhost or GitHub cannot map the author. Optional skill — not
  part of skills-core N/3.
---

# GitHub lab (optional)

You keep this lab's git author **attached to a GitHub account**. Identity **algorithm lives in** `lib/git-identity.sh` and the `grokhunter` skill — do not re-specify resolution order here.

**Not affiliated** with xAI, Offensive Security, Termux, or jorexdeveloper.

## When to activate

- GitHub shows `invalid-email-address` or `root`
- `git identity: unset` / doctor placeholder warning
- `gh: command not found` but the user still needs attributable commits
- First commit from a fresh proot

## First command

```bash
grokhunter git-identity set
```

Sources (first match): `--name/--email`, `GROKHUNTER_GIT_NAME` / `GROKHUNTER_GIT_EMAIL`, `gh api user`, `GH_TOKEN` / `GITHUB_TOKEN`, GitHub `origin` owner.

Show:

```bash
grokhunter git-identity
grokhunter doctor    # Git identity section
```

## Noreply

From [settings/emails](https://github.com/settings/emails):

```text
ID+LOGIN@users.noreply.github.com
```

Example shape: `119702188+FineComputer14451@users.noreply.github.com`.

`.mailmap` in the overlay maps leftover `root@localhost` **locally** only.

## `gh` is optional

Identity does **not** require GitHub CLI. Origin fallback is enough on a clone of `github.com/OWNER/repo`.

Install `gh` only if the user needs PRs/releases from the phone (`apt install gh` or GitHub's linux aarch64 binary). Never print tokens.

## Common failures

| Symptom | First step |
|---------|------------|
| `invalid-email-address` / `root` | `grokhunter git-identity set` |
| `gh api` TLS / missing CA | `lib/tls.sh` sanitizes `SSL_CERT_FILE`; do not paste certs |
| No `gh` CLI | Origin fallback is enough; `gh` is optional |

## Verify

```bash
grokhunter git-identity
```

## Hard rules

- Never log or commit `XAI_API_KEY`, `GH_TOKEN`, or private keys
- Prefer `git config --global` so every repo on the lab is attributable
- Do not rewrite published history unless the user explicitly asks
- Hard rules: `skills/REFERENCES.md`

## Cross-links

- Agent `github` (`grokhunter github` launches the agent; CLI is `grokhunter git-identity`)
- CLI + doctor: skill `grokhunter`
- Docs: `docs/FAQ.md`, `docs/TROUBLESHOOTING.md`
- Agent `ship` for VERSION/changelog/tag — not this skill
- MCP GitHub *tools*: skill `mcp-lab` (`grok mcp`) — not identity

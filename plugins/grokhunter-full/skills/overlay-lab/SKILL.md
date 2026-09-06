---
name: overlay-lab
description: >-
  GrokHunter installer and overlay cache: install.sh, MODULES_VERSION,
  --overlay-only, PATH wrappers, command-not-found after overlay. Use when
  wrappers are missing, cache is stuck, or overlay dest looks wrong. Optional
  skill — not part of skills-core N/3.
---

# Overlay lab (optional)

You own **install.sh / overlay cache / PATH wrappers**. Product features stay Lucas/fix. X11 / `grokhunter binds` stay `x11-desktop` / agent `desktop`. Domain tables live on agent `overlay` — do not copy them here.

## When to activate

- `grokhunter: command not found` after install or overlay-only
- User asks about `install.sh`, `MODULES_VERSION`, or `~/.cache/grokhunter/`
- Wrappers missing from `~/.local/bin` / PATH after overlay
- One-liner extract landed on `/dev/fd` (never treat that as overlay root)

## First commands

Prefer overlay-only when Kali already exists (needs at least one `--with-*`):

```bash
bash install.sh --overlay-only --with-grok --with-completions
source ~/.grok/profile.sh
which grokhunter
grokhunter status
```

Cache refresh when stuck:

```bash
GROKHUNTER_REFRESH=1 bash install.sh --overlay-only --with-grok
# or bump MODULES_VERSION per docs/INSTALL.md
```

## Common failures

| Symptom | First step |
|---------|------------|
| `grokhunter: command not found` | overlay-only + `source ~/.grok/profile.sh`; check host vs guest (`host-lab`) |
| Cache stuck / stale modules | `GROKHUNTER_REFRESH=1` or bump `MODULES_VERSION` |
| Wrappers missing after install | `install_cli_bins` → `~/.local/bin` on PATH |
| One-liner extracts to `/dev/fd` | Never use `/dev/fd` as overlay root; re-extract to a real dest |
| `SSL_CERT_FILE` / missing `/etc/tls/cert.pem` | Install symlink is overlay; runtime sanitize → `tls-lab` / agent `tls` |
| Black screen / binds / bwrap | Escalate → `x11-desktop` / agent `desktop` (`grokhunter binds`) |

## Verify

```bash
which grokhunter
grokhunter doctor
grokhunter status
# expect wrappers on PATH; overlay root not /dev/fd
```

## Hard rules

- Never print secrets
- Prefer `--overlay-only` over re-downloading Kali
- Do not claim Magisk/root — this is proot
- Optional skill — leave `skills=N/3` alone
- Credit jorexdeveloper / Termux / Kali / xAI (`CREDITS.md`)

## Cross-links

- Agent `overlay` (`grok --agent overlay` / Coding Team spawn)
- Skill `grokhunter` — fresh bootstrap / doctor / skills CLI
- Skill `host-lab` — Termux host vs Kali guest PATH
- Skill `x11-desktop` — binds / nh-x11 / bwrap (not this playbook)
- Skill `tls-lab` — runtime `SSL_CERT_FILE` (install symlink still overlay)
- Skill `storage-lab` — disk / cache cleanup
- Docs: `docs/INSTALL.md`, `docs/TROUBLESHOOTING.md`
- Recipe: `agents/README.md` (skill-only); meta skill `specialist-lab`

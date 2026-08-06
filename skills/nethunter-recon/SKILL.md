---
name: nethunter-recon
description: >-
  Authorized reconnaissance and lab assessment helper for Kali NetHunter.
  Optional/legacy — not the product default. Use only when the operator has
  explicit authorized scope (lab, CTF, engagement).
---

# NetHunter Recon Skill (legacy / optional)

GrokHunter’s **default mission is a coding & building lab**. This skill is optional for **authorized** lab/CTF/engagement work only — not the product default.

For install, doctor, PATH, Grok, Aider, or desktop setup, use the **`grokhunter`** skill instead.

You assist with **authorized** reconnaissance and assessment on Kali NetHunter, orchestrated through Grok Build when requested.

## Activation

- `ACTIVATE NETHUNTER RECON`
- User is in-scope for a lab, CTF, bug bounty, or written engagement
- Needs structured recon plans, command recipes, or report drafts

## Preconditions (always confirm)

Before active scanning or intrusive checks, confirm:

1. **Target scope** (IPs, domains, SSIDs, apps) is authorized
2. **Rules of engagement** (timing, DoS limits, data handling)
3. **Environment** (lab VLAN vs production)

If scope is missing or clearly unauthorized → **refuse** and explain why.

## Preferred workflow

1. **Scope card** — one short block restating authorized targets
2. **Passive first** — OSINT, DNS, public certs, metadata (when in scope)
3. **Active recon** — only after confirmation; prefer rate-limited scans
4. **Evidence** — save outputs under `~/scans/<engagement>/` with timestamps
5. **Report** — findings with severity, evidence path, remediation

## Command recipes (examples — adjust to scope)

```bash
# Engagement folder
ENG="~/scans/$(date +%Y%m%d)-lab"
mkdir -p "$ENG"/{nmap,notes,evidence}

# Discovery (authorized subnet only)
nmap -sn <CIDR> -oA "$ENG/nmap/ping-sweep"

# Service inventory
nmap -sV -sC -oA "$ENG/nmap/svc" <targets>

# Quick local posture on the chroot itself
ss -tulpn | tee "$ENG/notes/local-listeners.txt"
```

## NetHunter-specific notes

- **Wireless / HID / USB attacks** often depend on the **Android host** and NetHunter app, not only the chroot. Document host prerequisites; do not invent capabilities.
- Prefer existing `nethunter-utils` scripts when present after verifying they match the Android version.
- Keep heavy scans off battery-critical sessions; use `tmux`.
- Rootless GrokHunter does **not** claim Magisk/HID/firmware modules; coding lab only by default.

## Output format

```markdown
## Scope
- ...

## Actions taken
- ...

## Findings
| ID | Severity | Title | Evidence |

## Next steps
- ...

## Residual risk
- ...
```

## Hard refusals

- Unauthorized intrusion, credential stuffing against third parties
- Malware / ransomware packaging
- Bypass of safety for clearly criminal intent

Defensive review of local configs, CTF writeups, and owned lab targets are in-scope when the user states ownership/permission.

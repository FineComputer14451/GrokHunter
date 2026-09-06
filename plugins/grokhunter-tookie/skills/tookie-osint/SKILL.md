---
name: tookie-osint
description: >-
  Authorized public username discovery with Tookie-OSINT (Sherlock-class).
  Scoped lab module — not the product default. Install or verify the CLI,
  scan one handle with -sC, triage hits as leads. Activate on tookie,
  username scan, social footprint, /tookie-scan, ACTIVATE TOOKIE INVESTIGATOR.
---

# Tookie-OSINT (scoped)

GrokHunter’s **default mission is a coding lab**. This skill is for **authorized**
public-source username lookup only — training, research, or an engagement the
operator already owns. Hits are **leads**, not identity proof.

Upstream CLI — https://github.com/Alfredredbird/tookie-osint (MIT).
Do not vendor the Python tool in this repo. Do not claim affiliation with
Alfredredbird, xAI, Offensive Security, or Termux.

| Need | Use |
|------|-----|
| Install / doctor / PATH | **`grokhunter`** |
| Authorized username footprint | **this skill** + agent `tookie` |
| Broader authorized recon | **`nethunter-recon`** |

## Activation

- `ACTIVATE TOOKIE INVESTIGATOR`
- `/tookie-scan` `/tookie-install` `/tookie-batch`
- User asks for a Sherlock-like handle check and states authorization

## Preconditions

1. Purpose is authorized public OSINT, training, or research.
2. Handle is a public username — not a path (`../`, `/`, `\\`).
3. CLI exists or will be installed into a user-writable venv (no sudo on phone).

If the request looks like stalking, doxxing, harassment, or account access — **refuse**.

## Install (rootless first)

```bash
# detect
command -v tookie-osint && tookie-osint -h

# Termux / proot / GrokHunter — no sudo
git clone https://github.com/Alfredredbird/tookie-osint.git
cd tookie-osint
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 brib.py -h
```

Kali package (`sudo apt install tookie-osint`) only on a real Kali host when the user asked.

Helpers in this skill:

```bash
bash skills/tookie-osint/scripts/detect-tookie.sh
bash skills/tookie-osint/scripts/safe-username.sh HANDLE
```

Sanitize handles. GHSA-rp68-wfv6-3cq3 is a path-traversal advisory on username / output names.

## Scan

Always use script mode in agent runs. Skip Selenium `-W`/`-H` on phones.

```bash
# single
tookie-osint -u HANDLE -sC -o json -t 2

# batch (one name per line)
tookie-osint -U users.txt -sC -o csv -t 2

# from a source checkout
python3 brib.py -u HANDLE -sC -o json -t 2
```

`-W` cannot combine with custom `-t` (upstream exits 1).
Wiki examples that use `--username` / `--site` are stale — do not use them.

## Triage

```text
Username:
Authorization:
Command:
Hits: N
- site — url
Uncertain / errors:
Next public checks:
Limits: leads not identity; false positives exist
```

Never invent URLs. Timeouts are not “username missing”.

## Phone constraints

- Threads start at 2, cap at 4
- One handle before a batch file
- No Magisk / HID / firmware claims

## Hard refusals

- Stalking, harassment, doxxing, intimidation
- Logins, token reuse, private APIs, account takeover
- Fabricated scan output

## After OSINT (return to coding lab)

```bash
grokhunter doctor
grok
```

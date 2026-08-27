---
name: tls-lab
description: >-
  GrokHunter TLS and CA on the phone lab: SSL_CERT_FILE, Kali CA bundle,
  injected /etc/tls/cert.pem, doctor TLS probe, clock-skew cert fails. Use
  when curl/gh SSL errors, CA is missing, or doctor warns about TLS. Optional
  skill — not part of skills-core N/3.
---

# TLS lab (optional)

You keep **HTTPS working** inside Kali when Termux/Grok inject a missing `SSL_CERT_FILE`. Algorithm lives in `lib/tls.sh` — do not re-specify it here. Never print certificate PEM.

**Not affiliated** with xAI, Offensive Security, Termux, or jorexdeveloper.

## When to activate

- `SSL_CERT_FILE=/etc/tls/cert.pem` and the path is missing
- curl / `gh api` SSL or CA errors
- Doctor TLS / CA warning (x.ai *offline* is skill `net-lab`)
- Phone clock in 1970 (certs look expired)

## First commands

```bash
echo "SSL_CERT_FILE=${SSL_CERT_FILE:-unset}"
test -r "${SSL_CERT_FILE:-/}" && echo cert-file-readable || echo cert-file-missing
test -r /etc/ssl/certs/ca-certificates.crt && echo kali-ca-ok
ls -l /etc/tls/cert.pem 2>/dev/null || echo 'no /etc/tls/cert.pem'
date -u
grokhunter doctor
```

Do not `cat` those files.

## Common failures

| Symptom | First step |
|---------|------------|
| `SSL_CERT_FILE` missing `/etc/tls/cert.pem` | `lib/tls.sh` sanitize; overlay writes the install symlink |
| curl/gh SSL error, date in 1970 | set Android time; retry |
| Cloudflare 403 / API 401 | skill `net-lab` — reachable, not a CA fail |
| No Kali CA bundle | `host` (are you in the guest?) then overlay-only |

## Verify

```bash
[[ -z "${SSL_CERT_FILE:-}" || -r "${SSL_CERT_FILE}" ]] && echo tls-env-ok
grokhunter doctor    # TLS / CA rows — never print certs
```

## Hard rules

- Never log, paste, or commit certificate PEM or private keys
- Overlay still *installs* `/etc/tls` compat; this skill owns runtime
- Hard rules: `skills/REFERENCES.md`

## Cross-links

- Agent `tls` (`grokhunter tls` launches the agent)
- Install symlink: agent `overlay`
- `gh api` identity: skill `github-lab` (CA failures stay here)
- Doctor product: skill `grokhunter`
- x.ai offline / `http_code=000`: skill `net-lab` / agent `net`

---
name: tls-lab
description: >-
  Use when GrokHunter curl/gh SSL fails, SSL_CERT_FILE/CA is missing, or doctor
  warns about TLS / clock-skew certs.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/tls-lab` (v1.0.10).
Hard rules: never print secrets or cert PEM; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# TLS lab (optional)

You keep **HTTPS working** inside Kali when Termux/Grok inject a missing `SSL_CERT_FILE`. Algorithm lives in `lib/tls.sh`. Never print certificate PEM.

## When to activate

- `SSL_CERT_FILE=/etc/tls/cert.pem` and the path is missing
- curl / `gh api` SSL or CA errors
- Doctor TLS / CA warning (x.ai offline is skill `net-lab`)
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
| `SSL_CERT_FILE` missing `/etc/tls/cert.pem` | `lib/tls.sh` sanitize; overlay install symlink |
| curl/gh SSL error, date in 1970 | set Android time; retry |
| Cloudflare 403 / API 401 | skill `net-lab` — reachable, not a CA fail |
| No Kali CA bundle | confirm guest (skill `host-lab`) then overlay-only |

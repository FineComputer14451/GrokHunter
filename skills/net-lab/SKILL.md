---
name: net-lab
description: >-
  GrokHunter HTTPS reachability on the phone lab: x.ai probe, http_code 000
  vs Cloudflare 403 / API 401, guest DNS. Use when doctor says offline or no
  route to x.ai, curl returns 000, or resolv.conf is empty. Optional skill —
  not part of skills-core N/3.
---

# Net lab (optional)

You keep **false “offline” alarms** from blocking the lab. Algorithm lives in `lib/https-probe.sh` — do not re-specify it here. 401 / 403 means the host was reached. Never print response bodies.

**Not affiliated** with xAI, Offensive Security, Termux, or jorexdeveloper.

## When to activate

- Doctor: Offline or no route to x.ai
- curl `http_code=000` / timeout
- Empty `/etc/resolv.conf` in the Kali guest
- User asks if the phone can reach api.x.ai

## First commands

```bash
curl -sS -o /dev/null -w '%{http_code}\n' --max-time 5 https://api.x.ai/v1/models
# 401 = online (no key). 403 = reachable (Cloudflare). 000 = no route / DNS / TLS.
cat /etc/resolv.conf
grokhunter doctor
```

Do not dump the HTTP body.

## Common failures

| Symptom | First step |
|---------|------------|
| Doctor offline / no route to x.ai | probe; 401/403 = reachable |
| `http_code=000` | guest DNS; else phone data/Wi-Fi/VPN |
| SSL error / clock 1970 / missing CA | skill `tls-lab` |
| `ai-smoke` missing-key | skill `secrets-lab` |

## Verify

```bash
curl -sS -o /dev/null -w '%{http_code}\n' --max-time 5 https://api.x.ai/v1/models
grokhunter doctor    # x.ai line — 403/401 are OK
```

## Hard rules

- Never log response bodies, keys, or certs
- Offline lab is still OK for local coding
- Hard rules: `skills/REFERENCES.md`

## Cross-links

- Agent `net` (`grokhunter net` launches the agent)
- CA / `SSL_CERT_FILE`: skill `tls-lab` / agent `tls`
- API key: skill `secrets-lab`
- Doctor product: skill `grokhunter`

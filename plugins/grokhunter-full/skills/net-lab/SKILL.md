---
name: net-lab
description: >-
  Use when GrokHunter doctor says offline/no route to x.ai, curl returns
  http_code 000, or guest DNS/resolv.conf is broken.
---
# Source
Ported from FineComputer14451/GrokHunter `skills/net-lab` (v1.0.10).
Hard rules: never print secrets; coding lab mission; credit jorexdeveloper, Termux, Kali/OffSec, xAI.

# Net lab (optional)

You keep **false “offline” alarms** from blocking the lab. Algorithm lives in `lib/https-probe.sh`. 401 / 403 means the host was reached. Never print response bodies.

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

## Common failures

| Symptom | First step |
|---------|------------|
| Doctor offline / no route to x.ai | probe; 401/403 = reachable |
| `http_code=000` | guest DNS; else phone data/Wi-Fi/VPN |
| SSL error / clock 1970 / missing CA | skill `tls-lab` |
| `ai-smoke` missing-key | skill `secrets-lab` |

## Hard rules

- Never log response bodies, keys, or certs
- Offline lab is still OK for local coding

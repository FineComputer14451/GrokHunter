---
name: grokhunter-doctor
description: Run or explain grokhunter doctor / status repair for the phone lab
---

Help the user health-check GrokHunter Rootless.

1. Confirm they are on Termux Android (or advising remote paste-ready commands).
2. Give paste-ready:

```bash
grokhunter doctor
grokhunter status
```

3. Route failures to the matching skill (tls-lab, net-lab, secrets-lab, host-lab, x11-desktop, github-lab).
4. Never print secrets.

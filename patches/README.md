# Code patches

## pr2-code.patch

Applies the remaining three code changes from the UX review:

1. **install.sh** — prefer `vendor/termux-distro.sh` + optional `GROKHUNTER_DISTRO_ENGINE_SHA256`
2. **lib/grok.sh** — clearer incomplete-overlay messaging
3. **bin/grokhunter-doctor** — Overlay completeness section

### Apply (from repo root on main)

```bash
git checkout main
git pull
git checkout -b apply-pr2-code
git apply patches/pr2-code.patch
# or:  patch -p1 < patches/pr2-code.patch
git add install.sh lib/grok.sh bin/grokhunter-doctor
git commit -m "Prefer vendor engine + overlay completeness in doctor/grok"
```

### Verify

```bash
# Should mention vendor/ priority
grep -n 'vendor/termux-distro' install.sh

# Doctor section
grep -n 'Overlay completeness' bin/grokhunter-doctor

# Overlay messaging
grep -n 'Full overlay' lib/grok.sh
```

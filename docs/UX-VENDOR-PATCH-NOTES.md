# UX + vendor engine improvements (v1.0.8 prep)

This branch applies:

1. **lib/actions.sh** — post-install full-overlay nudge when one-liner is used
2. **README.md** — recommended full stack first; one-liner note; reproducible/offline section
3. **docs/ARCHITECTURE.md** — vendoring priority + SHA pin docs
4. **vendor/README.md** — how to vendor termux-distro.sh

## Remaining code patches (apply locally or follow-up PR)

See the review conversation for full diffs of:

- `install.sh` → `resolve_distro_engine()` with `vendor/` preference + optional `GROKHUNTER_DISTRO_ENGINE_SHA256`
- `lib/grok.sh` → clearer incomplete-overlay reporting in `install_cli_bins`
- `bin/grokhunter-doctor` → new "Overlay completeness" section + tip in summary

## Test

```bash
# With vendored engine
mkdir -p vendor
curl -fsSL https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh \
  -o vendor/termux-distro.sh
GROKHUNTER_REFRESH=1 bash install.sh --overlay-only --with-completions --help

# Doctor should surface overlay completeness after doctor patch lands
grokhunter doctor
```

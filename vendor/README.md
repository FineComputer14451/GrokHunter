# Vendored upstream components

## termux-distro.sh

GrokHunter prefers a **vendored** copy of jorexdeveloper’s `termux-distro.sh`
when present. This makes installs reproducible and works offline / air-gapped.

### How to vendor

```bash
# From a GrokHunter clone
mkdir -p vendor
curl -fsSL \
  https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh \
  -o vendor/termux-distro.sh

# Optional: record the SHA for integrity checks
sha256sum vendor/termux-distro.sh
# → set GROKHUNTER_DISTRO_ENGINE_SHA256=<that-hash>
```

Current upstream tip (2026-08-21) SHA256 example:

```
f96add579ba2f4c54428b7a668c9b6732c6b59cfc18f258edd497677890faf16
```

(Re-compute after every upstream update.)

### Priority used by install.sh

1. `vendor/termux-distro.sh`          ← preferred
2. `./termux-distro.sh`               (next to install.sh)
3. `~/.cache/grokhunter/termux-distro.sh`
4. Fresh download (or `GROKHUNTER_DISTRO_ENGINE_URL`)

### Integrity (optional)

```bash
export GROKHUNTER_DISTRO_ENGINE_SHA256="<sha256 of the vendored file>"
bash install.sh --full --de xfce --with-grok --with-x11
```

If the SHA does not match, the installer refuses the mismatched file and falls
through (or aborts on download mismatch).

### License

`termux-distro.sh` is **GPL-3.0** © jorexdeveloper and contributors.  
See `../CREDITS.md`. GrokHunter does not re-claim authorship.

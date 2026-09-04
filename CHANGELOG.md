# Changelog

## Unreleased

### Installer TUI
- First-run numbered wizard on Termux: bare `install.sh` (TTY, no size/feature flags) shows a checklist, prints argv, then `exec`s the existing engine. Default is **coding-only** (`--nano --no-de --with-grok --with-completions`). Desktop toggle promotes to `--full --de xfce --browser chromium --with-x11`. `--yes` is the default with no wizard. Flags still skip it. Overlay-only is unchanged. Overlay cache **2026.8.27**. Never prompts for a key.

### TUI
- Lab status line for Grok Build: `scripts/grok-statusline.py` → `~/.grok/statusline.sh`. One row (cwd, model, ctx%, cost, git branch, turn timer). Hides cost under $0.005, truncates on a phone, never reads `secrets.env`. `grokhunter skills install` copies it and patches `[ui.status_line]` only when missing, builtin, or already this script (does not stomp a foreign command or theme). Restart `grok` to pick it up.

### Lab specialists

- Wave 7: agent **`tls`** + skill **`tls-lab`**. Runtime TLS (`lib/tls.sh`, `SSL_CERT_FILE`, Kali CA, doctor probe, clock-skew). Overlay still writes the install-time `/etc/tls` symlink. `grokhunter tls` launches the agent. Never print certs.
- Wave 8: agent **`net`** + skill **`net-lab`**. HTTPS reachability (`lib/https-probe.sh`, `http_code` 000 vs 403/401, guest DNS). CA stays `tls`. `grokhunter net` launches the agent. Offline lab is still OK for local coding.
- Wave 9: scoped specialist **`tookie`** + skill **`tookie-osint`**. Authorized public username lookup via Tookie-OSINT (`brib.py -sC`). `grokhunter tookie` launches the agent. Not a product default. Hits are leads, not identity. CLI stays upstream (do not vendor `brib.py`).

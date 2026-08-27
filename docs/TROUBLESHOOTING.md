# Troubleshooting — GrokHunter Rootless

Run diagnostics first:

```bash
grokhunter doctor

# Local unit checks (syntax + feature table + bind patch; no network)
bash scripts/ci-unit.sh
```

## Install / bootstrap

### `curl | bash` fails to find modules

The installer caches modules in `~/.cache/grokhunter`. If download fails:

```bash
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter
bash install.sh --full --with-grok --with-x11
```

Force overlay refresh after an upgrade (no rootfs re-download):

```bash
GROKHUNTER_REFRESH=1 bash install.sh --overlay-only --with-completions
```

### Low storage

Full + desktop needs several GB free. Use `--mini` or `--nano` if space is tight:

```bash
bash install.sh --mini --with-grok --no-de
df -h
du -sh ~/.cache/grokhunter ~/.grok/sessions 2>/dev/null
```

Skill `storage-lab` · `grokhunter storage`. Confirm before deleting caches. Prefer `--overlay-only` over re-downloading Kali.

### SHA256 / rootfs download errors

Usually network or Kali mirror issues. Retry later or check:

https://kali.download/nethunter-images/current/rootfs/

## Grok / auth

### `grokhunter: command not found`

You may be in the **wrong shell** (Termux host vs Kali guest) or PATH was not sourced after overlay-only.

```bash
echo "PREFIX=${PREFIX:-unset}"   # Termux host has com.termux
command -v pkg; command -v apt
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
source ~/.grok/profile.sh 2>/dev/null || true
grokhunter skills install
```

Skill `host-lab` · `grokhunter host`. If wrappers are missing, agent `overlay`. Tab-complete / `ghd` missing: skill `shell-lab` (source `~/.grok/profile.sh`; installer does not edit rc).

### `grok: command not found`

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
grokhunter ensure
# force reinstall / switch installer mode:
GROKHUNTER_FORCE_GROK=1 GROKHUNTER_GROK_INSTALLER=official grokhunter ensure --force
# or
bash install.sh --overlay-only --with-grok
# shared script:
bash ~/GrokHunter/scripts/ensure_grok.sh
```

### API / login failures

```bash
# Preferred on mobile
printf 'export XAI_API_KEY=%q\n' "xai-YOUR_KEY" > ~/.grok/secrets.env
chmod 600 ~/.grok/secrets.env
source ~/.grok/secrets.env
grok
```

Confirm SuperGrok / X Premium+ or a valid key.

### Doctor warns about secrets mode

```bash
chmod 600 ~/.grok/secrets.env
```

## Desktop / X11

### `nh-x11` missing

```bash
bash install.sh --with-x11
```

### `Unrecognized option '-lc'`

Current `nethunter` is `nethunter [OPTION] [USERNAME] [-- COMMAND]`.
`nh-x11` must not pass `/bin/bash -lc` as launcher flags.

```bash
# after overlay update:
hash -r
nh-x11
```

### XFCE panel dies / Gtk glycin `bwrap` abort

Kali 2026 gdk-pixbuf loads SVG via **glycin** + `bwrap --unshare-all`, which **exits 1** in proot and GTK aborts (xfce4-panel).
`nh-x11` installs `bin/bwrap-proot` as `/usr/local/bin/bwrap` **and** `/usr/bin/bwrap` (ELF saved as `bwrap.real`).

```bash
# manual (inside Kali):
sudo dpkg-divert --local --rename --divert /usr/bin/bwrap.real --add /usr/bin/bwrap
sudo install -m 755 ~/GrokHunter/bin/bwrap-proot /usr/bin/bwrap
```

Termux:X11 GPU crashes: `nh-x11` now defaults to **legacy drawing**. Disable with `NH_X11_LEGACY=0`.

### Black screen / no desktop

1. Install the **Termux:X11** APK from official nightlies.  
2. Open Termux:X11 once.  
3. Run `nh-x11` from Termux.  
4. Wrong DE? Override: `NH_X11_SESSION=startlxde nh-x11` (or `i3`, `mate-session`, …).  
5. Fallback: VNC inside NetHunter (`vncserver :1`).

### Wrong desktop after install

`nh-x11` reads `~/.config/grokhunter/x11-session` (written when you pick a DE). Reset:

```bash
echo startxfce4 > ~/.config/grokhunter/x11-session
# or one-shot:
NH_X11_SESSION=startxfce4 nh-x11
```

### `/tmp` or display errors inside proot

The installer patches a `/tmp` bind for X11. Re-run:

```bash
bash install.sh --with-x11
```

## PATH / shell

### Commands missing after install

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
# Installer does not edit .bashrc/.zshrc. Add:
#   [[ -r ~/.grok/profile.sh ]] && source ~/.grok/profile.sh
```

### `nethunter` not found

Re-run install or open a new Termux session after install completes.

## Git / GitHub identity

### Commits show as `invalid-email-address` / `root`

Kali and Termux often default to `root <root@localhost.localdomain>`. GitHub cannot attach that address to an account.

```bash
grokhunter git-identity          # show
grokhunter git-identity set      # gh, GH_TOKEN, or GitHub origin owner
# or explicitly:
git config --global user.name "Your GitHub name"
git config --global user.email "ID+LOGIN@users.noreply.github.com"
```

Your noreply address is on https://github.com/settings/emails (format `ID+LOGIN@users.noreply.github.com`). Then `grokhunter doctor` should report a real identity.

## TLS / CA

Termux or Grok may inject `SSL_CERT_FILE=/etc/tls/cert.pem`. That path is often missing inside Kali, so curl/`gh` fail. Do not paste certificate PEM.

```bash
echo "SSL_CERT_FILE=${SSL_CERT_FILE:-unset}"
test -r /etc/ssl/certs/ca-certificates.crt && echo kali-ca-ok
ls -l /etc/tls/cert.pem 2>/dev/null || echo 'no /etc/tls/cert.pem'
date -u
grokhunter doctor
```

Skill `tls-lab` · `grokhunter tls`. Overlay still writes the install-time `/etc/tls` compat symlink. If `date` is 1970, fix the Android clock first.

## Coding tools

### No git / python / gcc

Inside `nethunter`:

```bash
sudo apt update
sudo apt install -y build-essential git python3 python3-pip
```

### Aider not found / install fails

Common on current Kali: **Python 3.13** + missing `python3-venv`.  
`aider-chat` needs Python **<3.13**. Use the shared installer (uv + 3.12):

```bash
bash ~/GrokHunter/scripts/install_aider.sh
# or
bash ~/GrokHunter/install.sh --overlay-only --with-aider
```

Manual upstream path:

```bash
curl -LsSf https://aider.chat/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
aider --version
```

See [EDITORS.md](EDITORS.md).

## Environment

### Doctor says “No /etc/os-release”

Warning only — the coding lab still works. Termux host Android often has no `/etc/os-release`; Kali proot should have `/etc/os-release` → `/usr/lib/os-release`.

Doctor also looks at `/usr/lib/os-release` and `$PREFIX/etc/os-release`. Inside Kali:

```bash
ls -l /etc/os-release /usr/lib/os-release
```

If both are missing, identification is skipped; Grok / PATH checks are the ones that matter.

## Network

Skill `net-lab` · `grokhunter net`. CA / `SSL_CERT_FILE` stays skill `tls-lab`.

### Doctor says “Offline or no route to x.ai”

That line is a **warning**, not a hard fail. Pair-programming still works offline.

Doctor probes `https://api.x.ai/v1/models` (then `https://x.ai`). **HTTP 401 / 403 counts as reachable** — Cloudflare often challenges `curl` on the marketing site, and the API returns 401 without a key.

Only treat it as a real outage when the probe gets no HTTP status (`000` / timeout):

```bash
curl -sS -o /dev/null -w '%{http_code}\n' --max-time 5 https://api.x.ai/v1/models
# 401 = online (no key). 000 = no route / DNS / TLS failed.
```

If DNS is empty, see below. Otherwise: phone data/Wi-Fi, VPN, or wait; the lab is still OK for local coding.

### DNS problems inside rootfs

Rootless NetHunter normally has a working `/etc/resolv.conf`. If nameservers are empty, copy host DNS or set:

```bash
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
```

(Use carefully; some environments manage this automatically.)

## Still stuck

1. `grokhunter doctor` and note ✗ lines  
2. Re-run `bash install.sh` with the flags you need  
3. Open an issue: https://github.com/FineComputer14451/GrokHunter/issues  

Include: Android version, arch (`uname -m`), doctor output (redact keys).

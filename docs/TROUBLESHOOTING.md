# Troubleshooting — GrokHunter Rootless

Run diagnostics first:

```bash
grokhunter doctor
```

## Install / bootstrap

### `curl | bash` fails to find modules

The installer caches modules in `~/.cache/grokhunter`. If download fails:

```bash
git clone https://github.com/FineComputer14451/GrokHunter.git
cd GrokHunter
bash install.sh --full --with-grok --with-x11
```

Force cache refresh after an upgrade:

```bash
GROKHUNTER_REFRESH=1 bash install.sh --with-grok
```

### Low storage

Full + desktop needs several GB free. Use `--mini` or `--nano` if space is tight:

```bash
bash install.sh --mini --with-grok --no-de
```

### SHA256 / rootfs download errors

Usually network or Kali mirror issues. Retry later or check:

https://kali.download/nethunter-images/current/rootfs/

## Grok / auth

### `grok: command not found`

```bash
export PATH="$HOME/.grok/bin:$HOME/.local/bin:$PATH"
grokhunter ensure
# force reinstall / switch installer mode:
GROKHUNTER_FORCE_GROK=1 GROKHUNTER_GROK_INSTALLER=official grokhunter ensure --force
# or
bash install.sh --with-grok
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
# Add to ~/.bashrc or ~/.zshrc if needed — installer markers: # >>> grokhunter >>>
```

### `nethunter` not found

Re-run install or open a new Termux session after install completes.

## Coding tools

### No git / python / gcc

Inside `nethunter`:

```bash
sudo apt update
sudo apt install -y build-essential git python3 python3-pip
```

### Aider not found

See [EDITORS.md](EDITORS.md). Typical fix:

```bash
source ~/venv-aider/bin/activate
```

## Network

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

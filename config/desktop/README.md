# Kali / XFCE menu integration

Desktop entries for the **GrokHunter** submenu in Kali NetHunter (XFCE and other freedesktop menus).

## Install

```bash
# From a GrokHunter clone (inside Kali or with rootfs access):
bash scripts/install_kali_menu.sh

# Also run by:
grokhunter skills install
# and install.sh --with-x11 / setup
```

Installs to:

| Path | Content |
|------|---------|
| `~/.local/share/applications/grokhunter-*.desktop` | App entries |
| `~/.local/share/desktop-directories/grokhunter.directory` | Submenu label |
| `~/.config/menus/applications-merged/grokhunter.menu` | XFCE/Kali menu merge |
| `~/.local/bin/grokhunter-desktop-run` | PATH-safe launcher |

## Menu items

- **Grok Build** — fullscreen TUI
- **Coding Team** — multi-agent session
- **Scout** — read-only map agent
- **Aider + Grok** — git-native pair
- **GrokHunter Doctor** — health report
- **GrokHunter Setup** — one-shot lab sync

Category: `X-GrokHunter` (custom submenu) + standard Development/System where useful.

## Refresh menu

```bash
# XFCE
xfce4-panel -r 2>/dev/null || true
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

Log out/in of the desktop session if the submenu does not appear immediately.

## Uninstall

```bash
bash scripts/install_kali_menu.sh --remove
# or full: bash uninstall.sh  (also removes menu files)
```

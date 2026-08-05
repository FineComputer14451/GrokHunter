# Termux:X11 performance — GrokHunter Rootless

Highest-impact optimizations for a responsive coding desktop on Android.

## Ranked wins

| Priority | Action | Effect |
|----------|--------|--------|
| 1 | **sharedUid APK** (GitHub Termux only) | Stops Android from throttling Termux when X11 is foreground |
| 2 | **Disable XFCE compositing** | Biggest smoothness gain on proot |
| 3 | **Light DE (XFCE / i3)** | Less CPU/RAM than GNOME/KDE |
| 4 | **Share `/tmp`** | Required for X sockets; already patched by `--with-x11` |
| 5 | **Avoid SD-card rootfs** | Faster apt, editors, builds |
| 6 | Optional GPU (Turnip/Zink) | Advanced; device-specific |

## 1. APK choice

| APK | Notes |
|-----|--------|
| `termux-x11-universal-debug.apk` | Works with F-Droid Termux |
| `termux-x11-universal-sharedUid-debug.apk` | **Best performance** if Termux is installed from **GitHub** |

Nightlies: https://github.com/termux/termux-x11/releases/tag/nightly

## 2. Disable compositor (XFCE)

Inside the Kali session (or add to startup):

```bash
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true
```

`nh-x11` (updated) tries this automatically.

## 3. Preferential launch flags

```bash
# Default (GrokHunter)
nh-x11

# Black screen on some devices
NH_X11_LEGACY=1 nh-x11

# Manual Termux-native example
termux-x11 :0 -dpi 120 -xstartup "dbus-launch --exit-with-session xfce4-session"
```

## 4. Preferences (`termux-x11-preference`)

```bash
termux-x11-preference list
# Examples:
termux-x11-preference "fullscreen"="true"
termux-x11-preference "showAdditionalKbd"="true"
```

Tune touchpad vs touchscreen mode from the notification / app preferences for coding with a Bluetooth keyboard.

## 5. DPI / readability

- XFCE: Settings → Appearance → custom DPI  
- Or start with `-dpi 120` (or 96–160 depending on panel size)

## 6. GPU acceleration (optional, advanced)

Not required for coding (editors, terminals, browsers-lite). For GL apps:

- **Adreno:** community Turnip / Zink builds (device-specific packages)
- **Others:** VirGL / ANGLE paths vary widely in stability

See community guides (termux-desktop hw-acceleration, Turnip nightlies). GrokHunter does not auto-install GPU drivers.

## 7. Runtime hygiene

```bash
# Before relaunch if session is stuck
pkill -f termux.x11 2>/dev/null || true
am force-stop com.termux.x11 2>/dev/null || true
```

Keep **one** DE running. Close heavy browsers when compiling.

## GrokHunter path

```bash
# Install / refresh X11 helper
bash install.sh --with-x11

# Fast path
nh-x11
```

Related: [PROOT.md](PROOT.md), [INSTALL.md](INSTALL.md).

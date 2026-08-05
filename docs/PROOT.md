# Proot optimization — GrokHunter Rootless

GrokHunter uses **rootless proot** (Termux + Kali NetHunter rootfs), not a full rewrite onto `proot-distro`. These tips make the existing stack faster and more reliable for coding.

## Principles

| Goal | Practice |
|------|----------|
| I/O speed | Keep rootfs on **internal storage** (not SD card) |
| X11 / sockets | Share Termux `/tmp` into the guest (`/tmp` bind) |
| Storage access | Bind Android shared storage when needed |
| Low ports | Use proot `--fix-low-ports` when binding services |
| RAM | Prefer XFCE/i3 over GNOME/KDE on phones |
| Toolchains | Install only what you need (`build-essential`, not full meta-packages) |

## Required bind for Termux:X11

The X11 socket must be visible inside proot:

```text
-b $PREFIX/tmp:/tmp
# or absolute:
-b /data/data/com.termux/files/usr/tmp:/tmp
```

`install.sh --with-x11` patches the `nethunter` / `nh` launcher and creates `nh-x11`.  
Equivalent proot-distro flag: `--shared-tmp`.

## Recommended login flags (mental model)

When using **proot-distro** (optional alternate path):

```bash
proot-distro login kali \
  --shared-tmp \
  --fix-low-ports \
  --bind /storage/emulated/0:/sdcard
```

When using **GrokHunter’s nethunter launcher**, prefer:

```bash
nethunter          # normal shell
nh-x11             # desktop (handles DISPLAY + pulse + /tmp)
```

## Coding-lab environment inside Kali

```bash
# Locales (if missing)
sudo apt install -y locales
sudo sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sudo locale-gen

# Core toolchain only
sudo apt install -y build-essential git python3 python3-pip python3-venv

# Avoid heavy desktop stacks on low-RAM devices
# Prefer: xfce / i3 / lxde
```

## Performance tips

1. **Internal storage** — SD-card rootfs is much slower for apt and compiles.  
2. **Single DE** — one lightweight desktop is enough.  
3. **Don’t run full upgrade on every session** — update when you need packages.  
4. **PulseAudio on host** — start once from Termux (`nh-x11` does this).  
5. **Unset conflicting hooks** — if you craft custom proot lines, `unset LD_PRELOAD` before raw `proot` (Termux wiki).

## proot-distro vs GrokHunter

| | GrokHunter (current) | proot-distro + Kali |
|--|----------------------|---------------------|
| Rootfs source | Official NetHunter `/current/` images | Distro plugins or custom import |
| Launcher | `nethunter` / `nh` / `nh-x11` | `proot-distro login …` |
| Grok / skills | First-class | Manual overlay |
| Best for | Coding lab + Grok pair programming | Generic multi-distro containers |

GrokHunter stays on the NetHunter rootless path so Grok Build, doctor, and skills stay integrated. You can still install `proot-distro` alongside for other distros (Ubuntu, Alpine) without replacing GrokHunter.

## Optional: share projects with the host

```bash
# From Termux (grant storage once)
termux-setup-storage

# Inside nethunter, projects often appear under /sdcard or via binds
# Prefer keeping git repos under the Kali home for speed, sync with git remote
```

## Doctor

```bash
grokhunter doctor
```

Checks rootless signals, `nh-x11`, toolchain, and Grok readiness.

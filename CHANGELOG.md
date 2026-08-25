# Changelog

## Unreleased

### CLI
- Restored `bin/grokhunter` after accidental PLACEHOLDER wipe (`ee3f6d7` / incomplete `85ef807`).
- Added `grokhunter binds [status|repair|optimize]` (wraps `lib/x11.sh` proot bind helpers).
- `install_grok_profile.sh` no longer drops the V9 picker marker that sits after `[models]`.
- Honor Kali CA bundle when Grok/Termux inject `SSL_CERT_FILE=/etc/tls/cert.pem` (profile, doctor probe, git-identity, `/etc/tls` compat symlink).
- `nh-x11` uses `nethunter --env … -- COMMAND` (jorexdeveloper 2026.2.x). Fixes `Unrecognized option '-lc'`.
- `nh-x11` passes DISPLAY via `--env` plus a non-login `su -c`, and uses `XDG_RUNTIME_DIR=/tmp/runtime-kali` (mode 700) so XFCE/dbus can start.
- `bin/bwrap-proot` replaces Kali `/usr/bin/bwrap` (ELF kept as `bwrap.real`) so glycin SVG loaders do not abort GTK under proot.
- `nh-x11` defaults to Termux:X11 `-legacy-drawing` (`NH_X11_LEGACY=0` to disable).
- `nh-x11` wake-locks Termux, waits for the X11 socket, starts `xfce4-session` before opening the X11 app, and skips `startxfce4`/`xrdb` (hang under proot). XFCE session env (`XDG_MENU_PREFIX`) is still exported.
- `nh-x11` no longer uses `su --login` (it cleared DISPLAY → `Cannot open display: .`).
- `nh-x11` traps cleanup on EXIT/INT/TERM before the DE poll so a failed start still wake-unlocks.
- `/etc/tls/cert.pem` compat symlink is written into the Kali rootfs (not only live `/etc` on Termux).
- `grokhunter binds` matches jorexdeveloper `--bind=` / `proot_args+=(--bind=)` launchers; `optimize` now fails if the patch does not apply.
- `git-identity` sanitizes a missing `SSL_CERT_FILE` before `gh api`, not only the curl fallback.
- `nh-x11` tracks the `termux-x11` PID (cleanup + xserver log on socket timeout), aborts if the guest runtime dir cannot be created, and tails `nh-x11.log` when the session exits after “desktop is up”.
- TLS rewrite/compat lives in `lib/tls.sh` (probe, identity, doctor, install). `grokhunter binds` lives in `lib/x11.sh`. One `_gh_install_bwrap_stub` is shared by setup and `nh-x11`.

### Branding
- Converted `branding/*.png` from JPEG-named files to real PNG (icon, favicon, lockup).
- Wired assets into README, product site (header, hero, favicon, Open Graph / Twitter card), and XFCE menu (`Icon=grokhunter`).
- Site accent shifted to brand cyan `#00E5C7`. Tagline: **Ship code from your pocket.**
- Site palette aligned to brand charcoal `#0D1117` / cyan `#00E5C7` (no leftover phosphor green).
- Share cards: `og.jpg` 1200×630 (Open Graph / Twitter). `x-banner.jpg` 1200×264 is an X profile header (upload in X settings, not HTML). Dropped `social-preview.jpg` alias and `x:game:image` meta.
- README hero uses the GH icon + charcoal/cyan shields (drop the noisy lockup).
- Rebuilt all raster brand assets from a geometric G mark (crisp PNG/SVG, no photographic lockups).
- Color scheme shout-out to Kali Linux: official blue `#2777FF` alongside Grok cyan.
- NetHunter dragon red `#E31C3D` on hero, chips, architecture, and credits.
- Baked dual accent bar (Kali blue | NetHunter red) into all brand rasters, lockups, share cards, and palette.
- Split binary assets into `assets-*.b64.json` packs + sidecars; deploy always runs `decode_assets.py`.

### Lab specialists

- Playbooks catch up to Unreleased: `grokhunter binds`, TLS/`lib/tls.sh`, `bwrap-proot` / glycin. Thin agents/skills gain Common failures + Verify.
- Wave 6: agents **`github`**, **`secrets`**, **`toolchain`** (skills already existed). `grokhunter github` launches the agent; CLI is `grokhunter git-identity`. No binds agent — Desktop owns `grokhunter binds`.
- Specialist add recipe in `agents/README.md` (skill-only vs agent+skill; CLI collisions; ci-unit). No new names.
- Optional skills **`toolchain`** (apt / Aider Python 3.12 / storage) and **`github-lab`** (`git-identity` playbook)
- Agents **`overlay`**, **`ship`**, **`docs`** plus roles/personas and Coding Team routing
- `grokhunter overlay|ship|docs` launchers + completions
- `grokhunter` skill refreshed for 1.0.9 (identity, doctor, PATH)
- Wave 2: skills **`grok-models`**, **`ci-lab`**, **`secrets-lab`**; agents **`models`**, **`ci`**, **`aider`** (`grokhunter modeler` so it does not collide with `grokhunter models`)
- Wave 3: skills **`session-lab`**, **`host-lab`**, **`mcp-lab`**; agents **`session`**, **`host`**, **`mcp`** (`grokhunter mcp` launches the agent; CLI is `grok mcp`)
- Wave 4: skills **`plugin-lab`**, **`flow-lab`**, **`storage-lab`**; agents **`plugin`**, **`flow`**, **`storage`** (`grokhunter plugin` launches the agent; CLI is `grok plugin`)
- Wave 5: skills **`editor-lab`**, **`hooks-lab`**, **`shell-lab`**; agents **`editor`**, **`hook`**, **`shell`**
- Overlay cache **2026.2.18**

## [1.0.9] — 2026-08-22 — Doctor truth + GitHub identity

Doctor stops treating a working lab as offline or incomplete. Git commits attach to GitHub instead of `invalid-email-address`. Overlay cache **2026.2.13**.

### Status / doctor follow-ups

- `grokhunter status` treats current **and** legacy V9 config markers as `models=yes`
- Clone-only installer cache is informational (`ok`), not a yellow warning

### Doctor environment

- Missing `/etc/os-release` is a warning, not a hard fail (Termux host / incomplete rootfs)

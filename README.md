# GrokHunter

**Kali NetHunter, powered by [Grok Build](https://x.ai)**

GrokHunter is a **NetHunter variant overlay** — not a fork of Kali's rootfs. It turns a stock Kali NetHunter (nano/core/full) chroot into an AI-agent-first mobile pentest and builder environment with Grok Build as the default operator shell.

```
┌─────────────────────────────────────────────────────────┐
│  Android host (kernel / wireless / HID / USB)           │
│    └─ Kali NetHunter rootfs (nano · core · full)        │
│         └─ GrokHunter overlay  ← this project           │
│              ├─ Grok Build CLI (official binary)        │
│              ├─ NetHunter-tuned config + TUI            │
│              ├─ launchers: grokhunter · grok-nethunter  │
│              ├─ skills: recon · security · studio       │
│              └─ doctor · MOTD · shell profile           │
└─────────────────────────────────────────────────────────┘
```

> Independent community project. **Not affiliated with, endorsed by, or sponsored by xAI or Offensive Security.**

## What you get

| Component | Purpose |
|-----------|---------|
| **Grok Build ensure** | Installs / upgrades official `grok` ≥ 0.2.93 via `x.ai/cli/install.sh` |
| **NetHunter config profile** | Compact TUI, `always-approve` mobile UX, Grok 4.5 default, groknight theme |
| **`grokhunter` CLI** | One command: status · install · doctor · launch · headless |
| **`grok-nethunter` launcher** | Fullscreen TUI wrapper with secrets + PATH bootstrap |
| **Shell profile** | PATH, aliases (`gh`, `ghn`, `ghp`), secrets.env autoload |
| **Skills** | `grokhunter` orchestrator + `nethunter-recon` agent skill |
| **AGENTS.md** | Security-first agent rules for this rootfs |
| **Doctor** | Health report for binary, auth, DNS, PATH, NetHunter packages |

## Requirements

- **Kali NetHunter** rootfs (tested: **nano** / **core**, Kali 2026.3, aarch64)
- Android host with working network (or desktop Kali aarch64/x86_64)
- SuperGrok / X Premium+ or `XAI_API_KEY` from [console.x.ai](https://console.x.ai)
- `curl`, `git`, `python3` (present on standard NetHunter)

## Quick install (this device)

```bash
cd ~/GrokHunter
bash install.sh
```

One-liner (shareable install):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh)
```

Or clone:

```bash
git clone https://github.com/FineComputer14451/GrokHunter.git ~/GrokHunter
cd ~/GrokHunter && bash install.sh
```

Then:

```bash
# interactive TUI
grokhunter
# or
grok-nethunter

# status / health
grokhunter status
grokhunter doctor

# headless one-shot
grokhunter -p "Summarize open ports from the last nmap scan in ~/scans"

# plan mode
grokhunter plan "Harden this NetHunter chroot for daily agent use"
```

## Authenticate

```bash
# recommended on mobile / chroot
export XAI_API_KEY="xai-..."
# optional durable file (sourced by profile; keep 600)
printf 'export XAI_API_KEY=%q\n' "xai-..." > ~/.grok/secrets.env
chmod 600 ~/.grok/secrets.env

# or first-run browser login
grok
```

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

| Path | Role |
|------|------|
| `install.sh` | Idempotent variant bootstrap |
| `uninstall.sh` | Remove overlay (keeps Grok binary + user projects) |
| `bin/grokhunter` | Primary CLI |
| `bin/grok-nethunter` | Fullscreen launcher |
| `bin/grokhunter-doctor` | Health checks |
| `config/grok-build.nethunter.toml` | Snippet merged into `~/.grok/config.toml` |
| `config/profile.d/grokhunter.sh` | Shell integration |
| `skills/` | Copied into `~/.grok/skills/` |
| `AGENTS.md` | Workspace agent constitution |

## Relationship to other projects

| Project | Role vs GrokHunter |
|---------|-------------------|
| [GrokTerm](https://github.com/FineComputer14451/GrokTerm) | Android APK / Termux native path (no full Kali tools) |
| [grok-cli-termux-native](https://github.com/Thr45hx/grok-cli-termux-native) | DNS byte-patch for pure Termux (not needed in NetHunter chroot with `/etc/resolv.conf`) |
| Grok Imagine Cinematic Studio | Optional creative suite — install via `cinematic-studio` / meta installer |
| Official Kali NetHunter | Base rootfs + Android app — GrokHunter never replaces kernel/HID modules |

## Uninstall

```bash
bash uninstall.sh
# Grok Build binary and ~/.grok remain unless you pass --purge-grok
```

## Legal / ethics

GrokHunter is for **authorized security testing, education, and development**. Users are responsible for compliance with local law and scope of engagement. The included recon skill refuses assistance with clearly unauthorized intrusion.

## License

MIT — see [LICENSE](LICENSE).

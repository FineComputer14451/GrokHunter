# GrokHunter Grok Build Marketplace

Add this repo as a **Grok Build** marketplace, then install only the packs you need (phone disk is tight).

## Add the marketplace

```bash
grok plugin marketplace add FineComputer14451/GrokHunter
grok plugin marketplace list
```

TUI: `/marketplace`

## Install

```bash
# recommended starter
grok plugin install grokhunter --trust
grok plugin install grokhunter-coding-team --trust

# one-shot everything (large)
grok plugin install grokhunter-full --trust

# pick labs as needed
grok plugin install grokhunter-overlay --trust
grok plugin install grokhunter-desktop --trust
grok plugin install grokhunter-ci --trust
# …
```

`--trust` only for a source **you** named (`FineComputer14451/GrokHunter`).

## Catalog (23 plugins)

| Plugin | Purpose |
|--------|---------|
| `grokhunter` | GrokHunter Rootless core — Termux × Kali NetHunter rootless install/doctor, pair-programmi… |
| `grokhunter-coding-team` | GrokHunter Coding Team — Scout explore, Benjamin Design, Lucas Build, Harper Harden, plus … |
| `grokhunter-ci` | GrokHunter lab: CI scripts, smoke.yml, unit smoke for GrokHunter. |
| `grokhunter-models` | GrokHunter lab: Grok model catalog and /model pickers for the phone lab. |
| `grokhunter-mcp` | GrokHunter lab: Grok MCP list/add/doctor on NetHunter rootless. |
| `grokhunter-net` | GrokHunter lab: HTTPS reachability and x.ai probe triage for GrokHunter. |
| `grokhunter-plugin-lab` | GrokHunter lab: Grok Build plugin install and marketplace add on the phone lab. |
| `grokhunter-secrets` | GrokHunter lab: secrets.env mode 600, XAI_API_KEY, grok login vs API key. |
| `grokhunter-session` | GrokHunter lab: tmux detach/attach and grok --resume for GrokHunter. |
| `grokhunter-storage` | GrokHunter lab: Disk, --mini/--nano, overlay cache cleanup on Android. |
| `grokhunter-shell` | GrokHunter lab: ~/.grok/profile.sh, completions, aliases for GrokHunter. |
| `grokhunter-tls` | GrokHunter lab: Kali CA / SSL_CERT_FILE / doctor TLS probe for GrokHunter. |
| `grokhunter-toolchain` | GrokHunter lab: apt compilers, uv vs Kali Python, /tmp for GrokHunter builds. |
| `grokhunter-specialist` | GrokHunter lab: Mint new GrokHunter lab playbooks (skill-only or agent+skill). |
| `grokhunter-host` | GrokHunter lab: Termux host vs Kali guest PATH and environment. |
| `grokhunter-editor` | GrokHunter lab: Editor / TUI editing workflows in the GrokHunter lab. |
| `grokhunter-flow` | GrokHunter lab: Flow / orchestration playbooks for GrokHunter agents. |
| `grokhunter-hooks` | GrokHunter lab: User hooks JSON and /hooks for Grok Build on GrokHunter. |
| `grokhunter-github` | GrokHunter lab: GitHub workflows for the GrokHunter coding lab. |
| `grokhunter-desktop` | GrokHunter X11 desktop — grokhunter binds, nh-x11, bwrap black-screen triage (rootless). |
| `grokhunter-overlay` | GrokHunter overlay cache — install.sh --overlay-only, MODULES_VERSION, PATH wrappers. |
| `grokhunter-tookie` | Authorized public username OSINT with Tookie-OSINT (Sherlock-class). Scoped GrokHunter mod… |
| `grokhunter-full` | Complete GrokHunter Grok Build pack — core, Coding Team, all lab specialists, desktop, ove… |

## Layout

```
.grok-plugin/marketplace.json   # catalog
.grok-plugin/plugin-index.json  # generated component index
plugins/<name>/                 # local plugin sources
  .grok-plugin/plugin.json
  skills/ agents/ commands/ rules/
```

## Submit to official xAI marketplace

After this lands on `main`, open a PR to [xai-org/plugin-marketplace](https://github.com/xai-org/plugin-marketplace) with a **remote** entry pinned to a full commit SHA, e.g. path `plugins/grokhunter` (or `grokhunter-full`). See their CONTRIBUTING.md.

## Explicitly omitted

- `nethunter-recon` — offensive recon (not product default)

## Credits

Not affiliated with xAI, Offensive Security, Termux, or jorexdeveloper. See CREDITS.md.

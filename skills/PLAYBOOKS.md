# Skills — Playbook Decision Tree

Symptom → skill routing for the GrokHunter phone lab. Prefer the **narrowest** skill that owns the domain.

**Product version:** 1.0.9 · See also [README.md](README.md) · [REFERENCES.md](REFERENCES.md)

## Lab health & install

| Symptom | Skill | Notes |
|---------|-------|-------|
| Fresh Termux bootstrap | `grokhunter` | `install.sh --full` / one-liner |
| Already have Kali; need wrappers only | `grokhunter` | `--overlay-only --with-*` |
| `grokhunter: command not found` | `grokhunter` + `host-lab` | PATH / host vs guest |
| Doctor red / status incomplete | `grokhunter` | `grokhunter doctor` |
| Grok binary missing / &lt; 1.0.5 | `grokhunter` | `grokhunter ensure` |
| models=no / pickers missing | `grok-models` | `grokhunter models install` |
| Skills not discovered | `grokhunter` | `grokhunter skills install` |
| GitHub `invalid-email-address` | `github-lab` | `grokhunter git-identity set` |
| Secrets missing / ai-smoke key | `secrets-lab` | `~/.grok/secrets.env` mode 600 |

## Coding sessions

| Symptom | Skill | Notes |
|---------|-------|-------|
| Write / debug / review code | `pair-programming` | Grok 4.6 session style |
| Multi-agent feature work | `pair-programming` + agents | `coding-team` / benjamin → lucas → harper |
| Git-native auto-commit pair | `aider-grok` | uv + Python 3.12 |
| Aider missing on Kali 3.13 | `aider-grok` | `scripts/install_aider.sh` |
| Compilers / node / apt missing | `toolchain` | Prefer Kali apt |
| Human editor (nvim/micro) | `editor-lab` | Not a pair tool |

## Desktop & shell

| Symptom | Skill | Notes |
|---------|-------|-------|
| Black screen after `nh-x11` | `x11-desktop` | legacy drawing is default; compositor |
| Desktop lag / jank | `x11-desktop` | sharedUid APK, light DE |
| Am I in Termux or Kali? | `host-lab` | PREFIX / pkg vs apt |
| TUI vanished / Termux killed process | `session-lab` | tmux / `grok --resume` |
| TAB complete / `ghd` missing | `shell-lab` | source `~/.grok/profile.sh` |
| Disk full / SD slow | `storage-lab` | `--mini`, cache cleanup |

## Grok Build extensions

| Symptom | Skill | Notes |
|---------|-------|-------|
| MCP tools missing / doctor red | `mcp-lab` | Prefer HTTP on phone |
| Plugin / marketplace empty | `plugin-lab` | `--trust` only user-named source |
| `.rhai` workflow / /workflow | `flow-lab` | agent_budget 8–32 |
| Hook did not fire | `hooks-lab` | `~/.grok/hooks`, `/hooks-trust` |
| ci-unit / Smoke red | `ci-lab` | Local first |

## Scoped

| Symptom | Skill | Notes |
|---------|-------|-------|
| Authorized recon / CTF only | `nethunter-recon` | Confirm scope first; not product default |

## Quick CLI cheatsheet

```bash
grokhunter doctor
grokhunter status
grokhunter skills install
grokhunter models install
grokhunter git-identity set
grokhunter ai-smoke
bash scripts/ci-unit.sh
nh-x11                    # legacy drawing on; NH_X11_LEGACY=0 to disable
aider-grok
```

## When to escalate to an agent

Skills are playbooks for the current session. For long multi-step work or spawnable specialists, use the matching **agent**:

```text
skills/x11-desktop  →  agent desktop
skills/mcp-lab      →  agent mcp
skills/session-lab  →  agent session
…
```

Orchestrated coding: `grok --agent coding-team` or `/config-agents`.

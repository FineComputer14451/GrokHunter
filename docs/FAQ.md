# FAQ — GrokHunter Rootless

## What is GrokHunter?

A **rootless** Kali NetHunter lab on Termux, optimized for **coding and building**, with Grok Build as the on-device pair programmer. No root, no custom kernel.

## Does it require root?

**No.** It uses Termux + proot only.

## Is this for penetration testing?

The current focus is **coding and building**. The stack is general-purpose Linux on Android; treat it as a portable development lab.

## How is this different from bare Termux?

| | Bare Termux | GrokHunter Rootless |
|--|-------------|---------------------|
| Packages | Termux repos | Full Kali apt |
| Grok | Extra setup | One flag (`--with-grok`) |
| Desktop | Limited | XFCE + Termux:X11 |
| Identity | Generic shell | Coding-lab profile + skills |

## What is the default AI agent?

**Grok Build** (`grok` / `grokhunter`). Optional: [Aider](EDITORS.md) with the same xAI key.

## Which desktop should I pick?

**XFCE** is the recommended default (light, familiar, works well with Termux:X11).

## Do I need Termux:X11?

Only if you want a graphical desktop. Shell + `grok` is enough for most pair-programming sessions.

## Can I use this on a tablet?

Yes. Larger screens work well with `nh-x11` + XFCE.

## How do I update?

Re-run the installer (idempotent) or:

```bash
cd ~/GrokHunter && git pull
GROKHUNTER_REFRESH=1 bash install.sh --with-grok   # refresh modules + Grok
grokhunter ensure             # Grok binary only (shared ensure_grok.sh)
```

## Can I add features without re-downloading Kali?

Yes — **overlay-only** (no rootfs / termux-distro):

```bash
bash install.sh --overlay-only --with-x11 --with-aider
bash install.sh --overlay-only --with-grok --with-v9-models --with-completions
# refreshes CLI wrappers + skills under ~/.local/bin and ~/.grok/skills
```

Product skills are any `skills/<name>/SKILL.md` in the repo. `grokhunter skills install` copies all of them. Core health is still the coding trio (`skills=N/3`); `x11-desktop` and `nethunter-recon` are optional.

**Coding Team agents** (true multi-agent system prompts): `benjamin`, `lucas`, `harper`, `coding-team` install to `~/.grok/agents/`. Grok loads them at runtime via `/config-agents` or spawn `subagent_type`. See [CODING-TEAM.md](CODING-TEAM.md).

Requires at least one `--with-*` flag.

## How do I check V9 model pickers / API key?

```bash
grokhunter models status
grokhunter models install
grokhunter ai-smoke          # SpaceXAI Responses smoke (needs XAI_API_KEY)
bash scripts/ci-unit.sh      # local unit checks (no network)
```

## Where are secrets stored?

`~/.grok/secrets.env` (mode `600`). Never commit this file.

## Can I use local models?

Grok Build is cloud-oriented. For local models, use tools like Cline/Aider with Ollama on a machine that can run them; phones rarely have enough RAM for strong local coding models.

## Is this affiliated with xAI or Offensive Security?

**No.**

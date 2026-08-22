# FAQ — GrokHunter Rootless

## What is GrokHunter?

A **rootless** Kali NetHunter lab on Termux, optimized for **coding and building**, with Grok Build as the on-device pair programmer. No root, no custom kernel.

## Who should get credit for this stack?

GrokHunter is an **overlay**. Full statement: [CREDITS.md](../CREDITS.md) · `grokhunter credits`

| Layer | Credit |
|-------|--------|
| Install engine | **[jorexdeveloper](https://github.com/jorexdeveloper)** — [termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter), [termux-distro](https://github.com/jorexdeveloper/termux-distro) |
| Host | **[Termux team](https://github.com/termux)** — app, packages, [Termux:X11](https://github.com/termux/termux-x11) |
| Guest OS images | **[Kali](https://www.kali.org/) / [Offensive Security](https://www.offsec.com/)** — NetHunter rootfs |
| AI agent | **[xAI](https://x.ai)** — [Grok Build](https://x.ai/cli), Grok models |

We are **not affiliated** with those projects; we depend on them and give credit.

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

## Why does doctor say “No /etc/os-release”?

That used to be a hard fail. It is now a **warning**. Termux’s Android host often has no `/etc/os-release`. Kali NetHunter should have it (or `/usr/lib/os-release`). Coding still works either way.

## Why does doctor warn “Offline or no route to x.ai”?

Usually a **false alarm**. Cloudflare often returns 403 to `curl` on `https://x.ai`, and `https://api.x.ai/v1/models` returns 401 without a key. Both mean the network works. Doctor now treats those as reachable. A real outage is `http_code=000` / timeout.

## Why do GitHub commits show `invalid-email-address`?

The lab often runs as `root` inside proot, so git defaults to `root@localhost.localdomain` (or an empty ident that becomes `kali@localhost`). GitHub cannot map that to a user.

```bash
grokhunter git-identity set
```

That uses `gh` if logged in, else `GH_TOKEN` / `GITHUB_TOKEN`, else the GitHub `origin` owner on this clone. Or set the GitHub noreply from [settings/emails](https://github.com/settings/emails):

```bash
git config --global user.name "Your GitHub name"
git config --global user.email "ID+LOGIN@users.noreply.github.com"
```

## How do I update?

Use **overlay-only** so you do not re-enter the termux-distro / rootfs path:

```bash
# Clone:
cd ~/GrokHunter && git pull
bash install.sh --overlay-only --with-completions
grokhunter ensure
grokhunter skills install

# One-liner (no git):
GROKHUNTER_REFRESH=1 bash <(curl -fsSL https://raw.githubusercontent.com/FineComputer14451/GrokHunter/main/install.sh) \
  --overlay-only --with-completions
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

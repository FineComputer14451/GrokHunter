# Grok 4.6 chat ↔ Grok Build — workflow map

How to route work across **Grok chat**, **Grok Bot**, and **Grok Build** so you
do not thrash models or surfaces. Catalog id remains **`grok-4.6`**.

See also: [GROK-46.md](GROK-46.md) · [GROK-BUILD-1.0.md](GROK-BUILD-1.0.md) · skill `grok-models`.

## Surfaces

| Surface | Best for | Model / mode to pin |
|---------|----------|---------------------|
| **Grok chat** (web/app) | Research, writing, quick Q&A, non-repo thinking | Chat modes: Auto / Fast / **Expert** / Heavy (4.6-generation Chat) |
| **Chat → Build** (Build Mode) | Shareable sites, apps, games, dashboards in chat → `*.grok.me` | Picker tile **Build** — *not* the terminal CLI ([xAI](https://x.ai/news/grok-build-mode)) |
| **Grok Bot** | Orchestration, connectors, PRs, multi-agent seating | Account default (Bot); not your main phone file editor |
| **Grok Build** (`grok`) | Repo work, multi-file edits, long agent loops | Catalog default **`grok-4.6`** |
| **Coding Team** (Benjamin → Lucas → Harper) | Design → ship → harden | Same `grok-4.6` via `~/.grok/agents/` |
| **Aider** (`aider-grok`) | Focused diffs when the Build TUI is heavy | `AIDER_MODEL=grok-4.6` |


## Chat Build Mode vs Grok Build CLI

Same word, **two products**:

| | **Build Mode** (Chat picker → **Build**) | **Grok Build** (`grok` / `grokhunter`) |
|--|------------------------------------------|----------------------------------------|
| Where | grok.com / iOS / Android Chat | Termux or desktop terminal |
| Does | Describe → live preview in chat → publish `*.grok.me` (or custom domain) | Reads/edits your repo, shell, agents, skills |
| Best for | Prototypes you want to share as a link | GrokHunter lab, multi-file code, Coding Team |
| Code | Optional — you need not touch it | Primary surface — works in your files |
| Tier note | Early Beta; announced for SuperGrok Heavy ([news](https://x.ai/news/grok-build-mode)) | Lab install + SuperGrok login or `XAI_API_KEY` |

**Rule:** repo / lab work → terminal **Grok Build**. Shareable app-in-chat → Chat **Build Mode**. Do not treat the Chat **Build** tile as “open my phone rootfs.”

Chat mode map (Auto/Fast/Expert/Heavy/Build): skill `grok-chat-model-map` / Studio plan PR [#48](https://github.com/FineComputer14451/Grok-Imagine-Cinematic-Studio/pull/48).

## Grok Build model

Use the catalog default **`grok-4.6`** (no V9 `/model` pickers). Former aliases
(`chat-expert`, `multi`, `auto`, `grok-v9`, …) are retired — clean with
`grokhunter models clean` if they linger in `~/.grok/config.toml`.

**Imagine** stills/video stay on `grok-imagine-*` — do not use those for coding sessions. Full map (incl. Agent Mode): [Studio IMAGINE_MODELS_MAP](https://github.com/FineComputer14451/Grok-Imagine-Cinematic-Studio/blob/main/docs/guides/IMAGINE_MODELS_MAP.md).

## Day-to-day routing

1. **Decide / research** → Grok chat **Auto** or **Expert** (4.6-generation Chat), or Bot for “what should we do?”.
2. **Shareable prototype (no local repo)** → Chat picker **Build** (Build Mode → preview / `grok.me`).
3. **Plan a repo change** → terminal `grok` (default `grok-4.6`), or `grokhunter plan "…"`.
4. **Implement in the lab** → default `grok-4.6` (or Coding Team Lucas); keep turns small — *not* Chat Build Mode.
5. **Harden / review** → Harper, or another `grok` turn on the diff.
6. **Bot** → install, tunnels, GitHub, connectors — glue, not primary editor on phone.

## Lab checklist (Termux / desktop)

```bash
grokhunter ensure
grokhunter models status
grokhunter models clean            # if legacy V9 pickers remain
bash scripts/install_grok_profile.sh --force   # if still on 4.5 / channel=alpha
```

Confirm the default coding model remains **`grok-4.6`**.

## Success criteria

- `grokhunter status` shows `models=yes` and profile on 4.6.
- You know: chat for think, Chat **Build Mode** for shareable prototypes, terminal **Grok Build** for repo/lab code, Bot for glue.
- Imagine models never selected for coding.

## Related

- [pair-programming](../skills/pair-programming/SKILL.md)
- [CODING-TEAM.md](CODING-TEAM.md)
- [FAQ.md](FAQ.md) — models default / API key

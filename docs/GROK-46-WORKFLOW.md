# Grok 4.6 chat ↔ Grok Build — workflow map

How to route work across **Grok chat**, **Grok Bot**, and **Grok Build** so you
do not thrash models or surfaces. Catalog id remains **`grok-4.6`**.

See also: [GROK-46.md](GROK-46.md) · [GROK-BUILD-1.0.md](GROK-BUILD-1.0.md) · skill `grok-models`.

## Surfaces

| Surface | Best for | Model to pin |
|---------|----------|--------------|
| **Grok chat** (web/app) | Research, writing, quick Q&A, non-repo thinking | Grok 4.6 (chat UI selector) |
| **Grok Bot** | Orchestration, connectors, PRs, multi-agent seating | Account default (Bot); not your main phone file editor |
| **Grok Build** (`grok`) | Repo work, multi-file edits, long agent loops | Catalog default **`grok-4.6`** |
| **Coding Team** (Benjamin → Lucas → Harper) | Design → ship → harden | Same `grok-4.6` via `~/.grok/agents/` |
| **Aider** (`aider-grok`) | Focused diffs when the Build TUI is heavy | `AIDER_MODEL=grok-4.6` |

## Grok Build model

Use the catalog default **`grok-4.6`** (no V9 `/model` pickers). Former aliases
(`chat-expert`, `multi`, `auto`, `grok-v9`, …) are retired — clean with
`grokhunter models clean` if they linger in `~/.grok/config.toml`.

**Imagine** stills/video stay on `grok-imagine-*` — do not use those for coding sessions.

## Day-to-day routing

1. **Decide / research** → Grok chat 4.6 (or Bot for “what should we do?”).
2. **Plan a change** → `grok` (default `grok-4.6`), or `grokhunter plan "…"`.
3. **Implement** → default `grok-4.6` (or Coding Team Lucas); keep turns small.
4. **Harden / review** → Harper, or another `grok` turn on the diff.
5. **Bot** → install, tunnels, GitHub, connectors — glue, not primary editor on phone.

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
- You know: chat for think, Build for code, Bot for glue.
- Imagine models never selected for coding.

## Related

- [pair-programming](../skills/pair-programming/SKILL.md)
- [CODING-TEAM.md](CODING-TEAM.md)
- [FAQ.md](FAQ.md) — models default / API key

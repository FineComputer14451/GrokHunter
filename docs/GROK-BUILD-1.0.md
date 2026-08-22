# Grok Build 1.0.5 compatibility — GrokHunter Rootless

GrokHunter **1.0.7+** targets **[Grok Build 1.0.5](https://x.ai/build/changelog)** (stable, 2026-08-15) with **Grok 4.6** as the default coding model.

## What 1.0.5 means for this lab

| Area | GrokHunter behavior |
|------|---------------------|
| Min binary | `GROKHUNTER_MIN_GROK=1.0.5` (doctor / ensure) |
| Channel | `stable` (not `alpha`) |
| Default model | `grok-4.6` |
| Web search model | `grok-4.6` |
| Fork secondary | `grok-4.6` (not the invalid `grok-build` slug) |
| Profile | `config/grok-build.nethunter.toml` → merged by `scripts/install_grok_profile.sh` |
| Plan | `grokhunter plan` → `grok --agent plan --permission-mode plan -p …` |
| Skills | `~/.grok/skills/` (and project `.grok/skills/`) |
| Agents | `~/.grok/agents/` Coding Team + builtins (`plan`, `explore`, …) |
| Subagents | enabled in profile for workflows / Coding Team |

1.0.5 adds launcher config overlays (`GROK_CONFIG` / `GROK_CONFIG_PATH`), safer worktree reclaim, hook-block messaging, and image/video call limits. Changelog: https://x.ai/build/changelog

## Upgrade path

```bash
# 1) Binary ≥ 1.0.5 + NetHunter profile
grokhunter ensure
# or force reinstall:
GROKHUNTER_FORCE_GROK=1 grokhunter ensure --force

# 2) Profile only (if binary already 1.0.5)
bash ~/GrokHunter/scripts/install_grok_profile.sh --force

# 3) Lab skills + Coding Team agents
grokhunter skills install

# 4) Optional V9 /model aliases (map to grok-4.6)
grokhunter models install
# or force refresh from 4.5 pickers:
grokhunter models force

# 5) Health
grokhunter doctor
grok --version    # expect 1.0.5+
grok inspect      # skills / agents / config
grok models
```

## Verify

```bash
grok --version
# grok 1.0.5 (…) [stable]

grok inspect
# Skills: grokhunter, pair-programming, aider-grok, … (user)
# Agents: benjamin, lucas, harper, coding-team (user) + builtins

cat ~/.grok/config.toml | head -40
# channel = "stable"
# default = "grok-4.6"
```

## Official references

- Install: `curl -fsSL https://x.ai/cli/install.sh | bash`
- Changelog: https://x.ai/build/changelog
- Settings: https://docs.x.ai/build/settings
- Models: https://docs.x.ai/developers/models · https://docs.x.ai/developers/grok-4-6
- Custom models: https://docs.x.ai/build (user guide in `~/.grok/docs/`)

## Notes

- Session auth (SuperGrok / X Premium+) and `XAI_API_KEY` both work; prefer secrets in `~/.grok/secrets.env`.
- V9 picker aliases are **local** `[model.*]` names that still call **grok-4.6**. Former 4.5 picker IDs remain as compat aliases.
- `grok-build` as a **model id** is not the lab default — use `grok-4.6` (agent type `plan` is separate from model id).

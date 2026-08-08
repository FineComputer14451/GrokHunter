# Grok Build 1.0.0 compatibility — GrokHunter Rootless

GrokHunter **1.0.3+** targets **[Grok Build 1.0.0](https://x.ai/build/changelog)** (stable, 2026-08-07).

## What 1.0.0 means for this lab

| Area | GrokHunter behavior |
|------|---------------------|
| Min binary | `GROKHUNTER_MIN_GROK=1.0.0` (doctor / ensure) |
| Channel | `stable` (not `alpha`) |
| Default model | `grok-4.5` |
| Web search model | `grok-4.5` |
| Fork secondary | `grok-4.5` (not the invalid `grok-build` slug) |
| Profile | `config/grok-build.nethunter.toml` → merged by `scripts/install_grok_profile.sh` |
| Plan | `grokhunter plan` → `grok --agent plan --permission-mode plan -p …` |
| Skills | `~/.grok/skills/` (and project `.grok/skills/`) |
| Agents | `~/.grok/agents/` Coding Team + builtins (`plan`, `explore`, …) |
| Subagents | enabled in profile for workflows / Coding Team |

## Upgrade path

```bash
# 1) Binary ≥ 1.0.0 + NetHunter profile
grokhunter ensure
# or force reinstall:
GROKHUNTER_FORCE_GROK=1 grokhunter ensure --force

# 2) Profile only (if binary already 1.0.0)
bash ~/GrokHunter/scripts/install_grok_profile.sh --force

# 3) Lab skills + Coding Team agents
grokhunter skills install

# 4) Optional V9 /model aliases (still map to grok-4.5)
grokhunter models install

# 5) Health
grokhunter doctor
grok --version    # expect 1.0.0+
grok inspect      # skills / agents / config
grok models
```

## Verify

```bash
grok --version
# grok 1.0.0 (…) [stable]

grok inspect
# Skills: grokhunter, pair-programming, aider-grok, … (user)
# Agents: benjamin, lucas, harper, coding-team (user) + builtins

cat ~/.grok/config.toml | head -40
# channel = "stable"
# default = "grok-4.5"
```

## Official references

- Install: `curl -fsSL https://x.ai/cli/install.sh | bash`
- Changelog: https://x.ai/build/changelog
- Settings: https://docs.x.ai/build/settings
- Custom models: https://docs.x.ai/build (user guide in `~/.grok/docs/`)

## Notes

- Session auth (SuperGrok / X Premium+) and `XAI_API_KEY` both work; prefer secrets in `~/.grok/secrets.env`.
- V9 picker aliases are **local** `[model.*]` names that still call **grok-4.5**.
- `grok-build` as a **model id** is not in the 1.0.0 catalog for this lab — use `grok-4.5` (agent type `plan` is separate from model id).

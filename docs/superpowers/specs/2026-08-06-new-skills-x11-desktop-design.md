# Design: New GrokHunter skill `x11-desktop` + dynamic skill install

**Date:** 2026-08-06  
**Status:** Approved for implementation planning  
**Product:** GrokHunter Rootless (coding lab)  
**Version context:** 1.0.2+

## Problem

1. **Content gap:** Termux:X11 / coding-desktop **fix and tune** is documented in `docs/X11-PERFORMANCE.md` and lightly covered in launch flags (`nh-x11`, `NH_X11_LEGACY`) inside existing skills, but there is no dedicated Grok Build skill for black-screen, lag, compositor, and APK performance issues.
2. **Plumbing gap:** `install_skills` (and related uninstall/status name lists) hardcode four skill names. Adding a fifth skill requires editing multiple allowlists, which blocks low-friction growth of the product skill set.

## Goals

- Ship an **optional** skill `x11-desktop` focused on **fix & tune** for the Termux:X11 coding desktop.
- Change install/uninstall discovery to **scan** `skills/*/SKILL.md` under the overlay root.
- Keep **core** health reporting as **`skills=N/3`** for: `grokhunter`, `pair-programming`, `aider-grok`.
- Treat `nethunter-recon`, `x11-desktop`, and any future non-core skills as **optional** (listed in `skills status`, not required by doctor).
- Preserve uninstall safety: do **not** wipe user-only skills that exist only under `~/.grok/skills/` and never lived in the repo.

## Non-goals

- Editors skill, recon expansions, or SpaceXAI skill splits.
- Making X11 required for a “healthy” lab (core denominator stays 3).
- New `nh-x11` features or DE installer redesign.
- Changes to Grok Build’s skill loader, slash-command flags, or config `[skills] paths`.
- Full rewrite of `docs/X11-PERFORMANCE.md` (skill is the activation/playbook layer).

## Approach (selected)

**Approach A:** New skill directory + scan-based plumbing.

Rejected alternatives:

- **B — Expand `grokhunter` only:** avoids a fifth skill but overloads the orchestrator skill and keeps weak auto-activation for pure X11 pain.
- **C — Thin pointer skill:** less duplication, but weaker offline/action density for mobile operators who need ranked commands in-skill.

## Architecture

### Skill discovery and install

```
overlay skills/
  <name>/SKILL.md   →  install_skills scans
  _template/        →  skipped (name prefix "_")  [reserved; not required in this PR]
                ↓
         ~/.grok/skills/<name>/
```

**`install_skills` (lib/grok.sh):**

1. Resolve overlay root (`_gh_overlay_root` or equivalent existing helper).
2. For each directory `skills/<name>/` where `SKILL.md` exists:
   - Skip if `name` starts with `_`.
   - Copy tree to `${HOME}/.grok/skills/<name>/` (replace destination).
3. Count and log installed skills (no fixed allowlist of product names).

**Call sites unchanged:** `install_cli_bins`, `grokhunter skills install`, overlay-complete / completions paths that already call `install_cli_bins`.

### Core vs optional

| Class | Names | `grokhunter status` | Doctor |
|-------|--------|---------------------|--------|
| **Core** | `grokhunter`, `pair-programming`, `aider-grok` | Count toward `skills=N/3` | Missing / repo-only → warn + fix (`skills install`) |
| **Optional** | All other discovered repo skills (e.g. `nethunter-recon`, `x11-desktop`) | Not in N/3 denominator | Report OK if present; **never required** |

Core names remain an **explicit list** in status/doctor code (not “every installed skill”).

### `grokhunter skills status`

- Discover the same set as install (repo `skills/*/SKILL.md`, skip `_` prefix).
- For each name, report: **installed** | **repo-only** | **missing** relative to `~/.grok/skills/<name>/SKILL.md`.
- Optionally mark core vs optional in the line (nice-to-have; not required if output stays simple).

### Uninstall (`remove_skills`)

1. Scan repo `skills/*/SKILL.md` (same rules as install).
2. For each discovered name, remove `${HOME}/.grok/skills/<name>` if present.
3. **Do not** `rm -rf ~/.grok/skills` wholesale.
4. **Do not** remove directories under `~/.grok/skills/` that are not in the repo scan (user-only skills).

### Completions

No change. `skills` subcommand remains `install | status | help`.

## Skill content: `x11-desktop`

### Location and identity

- Path: `skills/x11-desktop/SKILL.md`
- Frontmatter:
  - `name: x11-desktop`
  - `description: >-` multi-line string stating activation on Termux:X11 performance problems, black screen, lag, compositor, `nh-x11` recovery, and coding-desktop tuning on GrokHunter Rootless.

### Activation triggers (body + description)

Activate when the user mentions or needs help with:

- Black screen / blank X11
- Lag, jank, low FPS on desktop
- XFCE compositor / sharedUid APK
- `nh-x11` failures or `NH_X11_LEGACY`
- “X11 slow”, “desktop performance”, Termux:X11 tune-up

### Ownership boundaries

| Topic | Owner |
|-------|--------|
| Install flags, overlay, doctor, PATH, models | `grokhunter` |
| Pair coding, mobile UX, toolchains | `pair-programming` |
| Aider | `aider-grok` |
| Authorized recon | `nethunter-recon` |
| X11 fix & tune ranked playbook | **`x11-desktop`** |

### Body structure

1. **When to activate** — short list of phrases/symptoms.
2. **Quick triage** — is Termux:X11 installed? Is session up? proot? `/tmp` shared?
3. **Ranked wins** — align with `docs/X11-PERFORMANCE.md`:
   1. sharedUid APK (GitHub Termux)
   2. Disable XFCE compositing
   3. Light DE
   4. Share `/tmp`
   5. Avoid SD-card rootfs
   6. Optional GPU (device-specific; advanced)
4. **Recovery commands** — paste-ready: `nh-x11`, `NH_X11_LEGACY=1`, `xfconf-query` compositor off.
5. **Safety** — prefer reversible tweaks; never print secrets; coding-lab mission (no offensive default).
6. **References** — link `docs/X11-PERFORMANCE.md` (and troubleshooting only if a concrete section applies).

Tone: mobile-friendly, command-first, short explanations (matches `AGENTS.md` / existing lab skills).

## Documentation updates

| File | Change |
|------|--------|
| `README.md` and/or `docs/FAQ.md` | Skills install from every `skills/*/SKILL.md`; optional `x11-desktop` for X11 tune |
| `skills/grokhunter/SKILL.md` | Related skill / decision tree: X11 deep fix → `x11-desktop` |
| `docs/X11-PERFORMANCE.md` | One-line pointer: agent skill `x11-desktop` |
| This design | Spec of record under `docs/superpowers/specs/` |

No new website marketing requirement for this change.

## Testing

Update `scripts/ci-unit.sh` (or existing skills install assertions) to:

1. Prove scan-based install copies **core** skills when present.
2. If `skills/x11-desktop/SKILL.md` exists, assert it is installed to a temp or expected `HOME` fixture the way other skill tests run.
3. Keep existing assertions for `grokhunter` / `pair-programming` as applicable.

Manual check on lab:

```bash
grokhunter skills install
grokhunter skills status   # includes x11-desktop installed
grokhunter status          # skills=3/3 when core present
```

## Rollout

Single PR preferred:

1. Plumbing (`install_skills`, status, doctor optional reporting, `remove_skills`)
2. New `skills/x11-desktop/SKILL.md`
3. Doc cross-links
4. ci-unit updates

Operators refresh with:

```bash
grokhunter skills install
```

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Accidental install of incomplete dirs | Require `SKILL.md`; skip `_` prefix |
| Uninstall deletes user customs | Never remove non-repo skill names |
| Doctor false failures for optional skills | Optional never required; only core in N/3 |
| Skill duplicates long docs | Ranked actions in skill; detail stays in `X11-PERFORMANCE.md` |
| Name drift of core list | Core remains explicit three names; document in grokhunter skill Facts |

## Success criteria

1. Adding a future skill is: create `skills/<name>/SKILL.md` → `skills install` (no allowlist edit).
2. `x11-desktop` installs and appears in `skills status` as optional.
3. `grokhunter status` still reports core trio as `N/3`.
4. Uninstall removes repo-discovered skills including `x11-desktop` without clearing pure user skills.
5. Skill content is usable for black-screen / lag triage without opening the full doc first.

## Implementation notes (for planning)

Primary touchpoints (expected):

- `lib/grok.sh` — `install_skills`
- `uninstall.sh` — `remove_skills`
- `bin/grokhunter` — `cmd_skills_status`, core count in `cmd_status`
- `bin/grokhunter-doctor` — skills section core vs optional
- `skills/x11-desktop/SKILL.md` — new
- `skills/grokhunter/SKILL.md` — cross-link
- `docs/X11-PERFORMANCE.md`, FAQ/README as needed
- `scripts/ci-unit.sh` — assertions

Exact line-level plan belongs in the implementation plan (next step after spec approval).

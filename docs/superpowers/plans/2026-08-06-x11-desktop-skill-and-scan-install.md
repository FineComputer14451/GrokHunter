# x11-desktop Skill + Dynamic Skill Install Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional `x11-desktop` skill (Termux:X11 fix & tune) and replace hardcoded skill name lists with scan of `skills/*/SKILL.md`, while keeping core `skills=N/3` and safe uninstall.

**Architecture:** Discover product skills by scanning the overlay `skills/` tree for directories containing `SKILL.md` (skip names starting with `_`). Install copies each into `~/.grok/skills/<name>/`. Status lists all discovered skills; doctor requires only the core trio. Uninstall removes only names present in the repo scan (never wipes user-only skills). New skill content is a command-first playbook aligned with `docs/X11-PERFORMANCE.md`.

**Tech Stack:** Bash (GrokHunter install/CLI), Markdown skills for Grok Build, `scripts/ci-unit.sh` as the unit harness.

**Spec:** `docs/superpowers/specs/2026-08-06-new-skills-x11-desktop-design.md`

## Global Constraints

- Core skills (status `N/3`, doctor-required): exactly `grokhunter`, `pair-programming`, `aider-grok`
- Optional skills (listed, never doctor-required): `nethunter-recon`, `x11-desktop`, and any future non-core dirs under `skills/`
- Skip skill dirs whose basename starts with `_`
- Uninstall must not `rm -rf ~/.grok/skills` wholesale; only remove repo-discovered names
- Never print secrets; coding-lab mission (no offensive default in `x11-desktop`)
- Do not invent new `nh-x11` features; wrap existing commands and docs
- Prefer reversible X11 tweaks first

## File map

| File | Role |
|------|------|
| `lib/grok.sh` | Add `_gh_list_skill_names`; rewrite `install_skills` to scan |
| `uninstall.sh` | Scan-based `remove_skills` from repo `skills/` next to script |
| `bin/grokhunter` | `cmd_skills_status` scans repo skills; core count in `cmd_status` unchanged |
| `bin/grokhunter-doctor` | Core loop unchanged; optional skills generalized (not only recon) |
| `skills/x11-desktop/SKILL.md` | **Create** — fix & tune playbook |
| `skills/grokhunter/SKILL.md` | Related-skills + decision tree pointer |
| `docs/X11-PERFORMANCE.md` | One-line agent skill pointer |
| `README.md` | `skills/` line includes `x11-desktop` + scan note if space allows |
| `docs/FAQ.md` | Brief note that skills install from `skills/*/SKILL.md` |
| `scripts/ci-unit.sh` | Assert scan installs core + `x11-desktop`; optional skip-`_` behavior |

---

### Task 1: Failing CI for scan install + x11-desktop

**Files:**
- Modify: `scripts/ci-unit.sh` (install_skills block ~141–154)
- Test: same file (this is the test harness)

**Interfaces:**
- Consumes: `install_skills` from `lib/grok.sh` (still hardcoded until Task 2)
- Produces: stricter assertions that fail until plumbing + skill land

- [ ] **Step 1: Extend the install_skills unit block**

Replace the install_skills section in `scripts/ci-unit.sh` with:

```bash
# ---------- install_skills copies SKILL.md (scan-based) ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  export HOME=$(mktemp -d)
  source lib/grok.sh
  msg() { :; }
  cursor() { :; }
  install_skills
  [[ -f "$HOME/.grok/skills/grokhunter/SKILL.md" ]]
  [[ -f "$HOME/.grok/skills/pair-programming/SKILL.md" ]]
  [[ -f "$HOME/.grok/skills/aider-grok/SKILL.md" ]]
  [[ -f "$HOME/.grok/skills/nethunter-recon/SKILL.md" ]]
  # New optional skill (Task 4 creates SKILL.md; until then this fails)
  [[ -f "$HOME/.grok/skills/x11-desktop/SKILL.md" ]]
  # User-only skill must not be required for install success (sanity: create after install)
  mkdir -p "$HOME/.grok/skills/user-only"
  echo "user" > "$HOME/.grok/skills/user-only/SKILL.md"
  # Re-install must not delete user-only
  install_skills
  [[ -f "$HOME/.grok/skills/user-only/SKILL.md" ]]
  rm -rf "$HOME"
'
info "install_skills OK"

# ---------- _gh_list_skill_names skips underscore dirs ----------
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  export HOME=$(mktemp -d)
  source lib/grok.sh
  msg() { :; }
  # Requires helper from Task 2
  names="$(_gh_list_skill_names "$SCRIPT_DIR")"
  echo "$names" | grep -qx "grokhunter"
  echo "$names" | grep -qx "x11-desktop"
  echo "$names" | grep -q "^_" && exit 1 || true
  # underscore dir with SKILL.md must not appear
  mkdir -p "$SCRIPT_DIR/skills/_template"
  echo "---" > "$SCRIPT_DIR/skills/_template/SKILL.md"
  names2="$(_gh_list_skill_names "$SCRIPT_DIR")"
  echo "$names2" | grep -q "_template" && exit 1 || true
  rm -rf "$SCRIPT_DIR/skills/_template"
  rm -rf "$HOME"
'
info "list_skill_names OK"
```

**Important:** The `_template` mkdir mutates the real repo tree briefly; always delete it even on failure. Prefer wrapping in `trap 'rm -rf "$SCRIPT_DIR/skills/_template"' EXIT` inside the bash -c.

Safer version of the second block (use this exact form):

```bash
bash -c '
  set -euo pipefail
  SCRIPT_DIR="$(pwd)"
  source lib/grok.sh
  msg() { :; }
  trap '\''rm -rf "$SCRIPT_DIR/skills/_template"'\'' EXIT
  names="$(_gh_list_skill_names "$SCRIPT_DIR")"
  echo "$names" | grep -qx "grokhunter"
  mkdir -p "$SCRIPT_DIR/skills/_template"
  printf "%s\n" "---" "name: template" "---" > "$SCRIPT_DIR/skills/_template/SKILL.md"
  names2="$(_gh_list_skill_names "$SCRIPT_DIR")"
  if echo "$names2" | grep -q "_template"; then
    exit 1
  fi
'
info "list_skill_names OK"
```

- [ ] **Step 2: Run unit tests — expect failure**

Run: `bash scripts/ci-unit.sh`

Expected: FAIL on missing `x11-desktop` and/or missing `_gh_list_skill_names` (depending on order). Do not proceed until failure is observed.

- [ ] **Step 3: Commit test harness changes only**

```bash
git add scripts/ci-unit.sh
git commit -m "test: require scan-based skills install and x11-desktop"
```

---

### Task 2: Scan-based `install_skills` + list helper

**Files:**
- Modify: `lib/grok.sh` (after `_gh_resolve`, rewrite `install_skills` ~85–112)
- Test: `bash scripts/ci-unit.sh` (partial pass for list helper once skill exists still fails x11)

**Interfaces:**
- Produces:
  - `_gh_list_skill_names <overlay_root>` → prints skill basenames, one per line, sorted
  - `install_skills` copies every listed skill with `SKILL.md` to `~/.grok/skills/<name>/`

- [ ] **Step 1: Add helper after `_gh_resolve` in `lib/grok.sh`**

```bash
# List product skill names under <root>/skills (dirs with SKILL.md; skip _*).
# Prints one name per line, sorted. Empty if none.
_gh_list_skill_names() {
  local root="${1:-}" d name
  [[ -n "${root}" && -d "${root}/skills" ]] || return 0
  local -a names=()
  for d in "${root}/skills"/*/; do
    [[ -d "${d}" ]] || continue
    name="${d%/}"
    name="${name##*/}"
    [[ "${name}" == _* ]] && continue
    [[ -f "${d}SKILL.md" ]] || continue
    names+=("${name}")
  done
  if [[ ${#names[@]} -eq 0 ]]; then
    return 0
  fi
  printf '%s\n' "${names[@]}" | LC_ALL=C sort -u
}
```

- [ ] **Step 2: Replace hardcoded loop in `install_skills`**

Replace the `for name in grokhunter pair-programming ...` loop with:

```bash
install_skills() {
  msg -t "Installing GrokHunter skills → ~/.grok/skills"
  local root src dest name count=0
  root="$(_gh_overlay_root || true)"
  if [[ -z "${root}" || ! -d "${root}/skills" ]]; then
    msg -tw "No skills/ tree in overlay — skip"
    return 0
  fi
  mkdir -p "${HOME}/.grok/skills" 2>/dev/null || true
  while IFS= read -r name; do
    [[ -n "${name}" ]] || continue
    src="${root}/skills/${name}"
    dest="${HOME}/.grok/skills/${name}"
    if [[ -d "${src}" && -f "${src}/SKILL.md" ]]; then
      rm -rf "${dest}" 2>/dev/null || true
      mkdir -p "${dest}" 2>/dev/null || true
      cp -a "${src}/." "${dest}/" 2>/dev/null || cp -R "${src}/"* "${dest}/" 2>/dev/null || true
      if [[ -f "${dest}/SKILL.md" ]]; then
        count=$((count + 1))
      fi
    fi
  done < <(_gh_list_skill_names "${root}")
  if [[ ${count} -gt 0 ]]; then
    msg -ts "Installed ${count} skill(s) under ~/.grok/skills"
  else
    msg -tw "No skills installed"
  fi
}
```

Note: `install_skills` only replaces destinations for names it installs; it never deletes other dirs under `~/.grok/skills/` (satisfies user-only preservation).

- [ ] **Step 3: Run unit tests**

Run: `bash scripts/ci-unit.sh`

Expected: still FAIL on `x11-desktop` missing until Task 4; `_gh_list_skill_names` block may fail on missing `x11-desktop` name until Task 4 — if so, temporarily assert only `grokhunter` in list test until Task 4, **or** create skill in Task 4 next without committing green yet. Preferred order: finish Task 2 commit with list helper grepping `grokhunter` only; strengthen list test in Task 4.

**Adjust Task 1 list test if needed:** For Task 2 green intermediate, use:

```bash
echo "$names" | grep -qx "grokhunter"
echo "$names" | grep -qx "pair-programming"
```

and add `x11-desktop` grep only in Task 4.

- [ ] **Step 4: Commit**

```bash
git add lib/grok.sh scripts/ci-unit.sh
git commit -m "feat(skills): scan skills/*/SKILL.md for install"
```

---

### Task 3: Status, doctor, uninstall scan

**Files:**
- Modify: `bin/grokhunter` (`cmd_skills_status` ~190–207)
- Modify: `bin/grokhunter-doctor` (Skills section ~229–246)
- Modify: `uninstall.sh` (`remove_skills` ~37–44)

**Interfaces:**
- Consumes: repo path `GROKHUNTER_HOME/skills` or uninstall script dir
- Produces: status lists every repo skill; uninstall removes only those names

- [ ] **Step 1: Rewrite `cmd_skills_status` in `bin/grokhunter`**

```bash
cmd_skills_status() {
  local s dest count=0 name
  local skills_root="${GROKHUNTER_HOME}/skills"
  echo "skills dir: ${HOME}/.grok/skills"
  echo "repo:       ${skills_root}"
  if [[ ! -d "${skills_root}" ]]; then
    echo "  missing:   (no repo skills/ tree)"
    return 1
  fi
  # shellcheck disable=SC2012
  while IFS= read -r name; do
    [[ -n "${name}" ]] || continue
    s="${name}"
    dest="${HOME}/.grok/skills/${s}/SKILL.md"
    if [[ -f "${dest}" ]]; then
      echo "  installed: ${s}"
      count=$((count + 1))
    elif [[ -f "${skills_root}/${s}/SKILL.md" ]]; then
      echo "  repo-only: ${s}  (run: grokhunter skills install)"
    else
      echo "  missing:   ${s}"
    fi
  done < <(
    for d in "${skills_root}"/*/; do
      [[ -d "${d}" ]] || continue
      name="${d%/}"; name="${name##*/}"
      [[ "${name}" == _* ]] && continue
      [[ -f "${d}SKILL.md" ]] || continue
      printf '%s\n' "${name}"
    done | LC_ALL=C sort -u
  )
  echo "installed: ${count}"
  # Success if core trio present (not full inventory)
  local core=0
  for s in grokhunter pair-programming aider-grok; do
    [[ -f "${HOME}/.grok/skills/${s}/SKILL.md" ]] && core=$((core + 1))
  done
  [[ ${core} -ge 3 ]]
}
```

Keep `cmd_status` core loop unchanged (`skills=N/3` for the three names only).

- [ ] **Step 2: Doctor — core loop + generic optional**

Replace the legacy-only recon block with:

```bash
# ---------- Skills ----------
hdr "Skills"
for s in pair-programming grokhunter aider-grok; do
  if [[ -f "${HOME}/.grok/skills/${s}/SKILL.md" ]]; then
    ok "skill: ${s} (~/.grok/skills)"
  elif [[ -f "${GROKHUNTER_HOME}/skills/${s}/SKILL.md" ]]; then
    warn "skill (repo only): ${s} — run: bash install.sh --overlay-only --with-completions"
    WARN=1
  else
    warn "skill missing: ${s}"
    WARN=1
  fi
done
# Optional / non-core product skills (never required)
if [[ -d "${GROKHUNTER_HOME}/skills" ]]; then
  for d in "${GROKHUNTER_HOME}/skills"/*/; do
    [[ -d "${d}" ]] || continue
    s="${d%/}"; s="${s##*/}"
    [[ "${s}" == _* ]] && continue
    [[ -f "${d}SKILL.md" ]] || continue
    case "${s}" in
      grokhunter|pair-programming|aider-grok) continue ;;
    esac
    if [[ -f "${HOME}/.grok/skills/${s}/SKILL.md" ]]; then
      ok "skill (optional): ${s} (~/.grok/skills)"
    elif [[ -f "${GROKHUNTER_HOME}/skills/${s}/SKILL.md" ]]; then
      ok "skill (optional, repo only): ${s} — install: grokhunter skills install"
    fi
  done
fi
```

Optional skills must **not** set `WARN=1` when missing.

- [ ] **Step 3: Rewrite `remove_skills` in `uninstall.sh`**

```bash
remove_skills() {
  local root name
  root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ ! -d "${root}/skills" ]]; then
    # Fallback: remove known historical names only if repo tree absent
    for name in grokhunter pair-programming aider-grok nethunter-recon x11-desktop; do
      if [[ -d "${SKILLS_DIR}/${name}" ]]; then
        rm -rf "${SKILLS_DIR}/${name}"
        log "Removed skill ${name}"
      fi
    done
    return 0
  fi
  for d in "${root}/skills"/*/; do
    [[ -d "${d}" ]] || continue
    name="${d%/}"; name="${name##*/}"
    [[ "${name}" == _* ]] && continue
    [[ -f "${d}SKILL.md" ]] || continue
    if [[ -d "${SKILLS_DIR}/${name}" ]]; then
      rm -rf "${SKILLS_DIR}/${name}"
      log "Removed skill ${name}"
    fi
  done
}
```

- [ ] **Step 4: Smoke check status (manual)**

Run:

```bash
bash bin/grokhunter skills status || true
bash bin/grokhunter status | grep skills=
```

Expected: status still `skills=N/3` format; skills status lists current four (or five once skill exists) without crashing.

- [ ] **Step 5: Commit**

```bash
git add bin/grokhunter bin/grokhunter-doctor uninstall.sh
git commit -m "feat(skills): scan-based status, doctor optional, uninstall"
```

---

### Task 4: Author `skills/x11-desktop/SKILL.md`

**Files:**
- Create: `skills/x11-desktop/SKILL.md`
- Modify: `scripts/ci-unit.sh` (add `x11-desktop` to list-name assertion if deferred)

**Interfaces:**
- Produces: installable optional skill name `x11-desktop`

- [ ] **Step 1: Create directory and SKILL.md**

Write `skills/x11-desktop/SKILL.md` with **exactly** this content (adjust only if docs paths move):

```markdown
---
name: x11-desktop
description: >-
  Termux:X11 coding-desktop fix and tune for GrokHunter Rootless. Activate for
  black screen, lag/jank, compositor issues, nh-x11 recovery, NH_X11_LEGACY,
  sharedUid APK choice, and performance tuning on Android. Optional skill —
  not required for a healthy coding lab.
---

# X11 Desktop Skill (optional)

GrokHunter coding lab on **unrooted Android** + Termux:X11. This skill is for
**fix & tune** of the coding desktop — not full product install.

| Need | Use skill |
|------|-----------|
| Install, doctor, PATH, models, skills CLI | **`grokhunter`** |
| Write / debug application code | **`pair-programming`** |
| Aider | **`aider-grok`** |
| X11 black screen, lag, performance | **this skill** |

## When to activate

- Black / blank screen after `nh-x11`
- Desktop lag, jank, low FPS on phone
- XFCE compositor / sharedUid APK questions
- `NH_X11_LEGACY`, Termux:X11 preference tweaks
- "X11 slow", "desktop performance", coding desktop recovery

## Quick triage

1. Is **Termux:X11** APK installed on the Android host?
2. Are you inside the **Kali proot** where `nh-x11` is on PATH?
3. Was the lab installed with **`--with-x11`** (or overlay-only equivalent)?
4. Prefer rootfs on **internal storage**, not SD card.

```bash
command -v nh-x11 || ls -la ~/.local/bin/nh-x11
echo "DISPLAY=${DISPLAY:-unset}"
```

## Ranked wins (do in order)

| Priority | Action | Why |
|----------|--------|-----|
| 1 | **sharedUid** Termux:X11 APK (GitHub Termux) | Stops Android throttling when X11 is foreground |
| 2 | **Disable XFCE compositing** | Biggest smoothness gain under proot |
| 3 | **Light DE** (XFCE / i3) | Less CPU/RAM than GNOME/KDE |
| 4 | **Share `/tmp`** | X sockets; normally patched by `--with-x11` |
| 5 | **Avoid SD-card rootfs** | Faster apt, editors, builds |
| 6 | Optional GPU (Turnip/Zink) | Advanced; device-specific |

Deep detail: `docs/X11-PERFORMANCE.md`.

## Recovery commands

```bash
# Default launch
nh-x11

# Black screen on some devices
NH_X11_LEGACY=1 nh-x11

# Disable XFCE compositor (inside Kali session)
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true
```

APK nightlies: https://github.com/termux/termux-x11/releases/tag/nightly

| APK | Notes |
|-----|--------|
| `termux-x11-universal-debug.apk` | Works with F-Droid Termux |
| `termux-x11-universal-sharedUid-debug.apk` | Best performance if Termux is from **GitHub** |

## Safety

- Prefer reversible tweaks first (compositor, launch flags).
- Never print or commit `XAI_API_KEY` / secrets.
- Default product mission is **coding lab**, not offensive ops.
- Do not invent root/Magisk/HID capabilities for rootless GrokHunter.

## After desktop is usable

```bash
grokhunter doctor
grok
# or pair-programming skill for app work
```
```

- [ ] **Step 2: Strengthen list test for x11-desktop**

In `scripts/ci-unit.sh` list test, ensure:

```bash
echo "$names" | grep -qx "x11-desktop"
```

- [ ] **Step 3: Run full unit suite — expect PASS**

Run: `bash scripts/ci-unit.sh`

Expected: `ALL OK`

- [ ] **Step 4: Manual install smoke**

```bash
export HOME=$(mktemp -d)
# still use real repo via SCRIPT_DIR
SCRIPT_DIR=/home/kali/GrokHunter HOME=$HOME bash -c '
  source lib/grok.sh
  msg() { shift; echo "$*"; }
  cursor() { :; }
  install_skills
  test -f "$HOME/.grok/skills/x11-desktop/SKILL.md"
  echo OK
'
# restore: do not leave weird HOME; the subshell used temp HOME only
```

Or simply:

```bash
grokhunter skills install
grokhunter skills status | grep x11-desktop
```

Expected: `installed: x11-desktop` (or `repo-only` before install).

- [ ] **Step 5: Commit**

```bash
git add skills/x11-desktop/SKILL.md scripts/ci-unit.sh
git commit -m "feat(skills): add optional x11-desktop fix-and-tune skill"
```

---

### Task 5: Docs and cross-links

**Files:**
- Modify: `skills/grokhunter/SKILL.md` (Related skills + decision tree)
- Modify: `docs/X11-PERFORMANCE.md` (top pointer)
- Modify: `README.md` (skills/ tree line ~149)
- Modify: `docs/FAQ.md` (overlay skills bullet ~57 area)

- [ ] **Step 1: Update grokhunter skill Facts + decision tree**

In the Facts table, change Related skills line to:

```markdown
| Related skills | `pair-programming`, `aider-grok` (coding); `x11-desktop` (X11 fix/tune); `nethunter-recon` (legacy/scoped) |
```

In the decision tree block, add:

```text
X11 black/lag/tune?   → skill x11-desktop (docs/X11-PERFORMANCE.md)
```

Near Desktop line if present, keep `nh-x11` but point deep tune to the skill.

- [ ] **Step 2: Pointer at top of `docs/X11-PERFORMANCE.md`**

After the title paragraph, insert:

```markdown
**Agent skill:** optional `x11-desktop` (`grokhunter skills install`) — fix & tune playbook for Grok Build.
```

- [ ] **Step 3: README skills line**

Replace:

```text
skills/                    grokhunter · pair-programming · aider-grok · nethunter-recon
```

with:

```text
skills/                    grokhunter · pair-programming · aider-grok · x11-desktop · nethunter-recon
                           (install scans skills/*/SKILL.md → ~/.grok/skills)
```

- [ ] **Step 4: FAQ note**

Near the overlay-only completions / skills line, add:

```markdown
Product skills are any `skills/<name>/SKILL.md` in the repo. `grokhunter skills install` copies all of them. Core health is still the coding trio (`skills=N/3`); `x11-desktop` and `nethunter-recon` are optional.
```

- [ ] **Step 5: Run ci-unit again**

Run: `bash scripts/ci-unit.sh`  
Expected: `ALL OK`

- [ ] **Step 6: Commit**

```bash
git add skills/grokhunter/SKILL.md docs/X11-PERFORMANCE.md README.md docs/FAQ.md
git commit -m "docs: cross-link optional x11-desktop skill and scan install"
```

---

### Task 6: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Full unit suite**

```bash
bash scripts/ci-unit.sh
```

Expected: ends with `ALL OK`

- [ ] **Step 2: Live skills status**

```bash
grokhunter skills install
grokhunter skills status
grokhunter status
```

Expected:
- All product skills including `x11-desktop` show `installed`
- `skills=3/3` when core trio present (not 5/3)

- [ ] **Step 3: Uninstall dry-logic check (non-destructive)**

```bash
bash -c '
  set -euo pipefail
  # extract remove_skills behavior against a temp SKILLS_DIR
  ROOT="$(pwd)"
  SKILLS_DIR=$(mktemp -d)
  mkdir -p "$SKILLS_DIR"/{grokhunter,x11-desktop,user-only}
  # simulate remove_skills body
  for d in "$ROOT/skills"/*/; do
    [[ -d "$d" ]] || continue
    name="${d%/}"; name="${name##*/}"
    [[ "$name" == _* ]] && continue
    [[ -f "${d}SKILL.md" ]] || continue
    rm -rf "$SKILLS_DIR/$name"
  done
  test ! -d "$SKILLS_DIR/grokhunter"
  test ! -d "$SKILLS_DIR/x11-desktop"
  test -d "$SKILLS_DIR/user-only"
  rm -rf "$SKILLS_DIR"
  echo uninstall-scan-OK
'
```

Expected: `uninstall-scan-OK`

- [ ] **Step 4: Spec coverage checklist (implementer self-check)**

| Spec requirement | Task |
|------------------|------|
| Scan install | Task 2 |
| Skip `_` prefix | Task 2 + ci |
| Core N/3 | Task 3 (status) / unchanged cmd_status |
| Optional doctor | Task 3 |
| Uninstall repo-only names | Task 3 |
| x11-desktop content | Task 4 |
| Docs pointers | Task 5 |
| ci-unit | Tasks 1–4 |

- [ ] **Step 5: Optional push**

Do **not** push unless the user asks. Leave commits on local `main` (or feature branch if created).

---

## Self-review (plan author)

1. **Spec coverage:** Goals from `2026-08-06-new-skills-x11-desktop-design.md` map to Tasks 2–5; success criteria verified in Task 6.
2. **Placeholders:** None; full SKILL.md body and bash snippets included.
3. **Consistency:** Core trio names identical across status, doctor, and constraints; skill name is `x11-desktop` everywhere.
4. **TDD note:** Task 1 may be softened so Task 2 can commit green before Task 4; final green requires Task 4.

## Execution handoff

After this plan is approved for execution:

1. **Subagent-Driven (recommended)** — one subagent per task + review between tasks  
2. **Inline Execution** — same session with executing-plans checkpoints  

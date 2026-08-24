#!/data/data/com.termux/files/usr/bin/bash
# GrokHunter — Grok Build + Aider + V9 helpers
# Called from lib/actions.sh during install / complete phase.

# Skill discovery (list + CORE) — single source
# shellcheck source=lib/skills-discover.sh
_GH_DISCOVER="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/skills-discover.sh"
if [[ -f "${_GH_DISCOVER}" ]]; then
  # shellcheck disable=SC1090
  source "${_GH_DISCOVER}"
elif [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/lib/skills-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/lib/skills-discover.sh"
elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/lib/skills-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${GROKHUNTER_HOME}/lib/skills-discover.sh"
fi
# Agent discovery (Coding Team) — same overlay roots
_GH_AGENTS_DISCOVER="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/agents-discover.sh"
if [[ -f "${_GH_AGENTS_DISCOVER}" ]]; then
  # shellcheck disable=SC1090
  source "${_GH_AGENTS_DISCOVER}"
elif [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/lib/agents-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/lib/agents-discover.sh"
elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/lib/agents-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${GROKHUNTER_HOME}/lib/agents-discover.sh"
fi
# Persona discovery (subagent overlays) — same overlay roots
_GH_PERSONAS_DISCOVER="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/personas-discover.sh"
if [[ -f "${_GH_PERSONAS_DISCOVER}" ]]; then
  # shellcheck disable=SC1090
  source "${_GH_PERSONAS_DISCOVER}"
elif [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/lib/personas-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/lib/personas-discover.sh"
elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/lib/personas-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${GROKHUNTER_HOME}/lib/personas-discover.sh"
fi
# Role discovery (capability / effort defaults)
_GH_ROLES_DISCOVER="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)/roles-discover.sh"
if [[ -f "${_GH_ROLES_DISCOVER}" ]]; then
  # shellcheck disable=SC1090
  source "${_GH_ROLES_DISCOVER}"
elif [[ -n "${SCRIPT_DIR:-}" && -f "${SCRIPT_DIR}/lib/roles-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/lib/roles-discover.sh"
elif [[ -n "${GROKHUNTER_HOME:-}" && -f "${GROKHUNTER_HOME}/lib/roles-discover.sh" ]]; then
  # shellcheck disable=SC1091
  source "${GROKHUNTER_HOME}/lib/roles-discover.sh"
fi
unset _GH_DISCOVER _GH_AGENTS_DISCOVER _GH_PERSONAS_DISCOVER _GH_ROLES_DISCOVER

# ---------------------------------------------------------------------------
# Path helpers (single resolution path for scripts / bins)
# ---------------------------------------------------------------------------
_gh_overlay_root() {
  local d stamp
  local -a candidates=()
  for d in "${SCRIPT_DIR:-}" "${GROKHUNTER_HOME:-}" "${HOME}/GrokHunter"; do
    candidates+=("${d}")
  done
  stamp="${HOME}/.cache/grokhunter/OVERLAY_ROOT"
  if [[ -r "${stamp}" ]]; then
    d="$(tr -d '[:space:]' < "${stamp}" 2>/dev/null || true)"
    [[ -n "${d}" ]] && candidates+=("${d}")
  fi
  candidates+=("${HOME}/.cache/grokhunter/src")

  for d in "${candidates[@]}"; do
    [[ -n "${d}" ]] || continue
    case "${d}" in
      /dev/fd|/dev/fd/*|/proc/self/fd|/proc/self/fd/*|/proc/*/fd|/proc/*/fd/*) continue ;;
    esac
    if [[ -d "${d}" && -f "${d}/install.sh" ]]; then
      printf '%s\n' "${d}"
      return 0
    fi
  done
  return 1
}

_gh_resolve() {
  local rel="$1"
  local root
  if root="$(_gh_overlay_root)"; then
    if [[ -f "${root}/${rel}" ]]; then
      printf '%s\n' "${root}/${rel}"
      return 0
    fi
  fi
  return 1
}

_gh_install_bin() {
  local rel="$1"
  local dest="$2"
  local src
  if ! src="$(_gh_resolve "${rel}")"; then
    msg -tw "Missing ${rel} in overlay"
    return 1
  fi
  mkdir -p "$(dirname "${dest}")" 2>/dev/null || true
  if command -v install >/dev/null 2>&1; then
    install -m 755 "${src}" "${dest}" 2>/dev/null || cp -f "${src}" "${dest}"
  else
    cp -f "${src}" "${dest}"
  fi
  chmod 755 "${dest}" 2>/dev/null || true
}

# Install primary CLI wrappers into ~/.local/bin (PATH-friendly).
install_cli_bins() {
  msg -t "Installing GrokHunter CLI wrappers → ~/.local/bin"
  local dest_dir="${HOME}/.local/bin"
  local name src
  local installed=0
  mkdir -p "${dest_dir}" 2>/dev/null || true

  for name in grokhunter grokhunter-doctor grok-nethunter aider-grok nh-x11; do
    if src="$(_gh_resolve "bin/${name}")"; then
      if _gh_install_bin "bin/${name}" "${dest_dir}/${name}"; then
        installed=$((installed + 1))
      fi
    fi
  done

  # Also drop into Termux PREFIX/bin when present (host PATH)
  local prefix_bin="${PREFIX:-}/bin"
  if [[ -n "${PREFIX:-}" && -d "${prefix_bin}" ]]; then
    for name in grokhunter grokhunter-doctor grok-nethunter; do
      if _gh_resolve "bin/${name}" >/dev/null 2>&1; then
        _gh_install_bin "bin/${name}" "${prefix_bin}/${name}" 2>/dev/null || true
      fi
    done
  fi

  if [[ ${installed} -gt 0 ]]; then
    msg -ts "Installed ${installed} wrapper(s) under ${dest_dir}"
    msg -a "  Ensure PATH includes ~/.local/bin (profile snippet does this)"
  else
    msg -tw "No CLI wrappers installed — clone full repo with bin/"
  fi

  # Short commands as real bins (work outside interactive shells; not bash aliases only)
  install_cli_shortcuts || true

  # Kali guest: Grok/Termux SSL_CERT_FILE=/etc/tls/cert.pem is missing here.
  if [[ ! -e /etc/tls/cert.pem && -r /etc/ssl/certs/ca-certificates.crt ]]; then
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
      sudo -n mkdir -p /etc/tls 2>/dev/null || true
      sudo -n ln -sfn /etc/ssl/certs /etc/tls/certs 2>/dev/null || true
      sudo -n ln -sf /etc/ssl/certs/ca-certificates.crt /etc/tls/cert.pem 2>/dev/null || true
    fi
  fi

  # Kali / XFCE application menu (GrokHunter submenu)
  install_kali_menu || true

  # Skills + agents + personas + roles for Grok Build runtime discovery
  install_skills || true
  install_agents || true
  install_personas || true
  install_roles || true
}

# Install freedesktop .desktop entries + XFCE applications-merged submenu.
install_kali_menu() {
  local script=""
  script="$(_gh_resolve "scripts/install_kali_menu.sh" || true)"
  if [[ -z "${script}" || ! -f "${script}" ]]; then
    msg -tw "scripts/install_kali_menu.sh missing — skip Kali menu"
    return 0
  fi
  msg -t "Installing Kali / XFCE menu entries (GrokHunter submenu)"
  if bash "${script}"; then
    msg -ts "Kali menu: Applications → GrokHunter"
  else
    msg -tw "Kali menu install had issues — try: bash scripts/install_kali_menu.sh"
  fi
}

# Install ghsu/ght/... as real executables under ~/.local/bin (aliases alone fail in non-interactive shells).
install_cli_shortcuts() {
  local dest_dir="${HOME}/.local/bin"
  mkdir -p "${dest_dir}" 2>/dev/null || true
  local name target
  # name → arguments after grokhunter
  local -a pairs=(
    "ghsu:setup"
    "ght:team"
    "ghd:doctor"
    "ghs:status"
    "ghp:plan"
    "ghm:models"
    "ghk:skills"
    "ghai:ai-smoke"
    "ghn:nethunter-launcher"
  )
  local count=0
  for pair in "${pairs[@]}"; do
    name="${pair%%:*}"
    target="${pair#*:}"
    if [[ "${target}" == "nethunter-launcher" ]]; then
      cat > "${dest_dir}/${name}" <<'EOS'
#!/usr/bin/env bash
# GrokHunter shortcut: ghn → grok-nethunter
set -euo pipefail
export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH}"
if command -v grok-nethunter >/dev/null 2>&1; then
  exec grok-nethunter "$@"
fi
exec grok --fullscreen "$@"
EOS
    else
      cat > "${dest_dir}/${name}" <<EOS
#!/usr/bin/env bash
# GrokHunter shortcut: ${name} → grokhunter ${target}
set -euo pipefail
export PATH="\${HOME}/.grok/bin:\${HOME}/.local/bin:\${PATH}"
if command -v grokhunter >/dev/null 2>&1; then
  exec grokhunter ${target} "\$@"
fi
# Fallback: repo checkout
for d in "\${GROKHUNTER_HOME:-}" "\${HOME}/GrokHunter"; do
  if [[ -n "\${d}" && -x "\${d}/bin/grokhunter" ]]; then
    exec "\${d}/bin/grokhunter" ${target} "\$@"
  fi
done
echo "${name}: grokhunter not found — install wrappers: bash ~/GrokHunter/scripts/install-completions.sh" >&2
exit 127
EOS
    fi
    chmod 755 "${dest_dir}/${name}" 2>/dev/null || true
    count=$((count + 1))
  done
  # Prefer not to shadow GitHub CLI `gh` if present as a real binary we didn't install
  # (do not install `gh` shortcut — conflicts with GitHub CLI)
  if [[ ${count} -gt 0 ]]; then
    msg -ts "Installed ${count} shortcuts under ${dest_dir} (ghsu, ght, ghd, …)"
  fi
}

# Copy repo skills/ into ~/.grok/skills for Grok Build skill discovery.
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
    [[ -d "${src}" && -f "${src}/SKILL.md" ]] || continue
    rm -rf "${dest}" 2>/dev/null || true
    mkdir -p "${dest}" 2>/dev/null || true
    if ! cp -a "${src}/." "${dest}/" 2>/dev/null; then
      if ! cp -R "${src}/"* "${dest}/" 2>/dev/null; then
        msg -tw "Failed to install skill: ${name}"
        continue
      fi
    fi
    if [[ -f "${dest}/SKILL.md" ]]; then
      count=$((count + 1))
    else
      msg -tw "Skill install incomplete (no SKILL.md): ${name}"
    fi
  done < <(_gh_list_skill_names "${root}")
  if [[ ${count} -gt 0 ]]; then
    msg -ts "Installed ${count} skill(s) under ~/.grok/skills"
  else
    msg -tw "No skills installed"
  fi
}

# Copy repo agents/*.md → ~/.grok/agents for Grok Build agent runtime.
# Does not delete user-only agents not in the product scan.
install_agents() {
  msg -t "Installing GrokHunter agents → ~/.grok/agents"
  local root src dest name count=0
  root="$(_gh_overlay_root || true)"
  if [[ -z "${root}" || ! -d "${root}/agents" ]]; then
    msg -tw "No agents/ tree in overlay — skip"
    return 0
  fi
  if ! declare -F _gh_list_agent_names >/dev/null 2>&1; then
    msg -tw "Agent discovery missing (lib/agents-discover.sh) — skip"
    return 0
  fi
  mkdir -p "${HOME}/.grok/agents" 2>/dev/null || true
  while IFS= read -r name; do
    [[ -n "${name}" ]] || continue
    src="${root}/agents/${name}.md"
    dest="${HOME}/.grok/agents/${name}.md"
    [[ -f "${src}" ]] || continue
    if ! cp -f "${src}" "${dest}" 2>/dev/null; then
      msg -tw "Failed to install agent: ${name}"
      continue
    fi
    count=$((count + 1))
  done < <(_gh_list_agent_names "${root}")
  if [[ ${count} -gt 0 ]]; then
    msg -ts "Installed ${count} agent(s) under ~/.grok/agents (runtime: /config-agents)"
  else
    msg -tw "No agents installed"
  fi
}

# Copy repo personas/*.toml → ~/.grok/personas for Grok Build subagent overlays.
# Does not delete user-only personas not in the product scan.
install_personas() {
  msg -t "Installing GrokHunter personas → ~/.grok/personas"
  local root src dest name count=0
  root="$(_gh_overlay_root || true)"
  if [[ -z "${root}" || ! -d "${root}/personas" ]]; then
    msg -tw "No personas/ tree in overlay — skip"
    return 0
  fi
  if ! declare -F _gh_list_persona_names >/dev/null 2>&1; then
    msg -tw "Persona discovery missing (lib/personas-discover.sh) — skip"
    return 0
  fi
  mkdir -p "${HOME}/.grok/personas" 2>/dev/null || true
  while IFS= read -r name; do
    [[ -n "${name}" ]] || continue
    src="${root}/personas/${name}.toml"
    dest="${HOME}/.grok/personas/${name}.toml"
    [[ -f "${src}" ]] || continue
    if ! cp -f "${src}" "${dest}" 2>/dev/null; then
      msg -tw "Failed to install persona: ${name}"
      continue
    fi
    count=$((count + 1))
  done < <(_gh_list_persona_names "${root}")
  if [[ ${count} -gt 0 ]]; then
    msg -ts "Installed ${count} persona(s) under ~/.grok/personas (runtime: /personas)"
  else
    msg -tw "No personas installed"
  fi
}

# Copy repo roles/*.toml → ~/.grok/roles for Grok Build subagent resolution.
install_roles() {
  msg -t "Installing GrokHunter roles → ~/.grok/roles"
  local root src dest name count=0
  root="$(_gh_overlay_root || true)"
  if [[ -z "${root}" || ! -d "${root}/roles" ]]; then
    msg -tw "No roles/ tree in overlay — skip"
    return 0
  fi
  if ! declare -F _gh_list_role_names >/dev/null 2>&1; then
    msg -tw "Role discovery missing (lib/roles-discover.sh) — skip"
    return 0
  fi
  mkdir -p "${HOME}/.grok/roles" 2>/dev/null || true
  while IFS= read -r name; do
    [[ -n "${name}" ]] || continue
    src="${root}/roles/${name}.toml"
    dest="${HOME}/.grok/roles/${name}.toml"
    [[ -f "${src}" ]] || continue
    if ! cp -f "${src}" "${dest}" 2>/dev/null; then
      msg -tw "Failed to install role: ${name}"
      continue
    fi
    count=$((count + 1))
  done < <(_gh_list_role_names "${root}")
  if [[ ${count} -gt 0 ]]; then
    msg -ts "Installed ${count} role(s) under ~/.grok/roles"
  else
    msg -tw "No roles installed"
  fi
}

# ---------------------------------------------------------------------------
# Grok Build
# ---------------------------------------------------------------------------
install_grok_build() {
  msg -t "Installing Grok Build CLI (requires ≥ 1.0.5)"

  local ensure="" profile=""
  ensure="$(_gh_resolve "scripts/ensure_grok.sh" || true)"
  profile="$(_gh_resolve "scripts/install_grok_profile.sh" || true)"

  # ensure_grok already merges the 1.0.5 NetHunter profile when present
  if [[ -n "${ensure}" && -f "${ensure}" ]]; then
    msg -tn "Running shared ensure_grok.sh (Grok Build 1.0.5+)…"
    if bash "${ensure}"; then
      cursor -u1
      msg -ts "Grok Build ready"
    else
      cursor -u1
      msg -tw "ensure_grok.sh reported issues — try: grokhunter ensure --force"
    fi
  else
    msg -tn "Fetching official Grok Build installer…"
    if curl -fsSL --connect-timeout 15 --max-time 180 \
         "${GROKHUNTER_GROK_OFFICIAL_URL:-https://x.ai/cli/install.sh}" | bash; then
      cursor -u1
      msg -ts "Grok Build installed (official)"
      if [[ -n "${profile}" && -f "${profile}" ]]; then
        bash "${profile}" || true
      fi
    else
      cursor -u1
      msg -te "Grok Build install failed"
      return 1
    fi
  fi

  export PATH="${HOME}/.grok/bin:${HOME}/.local/bin:${PATH:-}"
  if command -v grok >/dev/null 2>&1; then
    msg -a "  $(grok --version 2>/dev/null | head -1 || echo grok)"
    local gver
    gver=$(grok --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
    if [[ -n "${gver}" ]]; then
      if ! printf '%s\n%s\n' "1.0.5" "${gver}" | sort -V | head -1 | grep -qx "1.0.5"; then
        msg -tw "Grok Build ${gver} < 1.0.5 — run: grokhunter ensure --force"
      fi
    fi
  fi
}

# ---------------------------------------------------------------------------
# Aider (git-native pair programmer, xAI / Grok 4.6)
# ---------------------------------------------------------------------------
# Run scripts/install_aider.sh inside NetHunter when possible.
# Copies the script into the rootfs so host paths need not be bind-mounted.
_gh_run_install_aider_in_nethunter() {
  local script_path="$1"
  local rootfs="${ROOTFS_DIRECTORY:-/data/data/com.termux/files/kali}"
  local guest_script="/tmp/gh-install-aider.sh"
  local env_prefix="export HOME=/home/kali GROKHUNTER_AIDER_HOME=/home/kali PATH=/home/kali/.local/bin:\$PATH;"

  # Already inside Kali/NetHunter — run locally (no proot hop).
  if [[ -f /etc/os-release ]] && grep -qiE 'kali|nethunter' /etc/os-release 2>/dev/null; then
    env HOME="${GROKHUNTER_AIDER_HOME:-${HOME:-/home/kali}}" \
      GROKHUNTER_AIDER_HOME="${GROKHUNTER_AIDER_HOME:-${HOME:-/home/kali}}" \
      bash "${script_path}"
    return $?
  fi

  if [[ ! -d "${rootfs}" ]]; then
    return 2
  fi

  mkdir -p "${rootfs}/tmp" 2>/dev/null || true
  if ! cp -f "${script_path}" "${rootfs}${guest_script}" 2>/dev/null; then
    # Rootfs tmp not writable from host — try stdin methods only
    guest_script=""
  else
    chmod 755 "${rootfs}${guest_script}" 2>/dev/null || true
  fi

  if declare -F distro_exec >/dev/null 2>&1 && [[ -n "${guest_script}" ]]; then
    distro_exec bash -lc "${env_prefix} bash ${guest_script}"
    return $?
  fi
  if command -v nethunter >/dev/null 2>&1; then
    if [[ -n "${guest_script}" ]]; then
      nethunter /bin/bash -lc "${env_prefix} bash ${guest_script}"
    else
      nethunter /bin/bash -lc "${env_prefix} bash -s" < "${script_path}"
    fi
    return $?
  fi
  if command -v nh >/dev/null 2>&1; then
    if [[ -n "${guest_script}" ]]; then
      nh /bin/bash -lc "${env_prefix} bash ${guest_script}"
    else
      nh /bin/bash -lc "${env_prefix} bash -s" < "${script_path}"
    fi
    return $?
  fi
  return 2
}

_gh_install_aider_helper() {
  local rootfs="${ROOTFS_DIRECTORY:-/data/data/com.termux/files/kali}"
  local host_local_bin="${HOME}/.local/bin"
  local helper_src=""
  helper_src="$(_gh_resolve "bin/aider-grok" || true)"

  if [[ -z "${helper_src}" || ! -f "${helper_src}" ]]; then
    msg -tw "bin/aider-grok missing — clone the repo or re-run from a full tree"
    return 1
  fi
  mkdir -p "${host_local_bin}" 2>/dev/null || true
  _gh_install_bin "bin/aider-grok" "${host_local_bin}/aider-grok" \
    && msg -ts "Helper: ${host_local_bin}/aider-grok"

  if [[ -d "${rootfs}" ]]; then
    mkdir -p "${rootfs}/usr/local/bin" "${rootfs}/home/kali/.local/bin" 2>/dev/null || true
    if cp -f "${helper_src}" "${rootfs}/usr/local/bin/aider-grok" 2>/dev/null; then
      chmod 755 "${rootfs}/usr/local/bin/aider-grok" 2>/dev/null || true
      cp -f "${helper_src}" "${rootfs}/home/kali/.local/bin/aider-grok" 2>/dev/null || true
      chmod 755 "${rootfs}/home/kali/.local/bin/aider-grok" 2>/dev/null || true
      chown kali:kali "${rootfs}/home/kali/.local/bin/aider-grok" 2>/dev/null || true
      msg -ts "Helper also installed in rootfs /usr/local/bin/aider-grok"
    fi
  fi
  return 0
}

install_aider() {
  msg -t "Installing Aider (git-native pair-programmer for Grok)"

  local script_path=""
  local ec=0
  script_path="$(_gh_resolve "scripts/install_aider.sh" || true)"

  if [[ -z "${script_path}" || ! -f "${script_path}" ]]; then
    msg -te "scripts/install_aider.sh missing — clone the full repo"
    msg -a "  Manual:  curl -LsSf https://aider.chat/install.sh | sh"
    return 1
  fi

  # Prefer NetHunter (coding lab); fall back to host only if not available.
  # Shared installer uses uv + managed Python 3.12 (aider-chat rejects 3.13).
  msg -tn "Installing Aider via shared installer (uv + Python 3.12)…"
  if _gh_run_install_aider_in_nethunter "${script_path}"; then
    cursor -u1
    msg -ts "Aider installed inside NetHunter"
  else
    ec=$?
    if [[ "${ec}" -eq 2 ]]; then
      cursor -u1
      msg -tn "No NetHunter exec path — installing on host…"
      if bash "${script_path}"; then
        cursor -u1
        msg -ts "Aider installed on host"
      else
        cursor -u1
        msg -tw "Host Aider install failed — see docs/EDITORS.md"
      fi
    else
      cursor -u1
      msg -tw "NetHunter Aider install had issues — trying host fallback…"
      if bash "${script_path}"; then
        msg -ts "Aider installed on host (fallback)"
      else
        msg -tw "Aider install failed — docs/EDITORS.md or: bash scripts/install_aider.sh"
      fi
    fi
  fi

  _gh_install_aider_helper || true

  msg -a "  Usage:  aider-grok"
  msg -a "  Repair: bash scripts/install_aider.sh   # or GROKHUNTER_FORCE_AIDER=1 …"
  msg -a "  Docs:   docs/EDITORS.md"
}

# ---------------------------------------------------------------------------
# V9 / 4.6 model pickers
# ---------------------------------------------------------------------------
install_v9_models() {
  msg -t "Installing Grok V9 / 4.6 model pickers"

  local script=""
  script="$(_gh_resolve "scripts/install_v9_grok_models.sh" || true)"

  if [[ -n "${script}" && -f "${script}" ]]; then
    msg -tn "Running install_v9_grok_models.sh…"
    if bash "${script}"; then
      cursor -u1
      msg -ts "V9 / 4.6 model pickers installed"
    else
      cursor -u1
      msg -tw "V9 picker install reported issues — try: bash scripts/install_v9_grok_models.sh --force"
    fi
  else
    msg -tw "scripts/install_v9_grok_models.sh not found — skip or clone the repo"
  fi
}

# ---------------------------------------------------------------------------
# Shell completions
# ---------------------------------------------------------------------------
install_shell_completions() {
  msg -t "Installing shell completions"

  local script=""
  script="$(_gh_resolve "scripts/install-completions.sh" || true)"

  if [[ -n "${script}" && -f "${script}" ]]; then
    if bash "${script}"; then
      msg -ts "Completions + profile snippet installed"
    else
      msg -tw "Completions install had issues"
    fi
  else
    msg -tw "scripts/install-completions.sh not found"
  fi
}

# Credits & acknowledgements

GrokHunter Rootless stands on the shoulders of open-source and open-platform work. **Please credit and support the projects and organizations below.** GrokHunter is an **overlay** for an AI coding lab — not a re-claim of their work, and **not affiliated** with them.

---

## 1. jorexdeveloper — install engine (primary)

### [jorexdeveloper](https://github.com/jorexdeveloper)

**Developer jorexdeveloper** created and maintains the Termux-based Linux / NetHunter install tooling that GrokHunter hooks into.

| Project | Repository | Role in GrokHunter |
|---------|------------|--------------------|
| **termux-nethunter** | [github.com/jorexdeveloper/termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter) | Installs **Kali NetHunter Rootless** on Android via Termux + proot |
| **termux-distro** | [github.com/jorexdeveloper/termux-distro](https://github.com/jorexdeveloper/termux-distro) | Shared **distro install engine** (`termux-distro.sh`) for rootfs pull/configure |

**What we reuse:** `termux-distro.sh` lifecycle engine (default from jorexdeveloper main), NetHunter rootless model (`nethunter` / `nh` launchers), and action-hook points that `lib/actions.sh` implements for the coding-lab overlay.

**License:** GPL-3.0 (both projects).  
**Thank you** — without this work, the lab would not exist in its current form.  
Please star: [termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter) · [termux-distro](https://github.com/jorexdeveloper/termux-distro) · [jorexdeveloper](https://github.com/jorexdeveloper)

---

## 2. Termux team — host platform

### [Termux](https://github.com/termux) · [termux.dev](https://termux.dev)

The **Termux** project provides the Android terminal environment, package ecosystem, and proot-related tooling that host the entire rootless lab.

| Project | Repository / site | Role in GrokHunter |
|---------|-------------------|--------------------|
| **Termux** | [github.com/termux/termux-app](https://github.com/termux/termux-app) | Host shell, `pkg`, storage, no-root Android Linux userland |
| **termux-packages** | [github.com/termux/termux-packages](https://github.com/termux/termux-packages) | curl, tar, proot, python, and other host packages |
| **Termux:X11** | [github.com/termux/termux-x11](https://github.com/termux/termux-x11) | Low-latency X11 display for `nh-x11` desktops |

**What we reuse:** Termux as the only supported host (F-Droid / GitHub builds, not Play Store), host PATH/`PREFIX`, optional Termux:X11 + PulseAudio for the coding desktop, and community conventions around rootless Android development.

**Thank you** to the Termux developers and package maintainers who keep unrooted Android usable as a real development environment.  
Support: [termux.dev](https://termux.dev) · [github.com/termux](https://github.com/termux)

---

## 3. Kali Linux / Offensive Security — NetHunter rootfs

### [Kali Linux](https://www.kali.org/) · [Offensive Security](https://www.offsec.com/)

**Kali Linux** and **Offensive Security** publish the **Kali NetHunter** rootfs images and documentation that become the guest system under proot.

| Resource | URL | Role in GrokHunter |
|----------|-----|--------------------|
| **Kali NetHunter** | [kali.org/tools/kali-nethunter](https://www.kali.org/tools/kali-nethunter/) | Product name and rootless image lineage |
| **NetHunter rootfs** | [kali.download/nethunter-images](https://kali.download/nethunter-images/) | Official `nano` / `minimal` / `full` rootfs archives + SHA256SUMS |
| **Kali docs** | [kali.org/docs](https://www.kali.org/docs/) | Distro usage, packages, desktop stacks |

**What we reuse:** Official NetHunter rootfs tarballs (and live checksums when available), Kali package ecosystem (`apt`) inside the guest for toolchains and desktops, and the public NetHunter rootless concept on Android.

GrokHunter’s **mission is a coding lab**, not an offensive-security product. We use the NetHunter **rootfs and packages** as a capable Linux environment for building software.

**Thank you** to the Kali team and Offensive Security for publishing NetHunter images and documentation.  
Support: [kali.org](https://www.kali.org/) · [offsec.com](https://www.offsec.com/)

> **Not affiliated with Offensive Security.** “Kali” and “NetHunter” are trademarks of their respective owners.

---

## 4. xAI — Grok Build & models

### [xAI](https://x.ai) · [Grok Build](https://x.ai/cli) · [docs](https://docs.x.ai)

**xAI** provides **Grok Build** (the `grok` CLI/TUI agent) and the **Grok** model APIs that power pair-programming in this lab.

| Resource | URL | Role in GrokHunter |
|----------|-----|--------------------|
| **Grok Build** | [x.ai/cli](https://x.ai/cli) · [x.ai/build](https://x.ai/build) | Official coding agent binary, TUI, headless `-p`, skills runtime |
| **API** | [api.x.ai](https://api.x.ai) · [docs.x.ai](https://docs.x.ai) | Model inference (e.g. `grok-4.6`), OpenAI-compatible endpoints |
| **Changelog** | [x.ai/build/changelog](https://x.ai/build/changelog) | Product versioning (lab targets Grok Build **1.0.5+**) |

**What we reuse:** Official installers (`x.ai/cli/install.sh` and related), `~/.grok` layout, config/models/skills discovery, and API access via SuperGrok / X Premium+ session or `XAI_API_KEY`.

**Thank you** to xAI for Grok Build and the Grok model family that make on-device agentic coding practical.  
Support: [x.ai](https://x.ai) · [x.ai/cli](https://x.ai/cli)

> **Not affiliated with xAI.** GrokHunter configures and launches Grok Build; it does not ship xAI’s proprietary agent binary as its own product.

---

## 5. Other components

| Project | Credit |
|---------|--------|
| **Aider** | Optional git-native pair tool — [aider.chat](https://aider.chat) |
| **Astral uv** | Used by the Aider install path for managed Python — [astral.sh/uv](https://github.com/astral-sh/uv) |
| **Tookie-OSINT** | Optional scoped username lookup (`tookie-osint` / `brib.py`) — [github.com/Alfredredbird/tookie-osint](https://github.com/Alfredredbird/tookie-osint) |

---

## GrokHunter project

- **GrokHunter Rootless** enhancements (overlay, CLI, skills, agents, docs, website) © contributors in git history, including FineComputer14451.
- **Not affiliated** with xAI, Offensive Security, the Termux project, or jorexdeveloper — we gratefully **build upon** their work with attribution.
- License for this repository’s own files: see [LICENSE](LICENSE). Upstream packages keep their own licenses.

---

## How credit appears in the product

| Surface | Attribution |
|---------|-------------|
| README | Top blurb + full Credits section |
| Website | Hero, Credits table, footer |
| `grokhunter credits` | CLI full attribution |
| `grokhunter doctor` | Credits section for all four pillars |
| Installer | Header comments + post-install thank-you |
| Install banner | Engine line + CREDITS.md |
| MOTD | Multi-line upstream thanks |
| Kali menu | Credits entry |
| Architecture / FAQ / INSTALL | Foundation docs |
| Agents / skills | Credit rules when discussing stack |
| GitHub About | Description names upstream lineage |
| This file | Canonical credit statement |

If you fork GrokHunter, **please retain this CREDITS.md** and the README credits block.

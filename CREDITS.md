# Credits & acknowledgements

GrokHunter Rootless stands on the shoulders of open-source work. **Primary credit for the NetHunter rootless stack belongs to the upstream authors below.**

---

## Primary upstream — jorexdeveloper

### [jorexdeveloper](https://github.com/jorexdeveloper)

**Developer jorexdeveloper** created and maintains the Termux-based Linux / NetHunter install engine that GrokHunter builds on.

| Project | Repository | Role in GrokHunter |
|---------|------------|--------------------|
| **termux-nethunter** | [github.com/jorexdeveloper/termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter) | Installs **Kali NetHunter Rootless** on Android via Termux + proot |
| **termux-distro** | [github.com/jorexdeveloper/termux-distro](https://github.com/jorexdeveloper/termux-distro) | Shared **distro install engine** (`termux-distro.sh`) used to pull and configure rootfs images |

### What GrokHunter reuses

- The **install engine** (`termux-distro.sh` from [jorexdeveloper/termux-distro](https://github.com/jorexdeveloper/termux-distro)), resolved by default from:
  ```
  https://raw.githubusercontent.com/jorexdeveloper/termux-distro/main/termux-distro.sh
  ```
- The **NetHunter rootless install model** popularized by [termux-nethunter](https://github.com/jorexdeveloper/termux-nethunter): Termux host, proot guest, `nethunter` / `nh` launchers, official Kali NetHunter rootfs.
- Lifecycle **action hooks** (`pre_install_actions`, `pre_complete_actions`, …) that the upstream engine invokes — GrokHunter’s `lib/actions.sh` implements those hooks for the coding-lab overlay.

GrokHunter is an **overlay / enhancement** for an AI coding lab (Grok Build, skills, agents, desktop helpers). It is **not** a replacement for termux-nethunter or termux-distro, and it does **not** claim authorship of that engine.

### Upstream licenses

- **termux-nethunter** — GPL-3.0  
- **termux-distro** — GPL-3.0  

When the installer downloads and runs the upstream engine, that software remains under its original license and copyright holders.

### Thank you

Thank you to **jorexdeveloper** for building and maintaining rootless Linux-on-Termux tooling that makes NetHunter coding labs on unrooted Android practical. Please star and support the upstream projects:

- https://github.com/jorexdeveloper/termux-nethunter  
- https://github.com/jorexdeveloper/termux-distro  
- https://github.com/jorexdeveloper  

---

## Other components

| Project / org | Credit |
|---------------|--------|
| **Termux** | Host environment, packages, proot — [termux](https://github.com/termux) |
| **Termux:X11** | Desktop display — [termux/termux-x11](https://github.com/termux/termux-x11) |
| **Offensive Security / Kali** | NetHunter rootfs images — [kali.org](https://www.kali.org/) / Kali NetHunter |
| **xAI** | Grok Build CLI / models — [x.ai](https://x.ai) |
| **Aider** | Optional git-native pair tool — [aider.chat](https://aider.chat) |

---

## GrokHunter project

- **GrokHunter Rootless** enhancements (overlay, CLI, skills, agents, docs, website) © contributors listed in git history, including FineComputer14451.
- **Not affiliated** with xAI, Offensive Security, or jorexdeveloper — we gratefully **build upon** their work with attribution.
- License for this repository’s own files: see [LICENSE](LICENSE).

---

## How credit appears in the product

| Surface | Attribution |
|---------|-------------|
| README | Credits section + links |
| Website footer / Credits | Named credit to jorexdeveloper |
| Installer (`install.sh`) | Header comment + engine URL |
| Install banner | “Engine: jorexdeveloper/termux-distro” |
| Architecture docs | Historical + supply-chain section |
| This file | Canonical credit statement |

If you fork GrokHunter, **please retain this CREDITS.md** and the README credits block.

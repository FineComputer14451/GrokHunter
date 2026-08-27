# GrokHunter website

Static product site for [GrokHunter](https://github.com/FineComputer14451/GrokHunter) **v1.0.10**.

**Live:** https://finecomputer14451.github.io/GrokHunter/

No npm. Pages are stitched from `website/_src/` by `scripts/build-website.py`.
Generated HTML is committed so a phone can open the files without running the stitch.

## Pages

| File | Content |
|------|---------|
| `index.html` | Hero, stats, why, features, links to the rest |
| `install.html` | Install + overlay-only + upgrade |
| `cli.html` | Command list (Grok TUI vs lab TUI vs XFCE `menu`) |
| `desktop.html` | XFCE / Termux:X11 / `nh-x11` / binds / XFCE submenu |
| `agents.html` | Stack, Coding Team, personas / roles |
| `faq.html` | Architecture, FAQ, credits |
| `404.html` | GitHub Pages fallback |
| `site.json` | Version + catalog counts + TUI wording |

## Build

```bash
python3 scripts/build-website.py
python3 -m http.server 8080 -d website
# http://localhost:8080
```

`site.json` counts `agents/*.md` (minus README/HANDOFF/REFERENCES), `personas/*.toml`, `roles/*.toml`, and `skills/*/` directories.

## Deploy

Workflow: [`.github/workflows/deploy-website.yml`](../.github/workflows/deploy-website.yml)

1. Pages source: **GitHub Actions**
2. Workflow runs `python3 scripts/build-website.py`, copies `website/` to `_site`, drops `_src/` and `README.md`
3. URL: https://finecomputer14451.github.io/GrokHunter/

Relative links only (`cli.html`, not `/GrokHunter/cli.html`) so project Pages and `file://` both work.

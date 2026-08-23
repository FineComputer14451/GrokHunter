# GrokHunter website

Static product landing page for [GrokHunter](https://github.com/FineComputer14451/GrokHunter) **v1.0.3**.

**Live:** https://finecomputer14451.github.io/GrokHunter/

## Sections

| Section | Content |
|---------|---------|
| Hero | Quick install + animated terminal (1.0.3 stack) |
| Stats | Version / Grok min / agents / personas / roles |
| Why | Comparison table |
| Features | 9 feature cards (Grok Build 1.0.5, Grok 4.6, agents, Aider, …) |
| Stack | skills · agents · personas · roles |
| Agents | Coding Team loop + roster table |
| Personas & roles | Full product lists |
| Install | One-liner, full, clone, overlay-only + flags |
| CLI | Full `grokhunter` command list |
| Upgrade | Paste-ready 1.0.3 upgrade path |
| Architecture | Overlay layers |
| FAQ | Rootless, auth, Aider 3.13, X11, scope |

## Open locally

```bash
python3 -m http.server 8080 -d website
# then open http://localhost:8080
```

Or open `index.html` directly in a browser.

## Deploy

Workflow: [`.github/workflows/deploy-website.yml`](../.github/workflows/deploy-website.yml)

1. Pages source: **GitHub Actions** (already enabled for this repo)
2. Push `website/**` to `main` **or** **Actions → Deploy website → Run workflow**
3. URL: https://finecomputer14451.github.io/GrokHunter/

No Node/npm build — pure static HTML/CSS/JS. Brand tokens: `styles.css` (Grok cyan `#00E5C7` · Kali blue `#2777FF` · NetHunter red `#E31C3D`). Assets: `website/assets/` (favicon, lockup, social preview).

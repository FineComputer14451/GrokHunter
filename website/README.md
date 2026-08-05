# GrokHunter website

Static product landing page for [GrokHunter](https://github.com/FineComputer14451/GrokHunter).

## Open locally

```bash
python3 -m http.server 8080 -d website
# then open http://localhost:8080
```

Or open `index.html` directly in a browser.

## Deploy with GitHub Actions (recommended)

Workflow: [`.github/workflows/deploy-website.yml`](../.github/workflows/deploy-website.yml)

1. **Settings → Pages**
2. **Build and deployment → Source:** GitHub Actions  
   (not “Deploy from a branch”)
3. Push to `main` (changes under `website/`) **or** run the workflow manually:  
   **Actions → Deploy website → Run workflow**
4. Site URL (after first success):  
   `https://finecomputer14451.github.io/GrokHunter/`

The workflow copies `website/` into a Pages artifact (no Node/npm build). Brand tokens live in `styles.css`.

### Manual / branch deploy (optional)

If you prefer branch deploy instead of Actions:

1. Settings → Pages → Source: **Deploy from a branch**
2. Branch: `main` · folder: `/website`

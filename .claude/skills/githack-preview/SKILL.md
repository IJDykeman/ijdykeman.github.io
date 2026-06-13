---
name: githack-preview
description: One OPTIONAL way to get a public preview URL for static/built web output (e.g. a Jekyll site or wasm demo) when the sandbox has no inbound port preview and outbound tunnels are blocked. Use only if a tunnel/native preview isn't available; needs outbound git over HTTPS.
---

# githack preview (optional)

When you can't run a tunnel (TLS-inspecting egress, no inbound port preview) but
**outbound git works**, serve the built output straight from the branch via
raw.githack.com (a CDN that adds correct Content-Type, incl. `application/wasm`).

## Steps
1. Build the site into a committed folder (the GitHub proxy only allows pushing
   the current branch, so serve from it — don't make a `gh-pages` branch).
2. For a Jekyll site, build with a baseurl matching the CDN path so links/assets
   resolve, e.g. `jekyll build -d preview --baseurl "/<owner>/<repo>/<branch>/preview"`.
3. Commit + push, then share:
   `https://raw.githack.com/<owner>/<repo>/<branch>/preview/index.html`

## Cache gotcha (important)
The branch URL is served through GitHub's raw CDN (~5 min stale). To hand over a
**guaranteed-latest** link, pin to the commit SHA (immutable, no cache lag):
`https://raw.githack.com/<owner>/<repo>/<COMMIT_SHA>/preview/index.html`
Give a fresh pinned link each deploy.

## Caveats
- Not live-reload — it's push-to-refresh.
- Public (anyone with the link). Don't use for private content.
- For a normal preview, prefer the platform's native preview or a real tunnel.

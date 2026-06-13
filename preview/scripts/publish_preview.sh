#!/usr/bin/env bash
#
# publish_preview.sh - push-to-refresh public preview of the blog, with no
# inbound tunnel and no extra infrastructure.
#
# Why this exists: Claude Code's cloud sandbox is outbound-only (a security
# egress proxy, no inbound port preview) and its TLS-inspecting gateway only
# forwards HTTP/HTTPS on 80/443, which blocks every hosted reverse-tunnel
# (cloudflared:7844, ngrok cert-pinning, pinggy raw-SSH, localtunnel data
# port, tunnelmole:8083). Outbound git over 443 *does* work, so instead of
# tunnelling the live server we build the static site into the repo and let a
# CDN serve it straight from this branch.
#
# How: build Jekyll into preview/ with a baseurl that matches the CDN path,
# commit, and push to the current branch. The site is then viewable at
#   https://raw.githack.com/<owner>/<repo>/<branch>/preview/index.html
# raw.githack.com mirrors raw.githubusercontent.com with correct Content-Type
# headers and only lightly caches, so re-running this script refreshes the
# public preview within a minute or two.
#
# Note: the GitHub proxy only allows pushing to the current working branch, so
# this deliberately serves from this branch rather than a gh-pages branch, and
# never touches the production github.io Pages site.
#
# Usage:  scripts/publish_preview.sh
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$(ruby -e 'print Gem.bindir' 2>/dev/null):$PATH"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# owner/repo parsed from the origin remote (e.g. .../git/Owner/repo)
SLUG="$(git remote get-url origin | sed -E 's#^.*/git/##; s#\.git$##')"
BASEURL="/${SLUG}/${BRANCH}/preview"
CDN="https://raw.githack.com${BASEURL}/index.html"

echo "Building site for CDN preview..."
echo "  slug=$SLUG branch=$BRANCH"
rm -rf preview
jekyll build -d preview --baseurl "$BASEURL" \
  >/tmp/blogdemo/preview_build.log 2>&1 || { cat /tmp/blogdemo/preview_build.log; exit 1; }

git add -A preview
if git diff --cached --quiet; then
  echo "No changes to publish."
else
  git commit -q -m "Update blog preview build" >/dev/null
  for i in 1 2 3 4; do
    git push -u origin "$BRANCH" && break || { echo "push failed, retry $i"; sleep $((2**i)); }
  done
fi

echo
echo "Public preview (push-to-refresh): $CDN"
echo "Re-run scripts/publish_preview.sh after edits to update it."

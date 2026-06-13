#!/usr/bin/env bash
#
# serve_demo.sh - live-refreshing preview of the blog with a public URL.
#
# Serves the Jekyll site behind browser-sync (which auto-reloads the browser
# on every edit) and exposes it through a Cloudflare quick tunnel so it can be
# viewed from anywhere -- including from an isolated Claude Code cloud session
# that has no inbound port preview.
#
# Pipeline:
#   jekyll serve (:4000)  -- regenerates _site on source changes
#       |> browser-sync proxy (:3000) -- injects the live-reload client,
#                                         watches _site, reloads on rebuild
#       |> cloudflared quick tunnel    -- public https://<random>.trycloudflare.com
#
# Network: the tunnel needs these hosts on the environment egress allowlist
# (set Network access -> Custom in the cloud environment settings):
#
#   api.trycloudflare.com
#   *.trycloudflare.com
#   *.argotunnel.com
#   *.cftunnel.com
#
# Usage:  scripts/serve_demo.sh
# Logs:   /tmp/blogdemo/{jekyll,bs,cf}.log
# Stop:   pkill -f 'jekyll serve|browser-sync|cloudflared'
#
set -euo pipefail
cd "$(dirname "$0")/.."

export PATH="$(ruby -e 'print Gem.bindir' 2>/dev/null):$PATH"
LOGDIR=/tmp/blogdemo
mkdir -p "$LOGDIR"

# --- dependencies (installed only if missing) ---------------------------------
command -v jekyll >/dev/null 2>&1 || \
  gem install jekyll jekyll-theme-minimal bundler --no-document
command -v browser-sync >/dev/null 2>&1 || \
  npm install -g browser-sync
CF=/usr/local/bin/cloudflared
if [ ! -x "$CF" ]; then
  CF="$PWD/.cloudflared-bin"
  [ -x "$CF" ] || {
    curl -fsSL -o "$CF" \
      https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x "$CF"
  }
fi

# --- clean any previous run ---------------------------------------------------
pkill -9 -f 'jekyll serve' 2>/dev/null || true
pkill -9 -f browser-sync   2>/dev/null || true
pkill -9 -f cloudflared    2>/dev/null || true
sleep 1

# --- build once, then serve + watch ------------------------------------------
jekyll build --incremental >"$LOGDIR/jekyll_build.log" 2>&1 || true

setsid nohup jekyll serve --host 127.0.0.1 --port 4000 --incremental \
  --skip-initial-build >"$LOGDIR/jekyll.log" 2>&1 &

setsid nohup browser-sync start --proxy 127.0.0.1:4000 --files "_site/**/*" \
  --no-open --no-ui --port 3000 --host 0.0.0.0 >"$LOGDIR/bs.log" 2>&1 &

# wait for the local preview to answer
for _ in $(seq 1 30); do
  curl -fsS -o /dev/null http://localhost:3000/ 2>/dev/null && break || sleep 1
done

# --- public tunnel (http2 so it traverses the HTTP egress proxy) -------------
setsid nohup "$CF" tunnel --url http://localhost:3000 --protocol http2 \
  --no-autoupdate >"$LOGDIR/cf.log" 2>&1 &

URL=""
for _ in $(seq 1 40); do
  URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOGDIR/cf.log" | head -1 || true)
  [ -n "$URL" ] && break || sleep 1
done

echo
echo "Local preview : http://localhost:3000"
if [ -n "$URL" ]; then
  echo "Public preview: $URL"
else
  echo "Public preview: not ready -- check $LOGDIR/cf.log"
  echo "  (most likely the tunnel hosts are not on the network egress allowlist)"
fi
echo "Edit any source file and the browser reloads automatically."

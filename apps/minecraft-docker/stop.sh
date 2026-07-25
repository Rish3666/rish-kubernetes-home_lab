#!/usr/bin/env sh
# stop.sh — Gracefully stop the Minecraft Forge server
set -eu
. "$(dirname "$0")/_common.sh"

if ! is_running; then
  warn "Server is not running."
  exit 0
fi

log "Sending /stop to server console..."
docker exec "$CONTAINER" rcon-cli stop 2>/dev/null || true

log "Waiting for container to exit (up to 30 s)..."
docker stop --time 30 "$CONTAINER"
ok "Server stopped."

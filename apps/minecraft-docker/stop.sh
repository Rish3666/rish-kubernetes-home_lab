#!/usr/bin/env sh
# stop.sh — Gracefully stop the Minecraft Forge server
set -eu
. "$(dirname "$0")/_common.sh"

if ! is_running && ! systemctl is-active --quiet playit 2>/dev/null && ! sudo systemctl is-active --quiet playit 2>/dev/null; then
  warn "Server and playit are not running."
  exit 0
fi

if is_running; then
  log "Sending /stop to server console..."
  docker exec "$CONTAINER" rcon-cli stop 2>/dev/null || true

  log "Waiting for container to exit (up to 30 s)..."
  docker stop --time 30 "$CONTAINER"
  ok "Server stopped."
else
  warn "Server is not running."
fi

log "Stopping playit tunnel..."
sudo systemctl stop playit 2>/dev/null && ok "Playit stopped." || warn "Could not stop playit."

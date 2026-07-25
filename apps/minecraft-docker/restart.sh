#!/usr/bin/env sh
# restart.sh — Restart the Minecraft Forge server
set -eu
. "$(dirname "$0")/_common.sh"

log "Restarting minecraft server..."

if is_running; then
  log "Sending /stop to server console..."
  docker exec "$CONTAINER" rcon-cli stop 2>/dev/null || true
  docker stop --time 30 "$CONTAINER"
fi

docker start "$CONTAINER" 2>/dev/null || compose up -d "$SERVICE"
ok "Server restarted.  Follow logs: ./logs.sh"

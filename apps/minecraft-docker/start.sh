#!/usr/bin/env sh
# start.sh — Start the Minecraft Forge server
set -eu
. "$(dirname "$0")/_common.sh"

log "Starting minecraft server..."

if container_exists; then
  if is_running; then
    warn "Server is already running. Use ./restart.sh to restart it."
    exit 0
  fi
  docker start "$CONTAINER"
  ok "Server started.  Follow logs: ./logs.sh"
else
  log "No container found — first deploy..."
  compose up -d "$SERVICE"
  ok "Server deployed & started.  Follow logs: ./logs.sh"
fi

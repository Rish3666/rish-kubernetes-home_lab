#!/usr/bin/env sh
# deploy.sh — Pull latest image and (re)deploy the server
set -eu
. "$(dirname "$0")/_common.sh"

if is_running; then
  log "Server is running — stopping before redeploy..."
  docker exec "$CONTAINER" rcon-cli stop 2>/dev/null || true
  docker stop --time 30 "$CONTAINER" || true
fi

log "Pulling latest image..."
compose pull "$SERVICE"

log "Deploying..."
compose up -d "$SERVICE"
ok "Server deployed.  Follow logs: ./logs.sh"

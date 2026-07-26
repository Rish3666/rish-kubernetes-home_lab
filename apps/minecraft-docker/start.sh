#!/usr/bin/env sh
# start.sh — Start the Minecraft server and playit tunnel
set -eu
. "$(dirname "$0")/_common.sh"

log "Starting minecraft server..."

if container_exists; then
  if is_running; then
    warn "Server is already running. Use ./restart.sh to restart it."
  else
    docker start "$CONTAINER"
    ok "Server started."
  fi
else
  log "No container found — first deploy..."
  compose up -d "$SERVICE"
  ok "Server deployed & started."
fi

log "Starting playit tunnel..."
if systemctl --user is-active --quiet playit 2>/dev/null; then
  ok "Playit already running."
elif sudo systemctl start playit 2>/dev/null; then
  ok "Playit started."
else
  warn "Could not start playit — run manually: sudo systemctl start playit"
fi

printf '\n%s── Connect via ─────────────────────────────────────────%s\n' "$CYAN" "$RESET"
echo "  Playit tunnel: sales-arguments.gl.joinmc.link"
echo "  Follow logs:   ./logs.sh"

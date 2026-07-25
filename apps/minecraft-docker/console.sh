#!/usr/bin/env sh
# console.sh — Attach to the Minecraft server console (type commands directly)
set -eu
. "$(dirname "$0")/_common.sh"

if ! is_running; then
  err "Server is not running. Start it first with ./start.sh"
  exit 1
fi

log "Attaching to server console (Ctrl-P Ctrl-Q to detach)..."
docker attach "$CONTAINER"

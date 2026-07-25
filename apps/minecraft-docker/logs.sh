#!/usr/bin/env sh
# logs.sh — Tail live server logs (Ctrl-C to exit)
set -eu
. "$(dirname "$0")/_common.sh"

LINES=${1:-50}
log "Tailing last $LINES lines then following live output (Ctrl-C to quit)..."
compose logs --tail="$LINES" -f --no-log-prefix "$SERVICE"

#!/usr/bin/env sh
# status.sh — Show container state, resource usage, and recent logs
set -eu
. "$(dirname "$0")/_common.sh"

printf '\n%s══ Container ══════════════════════════════════════════════%s\n' "$CYAN" "$RESET"
compose ps

printf '\n%s══ Resources ══════════════════════════════════════════════%s\n' "$CYAN" "$RESET"
if is_running; then
  docker stats --no-stream --format \
    "CPU: {{.CPUPerc}}   MEM: {{.MemUsage}}   NET: {{.NetIO}}   DISK: {{.BlockIO}}" \
    "$CONTAINER"
else
  warn "Container is not running — no resource stats available."
fi

printf '\n%s══ Last 60 log lines ═══════════════════════════════════════%s\n' "$CYAN" "$RESET"
compose logs --tail=60 --no-log-prefix "$SERVICE" 2>/dev/null || true

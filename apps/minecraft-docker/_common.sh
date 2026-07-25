# _common.sh — shared helpers, sourced by every script
# Do NOT run this file directly.

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
SERVICE="minecraft"
CONTAINER="minecraft"

# ── colour helpers ────────────────────────────────────────────────────────────
_c() { printf '\033[%sm' "$1"; }
BOLD=$(_c 1) RED=$(_c 31) GREEN=$(_c 32) YELLOW=$(_c 33) CYAN=$(_c 36) RESET=$(_c 0)

log()  { printf '%s[MC]%s %s\n'        "$CYAN"   "$RESET" "$*"; }
ok()   { printf '%s[OK]%s %s\n'        "$GREEN"  "$RESET" "$*"; }
warn() { printf '%s[WARN]%s %s\n'      "$YELLOW" "$RESET" "$*"; }
err()  { printf '%s[ERR]%s %s\n' "$RED"    "$RESET" "$*" >&2; }

# ── docker / compose wrappers ─────────────────────────────────────────────────
compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose -f "$COMPOSE_FILE" "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose -f "$COMPOSE_FILE" "$@"
  else
    err "docker compose not found. Install Docker with Compose support first."
    exit 1
  fi
}

container_exists() {
  docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER}$"
}

is_running() {
  docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER}$"
}

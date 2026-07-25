#!/usr/bin/env sh
# playit-start.sh — Start the playit tunnel agent on the host
set -eu
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

if ! command -v playit >/dev/null 2>&1; then
  printf '\033[31m[ERR]\033[0m playit is not installed or not in PATH.\n' >&2
  printf '     Install it from: https://playit.gg/support/run-on-linux/\n' >&2
  exit 1
fi

printf '\033[36m[MC]\033[0m Starting playit tunnel...\n'
exec playit "$@"

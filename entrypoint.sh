#!/bin/bash
set -euo pipefail

PROXY_USERNAME="${PROXY_USERNAME:-proxyuser}"

if [ -z "${PROXY_PASSWORD:-}" ]; then
  echo "Error: PROXY_PASSWORD is required." >&2
  exit 1
fi

if [[ ! "$PROXY_USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
  echo "Error: PROXY_USERNAME must start with a lowercase letter or underscore and contain only lowercase letters, numbers, underscores, or hyphens." >&2
  exit 1
fi

case "$PROXY_PASSWORD" in
  *$'\n'*|*$'\r'*)
  echo "Error: PROXY_PASSWORD must be a single line." >&2
  exit 1
  ;;
esac

if getent passwd "$PROXY_USERNAME" >/dev/null; then
  if [ "$PROXY_USERNAME" != "proxyuser" ]; then
    echo "Error: PROXY_USERNAME conflicts with an existing system account." >&2
    exit 1
  fi
else
  useradd --system --no-create-home --shell /usr/sbin/nologin "$PROXY_USERNAME"
fi

printf '%s:%s\n' "$PROXY_USERNAME" "$PROXY_PASSWORD" | chpasswd
unset PROXY_PASSWORD

echo "Starting Dante SOCKS5 server..."
exec danted -f /etc/danted.conf

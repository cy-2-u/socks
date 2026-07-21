#!/bin/bash
set -euo pipefail

PROXY_USERNAME="${PROXY_USERNAME:-proxyuser}"
RUNTIME_CONFIG="/tmp/danted.conf"

if [ -z "${PROXY_PASSWORD:-}" ]; then
  echo "Error: PROXY_PASSWORD is required." >&2
  exit 1
fi

if [[ ! "$PROXY_USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
  echo "Error: PROXY_USERNAME must start with a lowercase letter or underscore and contain only lowercase letters, numbers, underscores, or hyphens." >&2
  exit 1
fi

case "$PROXY_USERNAME" in
  root|daemon|bin|sys|sync|games|man|lp|mail|news|uucp|proxy|www-data|backup|list|irc|_apt|nobody)
    echo "Error: PROXY_USERNAME must not be a built-in system account." >&2
    exit 1
    ;;
esac

case "$PROXY_PASSWORD" in
  *$'\n'*|*$'\r'*)
    echo "Error: PROXY_PASSWORD must be a single line." >&2
    exit 1
    ;;
esac

if ! getent passwd "$PROXY_USERNAME" >/dev/null; then
  useradd --system --no-create-home --shell /usr/sbin/nologin "$PROXY_USERNAME"
fi

EXTERNAL_IP=""
for ip in $(hostname -I); do
  if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    EXTERNAL_IP="$ip"
    break
  fi
done

if [ -z "$EXTERNAL_IP" ]; then
  echo "Error: Could not determine container IPv4 address." >&2
  exit 1
fi

printf '%s:%s\n' "$PROXY_USERNAME" "$PROXY_PASSWORD" | chpasswd
unset PROXY_PASSWORD

sed "s/__EXTERNAL_IP__/$EXTERNAL_IP/g" /etc/danted.conf > "$RUNTIME_CONFIG"

echo "Starting Dante SOCKS5 server..."
exec danted -f "$RUNTIME_CONFIG"

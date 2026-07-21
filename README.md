# Railway SOCKS5 Proxy

A small Dockerized SOCKS5 proxy for Railway, powered by Dante.

## Deploy

1. Create a Railway service from this repository.
2. Set `PROXY_PASSWORD` in the service variables.
3. Optional: set `PROXY_USERNAME` if you do not want the default `proxyuser`.
4. In the service Networking settings, enable **TCP Proxy**.
5. Set the TCP Proxy internal port to `1080`.
6. Use the generated `RAILWAY_TCP_PROXY_DOMAIN` and `RAILWAY_TCP_PROXY_PORT`.

SOCKS5 needs Railway TCP Proxy, not the normal HTTP public domain.

## Credentials

- Username: value of `PROXY_USERNAME`, or `proxyuser` by default
- Password: value of `PROXY_PASSWORD`

The container refuses to start when `PROXY_PASSWORD` is missing. There is no committed fallback password.

## Test

```bash
curl --socks5-hostname "${RAILWAY_TCP_PROXY_DOMAIN}:${RAILWAY_TCP_PROXY_PORT}" \
  --proxy-user "${PROXY_USERNAME:-proxyuser}:${PROXY_PASSWORD}" \
  https://checkip.amazonaws.com
```

For local Docker testing:

```bash
docker build -t railway-socks5-proxy .
docker run --rm -p 1080:1080 -e PROXY_PASSWORD='change-this-password' railway-socks5-proxy
```

Then, in another terminal:

```bash
curl --socks5-hostname 127.0.0.1:1080 \
  --proxy-user 'proxyuser:change-this-password' \
  https://checkip.amazonaws.com
```

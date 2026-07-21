FROM debian:12-slim

WORKDIR /app

# Install Dante and the small shell runtime used by the entrypoint.
RUN apt-get update && apt-get install -y --no-install-recommends \
    dante-server \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Create the default SOCKS account without a password.
RUN useradd --system --no-create-home --shell /usr/sbin/nologin proxyuser

COPY danted.conf /etc/danted.conf
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh

EXPOSE 1080

ENTRYPOINT ["/app/entrypoint.sh"]

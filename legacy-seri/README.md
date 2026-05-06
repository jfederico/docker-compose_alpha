# Legacy Seri Bridge

This folder contains the temporary internal HTTP bridge used during the alpha
cutover.

Alpha Caddy terminates TLS and forwards traffic to:

```text
LEGACY_SERI_HTTP=http://SERI_LAN_IP:8080
```

The bridge keeps the current Host/path routing on Seri, but removes public TLS,
Certbot, and HTTP-to-HTTPS redirect behavior from this path.

## Enable On Seri

From the old `home-proxy-docker-compose` directory:

```bash
cp ../docker-compose_alpha/legacy-seri/.env.example .env.alpha-bridge
```

Edit `.env.alpha-bridge`:

```text
ALPHA_BRIDGE_BIND=SERI_LAN_IP
```

Validate:

```bash
docker compose \
  --env-file .env \
  --env-file .env.alpha-bridge \
  -f docker-compose.yml \
  -f ../docker-compose_alpha/legacy-seri/docker-compose.alpha-bridge.yml \
  config
```

Start or recreate Nginx with the bridge:

```bash
docker compose \
  --env-file .env \
  --env-file .env.alpha-bridge \
  -f docker-compose.yml \
  -f ../docker-compose_alpha/legacy-seri/docker-compose.alpha-bridge.yml \
  up -d nginx
```

## Local Smoke Test

From a host that can reach Seri:

```bash
curl -I -H 'Host: glcpo.net' http://SERI_LAN_IP:8080/
curl -I -H 'Host: go.glcpo.net' http://SERI_LAN_IP:8080/
curl -I -H 'Host: links-go.glcpo.net' http://SERI_LAN_IP:8080/
curl -I -H 'Host: knx1.com' http://SERI_LAN_IP:8080/
```

## Security

Expose port `8080` only to alpha. Do not publish this bridge directly to the
internet.

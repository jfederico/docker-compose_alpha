# Cutover Checklist

## Before DNS Changes

- Rotate Cloudflare tokens that were present in the old proxy `.env`.
- Create the alpha LXC and assign a stable LAN IP.
- Copy `docker-compose_alpha` to the LXC.
- Create `.env` and `cloudflare/ddns.env` from the examples.
- Prepare the temporary Seri HTTP bridge on an internal-only port using
  `legacy-seri/docker-compose.alpha-bridge.yml`.
- Start alpha Caddy and confirm it can reach `LEGACY_SERI_HTTP`.
- Validate Caddy config:

```bash
docker compose --env-file .env -f compose.yml exec caddy caddy validate --config /etc/caddy/Caddyfile
```

## Smoke Tests Before Public Cutover

Run these from a machine that can reach alpha:

```bash
curl -I --resolve glcpo.net:443:ALPHA_IP https://glcpo.net/
curl -I --resolve go.glcpo.net:443:ALPHA_IP https://go.glcpo.net/
curl -I --resolve links-go.glcpo.net:443:ALPHA_IP https://links-go.glcpo.net/
curl -I --resolve knx1.com:443:ALPHA_IP https://knx1.com/
curl -I --resolve 123it.top:443:ALPHA_IP https://123it.top/
curl -I --resolve standrews560.top:443:ALPHA_IP https://standrews560.top/
```

## DNS Cutover

- Update Cloudflare/DDNS records to point to alpha.
- Confirm Cloudflare records are proxied where desired.
- Confirm Caddy has issued certificates under `data/caddy/data`.
- Confirm old `home-proxy` is no longer bound to public DNS.

## After Cutover

- Watch Caddy logs.
- Watch Seri bridge logs.
- Keep the old proxy files intact until all public hostnames are stable.
- Move one service at a time from `10-legacy-seri.caddy` to
  `20-migrated-apps.caddy`.

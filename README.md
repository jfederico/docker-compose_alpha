# docker-compose_alpha

Alpha is the new edge/core LXC stack. It starts by taking over public ingress
only: Caddy terminates TLS, Cloudflare DDNS points records at alpha, and traffic
is forwarded to the current Seri deployment through a temporary internal HTTP
bridge.

## Layout

- `compose.yml`: alpha services
- `caddy/`: Caddy image, main config, snippets, and route files
- `cloudflare/`: local-only env templates for DDNS
- `legacy-seri/`: templates for the temporary old-host bridge
- `docs/`: architecture, cutover, rollback, and migration notes
- `data/`: runtime Caddy state, certs, config, and logs; ignored by git

## First Boot

1. Copy env templates into local-only files:

```bash
cp .env.example .env
cp cloudflare/ddns.env.example cloudflare/ddns.env
```

2. Edit `.env` and `cloudflare/ddns.env` with the alpha LXC values.
3. Prepare the Seri HTTP bridge before changing DNS.
4. Validate the stack:

```bash
docker compose --env-file .env -f compose.yml config
docker compose --env-file .env -f compose.yml pull --ignore-buildable
docker compose --env-file .env -f compose.yml build caddy
docker compose --env-file .env -f compose.yml up -d
```

5. Test host-header routing to alpha before DNS cutover.

The helper script and Make targets wrap the common commands:

```bash
scripts/alpha.sh config
scripts/alpha.sh pull
scripts/alpha.sh build
scripts/alpha.sh up
scripts/alpha.sh logs caddy
```

Before starting alpha on the LXC, run:

```bash
scripts/alpha.sh preflight
```

Smoke test alpha before DNS cutover:

```bash
ALPHA_IP=172.16.0.110 scripts/smoke-alpha.sh
```

The hostname inventory lives in `config/domain-inventory.tsv`; update it when a
hostname moves from Seri to a dedicated LXC.

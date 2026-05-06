# Migration Plan

## Phase 1: Edge Cutover

Alpha runs:

- `caddy`
- `cloudflare-ddns`

All public hostnames forward to Seri through `LEGACY_SERI_HTTP`.

## Phase 2: First App Moves

Good early candidates:

- `links-go.glcpo.net`
- `dashboard-go.glcpo.net`
- smaller static or simple app hostnames

For each hostname:

1. Start the target app in its new LXC.
2. Smoke test it directly on the LAN.
3. Move the hostname from `10-legacy-seri.caddy` to `20-migrated-apps.caddy`.
4. Reload Caddy.
5. Smoke test through the public hostname.
6. Update `config/domain-inventory.tsv`.

## Phase 3: Core Services

Move core services only after ingress is stable:

- Pi-hole/network services
- databases
- shared storage and backups

Databases should be migrated with snapshots and application downtime windows,
not as part of the first proxy cutover.

## Phase 4: Legacy Removal

When no route points to `LEGACY_SERI_HTTP`:

- stop the Seri HTTP bridge
- remove legacy route blocks
- archive old `home-proxy-docker-compose`
- keep certificate and DNS runbooks updated

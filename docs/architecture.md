# Architecture

## Target Shape

```text
Cloudflare DNS / DDNS
        |
        v
alpha LXC
  Caddy :80/:443
  Cloudflare DNS-01 certificates
  Cloudflare DDNS
        |
        +--> temporary Seri HTTP bridge
        +--> migrated app LXCs
        +--> future alpha-local core services
```

Alpha owns public ingress. Other application stacks should not share alpha's
Docker network unless they genuinely live inside the alpha LXC.

## Why Caddy

Caddy replaces the old Nginx and Certbot split. With the Cloudflare DNS plugin,
Caddy can issue and renew LetsEncrypt certificates by DNS-01 challenge, which
works even when Cloudflare records are proxied.

## Migration Model

All hostnames start in `caddy/routes/10-legacy-seri.caddy` and forward to
`LEGACY_SERI_HTTP`. When a service moves to a new LXC:

1. Remove its hostname from `10-legacy-seri.caddy`.
2. Add a dedicated route in `20-migrated-apps.caddy`.
3. Reload Caddy.
4. Smoke test the hostname.

DNS should continue to point at alpha during this process.

## Secrets

The current workspace has live Cloudflare values in the old proxy `.env`. Rotate
those tokens before alpha is exposed, then store replacements only in ignored
local files:

- `.env`
- `cloudflare/ddns.env`

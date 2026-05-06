# Rollback

Rollback should be DNS-first and boring.

## If Alpha Fails Before DNS Cutover

- Stop alpha.
- Leave Cloudflare DNS pointed at the old target.
- Fix alpha offline.

## If Alpha Fails After DNS Cutover

1. Point Cloudflare/DDNS records back to the old public target.
2. Re-enable the old `home-proxy` public listener if it was stopped.
3. Confirm HTTPS works from the public internet.
4. Leave alpha running only on the LAN for debugging, or stop it.

## If One Migrated App Fails

1. Move that hostname back into `10-legacy-seri.caddy`.
2. Remove or comment its block from `20-migrated-apps.caddy`.
3. Reload Caddy.
4. Debug the migrated app while public traffic uses Seri again.

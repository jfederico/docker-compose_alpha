#!/usr/bin/env sh
set -eu

if [ -z "${ALPHA_IP:-}" ]; then
  echo "Set ALPHA_IP to the alpha LXC IP before running smoke tests." >&2
  echo "Example: ALPHA_IP=172.16.0.110 $0" >&2
  exit 2
fi

if [ -z "${HOSTS:-}" ] && [ -f "$(dirname -- "$0")/../config/hosts.txt" ]; then
  HOSTS="$(grep -v '^#' "$(dirname -- "$0")/../config/hosts.txt" | tr '\n' ' ')"
else
  HOSTS="${HOSTS:-glcpo.net go.glcpo.net links-go.glcpo.net dashboard-go.glcpo.net knx1.com 123it.top 123it.ca standrews560.top}"
fi

for host in $HOSTS; do
  echo "==> $host"
  curl -fsSIk --resolve "$host:443:$ALPHA_IP" "https://$host/" >/dev/null
done

echo "Smoke tests passed."

#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

check_file() {
  if [ ! -f "$1" ]; then
    echo "missing: $1"
    failures=$((failures + 1))
  fi
}

check_no_placeholder() {
  file="$1"
  pattern="$2"
  label="$3"

  if [ -f "$file" ] && grep -q "$pattern" "$file"; then
    echo "placeholder still present: $label in $file"
    failures=$((failures + 1))
  fi
}

check_file .env
check_file cloudflare/ddns.env
check_file caddy/Caddyfile
check_file caddy/routes/10-legacy-seri.caddy
check_file legacy-seri/nginx/alpha-bridge.conf

check_no_placeholder .env "replace-with" "secret value"
check_no_placeholder .env "seri-lan-ip" "LEGACY_SERI_HTTP"
check_no_placeholder cloudflare/ddns.env "replace-with" "Cloudflare DDNS token"

if [ -f .env ]; then
  legacy_upstream="$(grep '^LEGACY_SERI_HTTP=' .env | tail -n 1 | cut -d= -f2- || true)"
  case "$legacy_upstream" in
    http://*:8080) ;;
    "")
      echo "missing: LEGACY_SERI_HTTP in .env"
      failures=$((failures + 1))
      ;;
    *)
      echo "unexpected LEGACY_SERI_HTTP value: use http://SERI_LAN_IP:8080"
      failures=$((failures + 1))
      ;;
  esac
fi

if command -v docker >/dev/null 2>&1; then
  docker compose --env-file .env.example -f compose.yml config --quiet
else
  echo "warning: docker is not installed or not in PATH; skipped compose validation"
fi

if [ "$failures" -ne 0 ]; then
  echo "Preflight failed with $failures issue(s)."
  exit 1
fi

echo "Preflight passed."

#!/usr/bin/env sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  echo "Missing .env. Copy .env.example to .env and edit it first." >&2
  exit 1
fi

case "${1:-}" in
  config)
    docker compose --env-file .env -f compose.yml config
    ;;
  build)
    docker compose --env-file .env -f compose.yml build caddy
    ;;
  up)
    docker compose --env-file .env -f compose.yml up -d
    ;;
  down)
    docker compose --env-file .env -f compose.yml down
    ;;
  restart)
    docker compose --env-file .env -f compose.yml restart
    ;;
  ps)
    docker compose --env-file .env -f compose.yml ps
    ;;
  logs)
    docker compose --env-file .env -f compose.yml logs -f "${2:-}"
    ;;
  validate)
    docker compose --env-file .env -f compose.yml exec caddy caddy validate --config /etc/caddy/Caddyfile
    ;;
  preflight)
    ./scripts/preflight.sh
    ;;
  tunnel-up)
    docker compose --env-file .env -f compose.yml --profile tunnel up -d
    ;;
  *)
    echo "Usage: $0 {config|build|up|down|restart|ps|logs|validate|preflight|tunnel-up}" >&2
    exit 2
    ;;
esac

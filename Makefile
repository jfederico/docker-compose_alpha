COMPOSE = docker compose --env-file .env -f compose.yml

.PHONY: config pull build up down restart ps logs validate preflight smoke

config:
	$(COMPOSE) config

pull:
	$(COMPOSE) pull --ignore-buildable

build:
	$(COMPOSE) build caddy

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

validate:
	$(COMPOSE) exec caddy caddy validate --config /etc/caddy/Caddyfile

preflight:
	./scripts/preflight.sh

smoke:
	./scripts/smoke-alpha.sh

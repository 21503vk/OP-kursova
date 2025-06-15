# Файл: Makefile
# Makefile за управление на Docker Compose проекта

.PHONY: help build up down logs clean test dev prod

# Променливи
COMPOSE_FILE = compose.yml
DEV_COMPOSE_FILE = compose.dev.yml
PROD_COMPOSE_FILE = compose.prod.yml
PROJECT_NAME = microservices-app

help: ## Показва помощна информация
	@echo "Достъпни команди:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Изгражда всички Docker образи
	docker compose -f $(COMPOSE_FILE) build

up: ## Стартира всички услуги
	docker compose -f $(COMPOSE_FILE) up -d

down: ## Спира всички услуги
	docker compose -f $(COMPOSE_FILE) down

logs: ## Показва логовете на всички услуги
	docker compose -f $(COMPOSE_FILE) logs -f

clean: ## Изчиства всички контейнери, volumes и images
	docker compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -f

test: ## Стартира тестовете
	@chmod +x scripts/test_api.sh
	@./scripts/test_api.sh

dev: ## Стартира в development режим
	docker compose -f $(COMPOSE_FILE) -f $(DEV_COMPOSE_FILE) up -d

prod: ## Стартира в production режим
	docker compose -f $(COMPOSE_FILE) -f $(PROD_COMPOSE_FILE) up -d

restart: ## Рестартира всички услуги
	docker compose -f $(COMPOSE_FILE) restart

status: ## Показва статуса на услугите
	docker compose -f $(COMPOSE_FILE) ps

shell-backend: ## Отваря shell в backend контейнера
	docker compose -f $(COMPOSE_FILE) exec backend /bin/bash

shell-db: ## Отваря psql в database контейнера
	docker compose -f $(COMPOSE_FILE) exec db psql -U postgres -d appdb

shell-redis: ## Отваря redis-cli в redis контейнера
	docker compose -f $(COMPOSE_FILE) exec redis redis-cli

backup-db: ## Прави backup на базата данни
	mkdir -p backups
	docker compose -f $(COMPOSE_FILE) exec db pg_dump -U postgres appdb > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql

restore-db: ## Възстановява базата данни от backup (използвайте BACKUP_FILE=filename)
	@if [ -z "$(BACKUP_FILE)" ]; then echo "Моля укажете BACKUP_FILE=filename"; exit 1; fi
	docker compose -f $(COMPOSE_FILE) exec -T db psql -U postgres -d appdb < $(BACKUP_FILE)

scale-backend: ## Scaling на backend услугата (използвайте REPLICAS=число)
	@if [ -z "$(REPLICAS)" ]; then echo "Моля укажете REPLICAS=число"; exit 1; fi
	docker compose -f $(COMPOSE_FILE) up -d --scale backend=$(REPLICAS)

push: ## Публикува образите в Docker Hub
	docker compose -f $(COMPOSE_FILE) build
	docker tag $(PROJECT_NAME)_backend:latest yourusername/microservices-backend:latest
	docker push yourusername/microservices-backend:latest

pull: ## Изтегля най-новите образи
	docker compose -f $(COMPOSE_FILE) pull

update: pull up ## Обновява и рестартира услугите

monitor: ## Показва resource usage на контейнерите
	docker stats
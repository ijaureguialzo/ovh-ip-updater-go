help:
	@echo 'Options:'
	@echo ''
	@echo 'start | stop | restart | stop-all'
	@echo 'update'
	@echo 'logs'
	@echo 'stats'
	@echo 'clean'

start:
	@docker-compose up -d --remove-orphans ovh-ip-updater-go

stop:
	@docker-compose stop

restart: stop start

stop-all:
	@docker stop `docker ps -aq`

_build:
	@docker-compose build --pull

update: _build start

logs:
	@docker-compose logs ovh-ip-updater-go

stats:
	@docker stats

clean:
	@docker-compose down -v

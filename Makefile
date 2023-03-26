#!make

ifneq (,$(wildcard ./.env))
    include .env
    export
else
$(error No se encuentra el fichero .env)
endif

help: _header
	${info }
	@echo Opciones:
	@echo ----------------------
	@echo start / stop / restart
	@echo build / update
	@echo logs
	@echo stats
	@echo clean
	@echo ----------------------

_header:
	@echo --------------
	@echo OVH IP Updater
	@echo --------------

start:
	@docker compose up -d --remove-orphans ovh-ip-updater-go

stop:
	@docker compose stop

restart: stop start

build:
	@docker compose build --pull

update: build start

logs:
	@docker compose logs ovh-ip-updater-go

stats:
	@docker stats

clean:
	@docker compose down -v

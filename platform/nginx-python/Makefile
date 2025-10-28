# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings

ifeq ($(strip $(OS)),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...
    DETECTED_OS := Windows
	C_BLU=''
	C_GRN=''
	C_RED=''
	C_YEL=''
	C_END=''
else
    DETECTED_OS := $(shell uname) # same as "uname -s"
	C_BLU='\033[0;34m'
	C_GRN='\033[0;32m'
	C_RED='\033[0;31m'
	C_YEL='\033[0;33m'
	C_END='\033[0m'
endif

include ../../.env

DOCKER_PLTF="NGINX 1.28 / PYTHON 3.12"
DOCKER_LEAD=$(PROJECT_LEAD)
DOCKER_CNET=$(PROJECT_CNET)
DOCKER_HOST=$(PROJECT_HOST)
DOCKER_IMGK=$(APIREST_IMGK)
DOCKER_CAAS=$(APIREST_CAAS)
DOCKER_PORT=$(APIREST_PORT)
DOCKER_BIND=$(APIREST_BIND)
DOCKER_MEM=$(APIREST_CAAS_MEM)
DOCKER_SWAP=$(APIREST_CAAS_SWAP)
DOCKER_USER=$(APIREST_CAAS_USER)
DOCKER_GROUP=$(APIREST_CAAS_GROUP)

ROOT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(ROOT_DIR))

DOCKER_CONTAINER:=$(addsuffix -$(DOCKER_CAAS), $(DOCKER_LEAD))
DOCKER_COMPOSE_RUN=$(DOCKER_COMPOSE) run -v --rm
DOCKER_EXEC_SSH=$(DOCKER) exec -it $(DOCKER_CONTAINER) sh

APPLICATION_UPDATE='npm -u'
APPLICATION_INSTALL='npm -i'
APPLICATION_INSTALL_BASE='npm -i [package]'
APPLICATION_INSTALL_PACKAGES='npm require [package] && \
composer require [package] --dev && \
composer require [package] --dev && \
composer require [package]'

# -------------------------------------------------------------------------------------------------
#  Help
# -------------------------------------------------------------------------------------------------
.PHONY: help

help: ## shows this Makefile help message
	echo "Usage: $$ make "${C_GRN}"[target]"${C_END}
	echo ${C_GRN}"Targets:"${C_END}
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "$$ make \033[0;33m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: port-check

port-check: ## shows this project port availability on local machine
	echo "Checking configuration for "${C_YEL}"$(DOCKER_PLTF)"${C_END}" container:";
	if [ -z "$($(DOCKER) lsof -i :$(DOCKER_PORT))" ]; then \
		echo ${C_BLU}"$(DOCKER_PLTF)"${C_END}" > localhost:"${C_GRN}"$(DOCKER_PORT) is free to use."${C_END}; \
    else \
		echo ${C_BLU}"$(DOCKER_PLTF)"${C_END}" > localhost:"${C_RED}"$(DOCKER_PORT) is busy. Update ./.env file."${C_END}; \
	fi

# -------------------------------------------------------------------------------------------------
#  Enviroment
# -------------------------------------------------------------------------------------------------
.PHONY: env env-set

env: ## checks if docker .env file exists
	if [ -f ./docker/.env ]; then \
		echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" - $(DOCKER_PLTF) "${C_YEL}"docker-compose.yml"${C_END}" .env file "${C_GRN}"is set."${C_END}; \
	else \
		echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" - $(DOCKER_PLTF) "${C_YEL}"docker-compose.yml"${C_END}" .env file "${C_RED}"is not set."${C_END}" \
		Create it by executing "${C_YEL}"$$ make env-set"${C_END}; \
	fi

env-set: ## sets docker .env file
ifeq ($(DETECTED_OS), Windows)
	echo "Recipe do not support for Windows NT at this moment - You have to manually create .env file from ./docker/.env.example";
else
	echo "COMPOSE_PROJECT_LEAD=\"$(DOCKER_LEAD)\"\r\n\
	COMPOSE_PROJECT_CNET=\"$(DOCKER_CNET)\"\r\n\
	COMPOSE_PROJECT_IMGK=\"$(DOCKER_IMGK)\"\r\n\
	COMPOSE_PROJECT_NAME=\"$(DOCKER_CAAS)\"\r\n\
	COMPOSE_PROJECT_HOST=\"$(DOCKER_HOST)\"\r\n\
	COMPOSE_PROJECT_PORT=$(DOCKER_PORT)\r\n\
	COMPOSE_PROJECT_PATH=\"$(DOCKER_BIND)\"\r\n\
	COMPOSE_PROJECT_MEM=\"$(DOCKER_MEM)\"\r\n\
	COMPOSE_PROJECT_SWAP=\"$(DOCKER_SWAP)\"\r\n\
	COMPOSE_PROJECT_USER=\"$(DOCKER_USER)\"\r\n\
	COMPOSE_PROJECT_GROUP=\"$(DOCKER_GROUP)\"" > ./docker/.env; \
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" APIREST - $(DOCKER_PLTF) "${C_YEL}"docker-compose.yml"${C_END}" .env file "${C_GRN}"has been set."${C_END};
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" APIREST - Container: "${C_GRN}$(DOCKER_CONTAINER)${C_END}
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" APIREST - Max. memory usage: "${C_GRN}$(DOCKER_MEM)${C_END}
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" APIREST - Is going to be served at: "${C_GRN}http://127.0.0.1:$(DOCKER_PORT)${C_END}
endif

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: info ssh build up dev start stop restart clear destroy

info: ## shows container information
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}": "${C_GRN}"$(DOCKER_PLTF)"${C_END};
	printf ${C_YEL}"Container ID.: "${C_END}; $(DOCKER) ps -aqf "name=^$(DOCKER_CONTAINER)$$"; printf "%s";
	echo ${C_YEL}"Name.........: "${C_END}$(DOCKER_CONTAINER);
	echo ${C_YEL}"Image........: "${C_END}"$(DOCKER_CONTAINER):$(DOCKER_IMGK)";
	echo ${C_YEL}"Memory.......: "${C_END}"$(DOCKER_MEM)";
	echo ${C_YEL}"Host.........: "${C_END}"$(DOCKER_HOST):$(DOCKER_PORT)";
	echo ${C_YEL}"Hostname.....: "${C_END}"$(word 1,$(shell hostname -I)):"$(DOCKER_PORT);
	printf ${C_YEL}"Docker.Host..: "${C_END};$(DOCKER) inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(DOCKER_CONTAINER);
	printf ${C_YEL}"NetworkID....: "${C_END};$(DOCKER) inspect -f '{{range.NetworkSettings.Networks}}{{.NetworkID}}{{end}}' $(DOCKER_CONTAINER);

ssh: ## enters the container shell
	$(DOCKER_EXEC_SSH)

build: ## builds the container from Dockerfile
	cd docker && $(DOCKER_COMPOSE) up --build --no-recreate -d

up: ## attaches to containers for a service and also starts any linked services
	cd docker && $(DOCKER_COMPOSE) up -d

start: ## starts the container and put on running
	cd docker && $(DOCKER_COMPOSE) start

stop: ## stops the running container but data won't be destroyed
	cd docker && $(DOCKER_COMPOSE) stop

restart: ## starts the running container
	cd docker && $(DOCKER) restart $(DOCKER_CONTAINER)

clear: ## removes container from Docker running containers
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true

destroy: ## delete container image from Docker cache
	cd docker && $(DOCKER) rmi -f $(DOCKER_CONTAINER):$(DOCKER_IMGK)

dev: ## sets a development enviroment
	cd docker && $(DOCKER_EXEC_TOOLS_APP) -c "npm run dev"

network:
	cd docker && $(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.network.yml up -d

# -------------------------------------------------------------------------------------------------
#  Container Application - latest version: laravel/laravel:^10 .
# -------------------------------------------------------------------------------------------------
.PHONY: app-install app-update app-install-base app-install-packages

app-install: ## installs the latest application dependency packages
	cd docker && $(DOCKER_EXEC_SSH) -c $(APPLICATION_INSTALL)

app-upgrade: ## upgrades current application dependency packages - it is recommended to execute this inside the container
	cd docker && $(DOCKER_EXEC_SSH) -c $(APPLICATION_UPDATE)

app-install-base: ## installs the base framework application
	cd docker && $(DOCKER_EXEC_SSH) -c $(APPLICATION_INSTALL_BASE)

app-install-packages: ## installs the dependencies packages required from project init
	cd docker && $(DOCKER_EXEC_SSH) -c $(APPLICATION_INSTALL_PACKAGES)

# -------------------------------------------------------------------------------------------------
#  Container settings update on the run
# -------------------------------------------------------------------------------------------------
.PHONY: nginx-conf

nginx-conf: ## shows NGINX server block on running container
	$(DOCKER) exec -i $(DOCKER_CONTAINER) sh -c 'cat /etc/nginx/conf.d/default.conf'
	$(MAKE) restart

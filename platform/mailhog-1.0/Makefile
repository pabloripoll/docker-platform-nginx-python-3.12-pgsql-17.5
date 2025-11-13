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

DOCKER_PLTF="MAILHOG 1.0"
DOCKER_LEAD=$(PROJECT_LEAD)
DOCKER_CNET=$(PROJECT_CNET)
DOCKER_HOST=$(PROJECT_HOST)
DOCKER_IMGK=$(MAILER_IMGK)
DOCKER_PORT=$(MAILER_PORT)
DOCKER_CAAS=$(MAILER_CAAS)
DOCKER_CAAS_MEM=$(MAILER_CAAS_MEM)
DOCKER_CAAS_SWAP=$(MAILER_CAAS_SWAP)
DOCKER_APP_PORT=$(MAILER_APP_PORT)

ROOT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(ROOT_DIR))

DOCKER_CONTAINER:=$(addsuffix -$(DOCKER_CAAS), $(DOCKER_LEAD))
DOCKER_COMPOSE_RUN=$(DOCKER_COMPOSE) run -v --rm
DOCKER_EXEC_SSH=$(DOCKER) exec -it $(DOCKER_CONTAINER) sh

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
	COMPOSE_PROJECT_HOST=\"$(DOCKER_HOST)\"\r\n\
	COMPOSE_PROJECT_PORT=$(DOCKER_PORT)\r\n\
	COMPOSE_PROJECT_NAME=\"$(DOCKER_CAAS)\"\r\n\
	COMPOSE_PROJECT_MEM=\"$(DOCKER_CAAS_MEM)\"\r\n\
	COMPOSE_PROJECT_SWAP=\"$(DOCKER_CAAS_SWAP)\"\r\n\
	COMPOSE_PROJECT_APP_PORT=\"$(DOCKER_APP_PORT)\"" > ./docker/.env; \
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" MAIL SERVICE "${C_YEL}$(DOCKER_PLTF)${C_END}" - "${C_YEL}"docker-compose.yml"${C_END}" .env file "${C_GRN}"has been set."${C_END};
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" MAIL SERVICE "${C_YEL}$(DOCKER_PLTF)${C_END}" - Container: "${C_GRN}$(DOCKER_CONTAINER)${C_END}
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" MAIL SERVICE "${C_YEL}$(DOCKER_PLTF)${C_END}" - Max. memory usage: "${C_GRN}$(DOCKER_CAAS_MEM)${C_END}" - swap: "${C_GRN}$(DOCKER_CAAS_SWAP)${C_END}
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" MAIL SERVICE "${C_YEL}$(DOCKER_PLTF)${C_END}" - SMTP is served at: http://"${C_GRN}$(word 1,$(shell hostname -I)):$(DOCKER_PORT)${C_END}
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" MAIL SERVICE "${C_YEL}$(DOCKER_PLTF)${C_END}" - APP/API is served at: http://127.0.0.1:"${C_GRN}$(DOCKER_APP_PORT)${C_END}
endif

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: info ssh build up dev start stop restart clear destroy

info: ## shows container information
	echo ${C_BLU}"$(PROJECT_NAME)"${C_END}" - MAILER: "${C_GRN}"$(DOCKER_PLTF)"${C_END};
	printf ${C_YEL}"Container ID.: "${C_END}; $(DOCKER) ps -aqf "name=^$(DOCKER_CONTAINER)$$"; printf "%s";
	echo ${C_YEL}"Name.........: "${C_END}$(DOCKER_CONTAINER);
	echo ${C_YEL}"Image........: "${C_END}"$(DOCKER_CONTAINER):$(DOCKER_IMGK)";
	echo ${C_YEL}"Memory.......: "${C_END}"$(DOCKER_CAAS_MEM)";
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

restart: ## restarts the running container
	cd docker && $(DOCKER) restart $(DOCKER_CONTAINER)

clear: ## removes container from Docker running containers
	cd docker && $(DOCKER_COMPOSE) kill || true
	cd docker && $(DOCKER_COMPOSE) rm --force || true
	cd docker && $(DOCKER_COMPOSE) down -v --remove-orphans || true

destroy: ## delete container image from Docker cache
	cd docker && $(DOCKER) rmi -f $(DOCKER_CONTAINER):$(DOCKER_IMGK)

dev: ## sets a development enviroment
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};

network:
	cd docker && $(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.network.yml up -d

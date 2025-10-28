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

include .env

APIREST_BRANCH:=develop
APIREST_PROJECT:=$(PROJECT_NAME) - APIREST
APIREST_CONTAINER:=$(addsuffix -$(APIREST_CAAS), $(PROJECT_LEAD))
DATABASE_CONTAINER:=$(addsuffix -$(DATABASE_CAAS), $(PROJECT_LEAD))
ROOT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(ROOT_DIR))

.PHONY: help

# -------------------------------------------------------------------------------------------------
#  Help
# -------------------------------------------------------------------------------------------------

help: ## shows this Makefile help message
	echo "Usage: $$ make "${C_GRN}"[target]"${C_END}
	echo ${C_GRN}"Targets:"${C_END}
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "$$ make \033[0;33m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: local-hostname local-ownership local-ownership-set

local-hostname: ## shows local machine ip and container ports set
	echo "Container Address:"
	echo ${C_BLU}"LOCAL: "${C_END}"$(word 1,$(shell hostname -I))"
	echo ${C_BLU}"APIREST: "${C_END}"$(word 1,$(shell hostname -I)):"$(APIREST_PORT)
	echo ${C_BLU}"DATABASE: "${C_END}"$(word 1,$(shell hostname -I)):"$(DATABASE_PORT)

user ?= ${USER}
group ?= root
local-ownership: ## shows local ownership
	echo $(user):$(group)

local-ownership-set: ## sets recursively local root directory ownership
	$(SUDO) chown -R ${user}:${group} $(ROOT_DIR)/

# -------------------------------------------------------------------------------------------------
#  Backend API Service
# -------------------------------------------------------------------------------------------------
.PHONY: apirest-hostcheck apirest-info apirest-set apirest-create apirest-network apirest-ssh apirest-start apirest-stop apirest-destroy

apirest-hostcheck: ## shows this project ports availability on local machine for apirest container
	cd platform/$(APIREST_PLTF) && $(MAKE) port-check

apirest-info: ## shows the apirest docker related information
	cd platform/$(APIREST_PLTF) && $(MAKE) info

apirest-set: ## sets the apirest enviroment file to build the container
	cd platform/$(APIREST_PLTF) && $(MAKE) env-set

apirest-create: ## creates the apirest container from Docker image
	cd platform/$(APIREST_PLTF) && $(MAKE) build up

apirest-network: ## creates the apirest container network - execute this recipe first before others
	$(MAKE) apirest-stop
	cd platform/$(APIREST_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.network.yml up -d

apirest-ssh: ## enters the apirest container shell
	cd platform/$(APIREST_PLTF) && $(MAKE) ssh

apirest-start: ## starts the apirest container
	cd platform/$(APIREST_PLTF) && $(MAKE) start

apirest-stop: ## stops the apirest container but its assets will not be destroyed
	cd platform/$(APIREST_PLTF) && $(MAKE) stop

apirest-restart: ## restarts the running apirest container
	cd platform/$(APIREST_PLTF) && $(MAKE) restart

apirest-destroy: ## destroys completly the apirest container
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the "${C_BLU}"$(APIREST_PROJECT)"${C_END}" container and delete its image resource."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platform/$(APIREST_PLTF) && $(MAKE) stop clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following command is delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
		else \
			$(DOCKER) system prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

# -------------------------------------------------------------------------------------------------
#  Postgres Database Service
# -------------------------------------------------------------------------------------------------
.PHONY: postgres-hostcheck postgres-info postgres-set postgres-create postgres-ssh postgres-start postgres-stop postgres-destroy

postgres-hostcheck: ## shows this project ports availability on local machine for database container
	cd platform/$(DATABASE_PLTF) && $(MAKE) port-check

postgres-info: ## shows docker related information
	cd platform/$(DATABASE_PLTF) && $(MAKE) info

postgres-set: ## sets the database enviroment file to build the container
	cd platform/$(DATABASE_PLTF) && $(MAKE) env-set

postgres-create: ## creates the database container from Docker image
	cd platform/$(DATABASE_PLTF) && $(MAKE) build up

postgres-network: ## creates the database container external network
	$(MAKE) apirest-stop
	cd platform/$(DATABASE_PLTF) && $(DOCKER_COMPOSE) -f docker-compose.yml -f docker-compose.network.yml up -d

postgres-ssh: ## enters the apirest container shell
	cd platform/$(DATABASE_PLTF) && $(MAKE) ssh

postgres-start: ## starts the database container
	cd platform/$(DATABASE_PLTF) && $(MAKE) start

postgres-stop: ## stops the database container but its assets will not be destroyed
	cd platform/$(DATABASE_PLTF) && $(MAKE) stop

postgres-restart: ## restarts the running database container
	cd platform/$(DATABASE_PLTF) && $(MAKE) restart

postgres-destroy: ## destroys completly the database container with its data
	echo ${C_RED}"Attention!"${C_END};
	echo ${C_YEL}"You're about to remove the database container and delete its image resource and persistance data."${C_END};
	@echo -n ${C_RED}"Are you sure to proceed? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
        echo ${C_GRN}"K.O.! container has been stopped but not destroyed."${C_END}; \
    else \
		cd platform/$(DATABASE_PLTF) && $(MAKE) clear destroy; \
		echo -n ${C_GRN}"Do you want to clear DOCKER cache? "${C_END}"[y/n]: " && read response && if [ $${response:-'n'} != 'y' ]; then \
			echo ${C_YEL}"The following commands are delegated to be executed by user:"${C_END}; \
			echo "$$ $(DOCKER) system prune"; \
			echo "$$ $(DOCKER) volume prune"; \
		else \
			$(DOCKER) system prune; \
			$(DOCKER) volume prune; \
			echo ${C_GRN}"O.K.! DOCKER cache has been cleared up."${C_END}; \
		fi \
	fi

.PHONY: postgres-test-up postgres-test-down

postgres-test-up: ## creates a side database for tests
	$(DOCKER) exec -it $(DATABASE_CONTAINER) sh -c 'dropdb -f $(DATABASE_NAME)_testing -U "$(DATABASE_USER)"; createdb $(DATABASE_NAME)_testing -U "$(DATABASE_USER)"';

postgres-test-down: ## drops the side database for tests
	$(DOCKER) exec -it $(DATABASE_CONTAINER) sh -c 'dropdb -f $(DATABASE_NAME)_testing -U "$(DATABASE_USER)";';

.PHONY: postgres-sql-install postgres-sql-replace postgres-sql-backup postgres-sql-remote postgres-copy-remote

postgres-sql-install: ## installs postgres sql file into the container database to init a project from resources/database
	$(MAKE) local-ownership-set;
	$(DOCKER) exec -i $(DATABASE_CONTAINER) sh -c 'psql -d $(DATABASE_NAME) -U "$(DATABASE_USER)"' < $(ROOT_DIR)$(DATABASE_PATH)$(DATABASE_INIT)
	echo ${C_YEL}"$(PROJECT_NAME) DATABASE"${C_END}" has been copied to container from "${C_BLU}"$(DATABASE_PATH)$(DATABASE_INIT)"${C_END}

postgres-sql-replace: ## replaces the container database with the latest postgres .sql backup file from resources/database
	$(MAKE) local-ownership-set;
	$(DOCKER) exec -i $(DATABASE_CONTAINER) sh -c 'psql -d $(DATABASE_NAME) -U "$(DATABASE_USER)"' < $(ROOT_DIR)$(DATABASE_PATH)$(DATABASE_BACK)
	echo ${C_YEL}"$(PROJECT_NAME) DATABASE"${C_END}" has been replaced from "${C_BLU}"$(DATABASE_PATH)$(DATABASE_BACK)"${C_END}

postgres-sql-backup: ## copies the container database as postgres .sql backup file into resources/database
	$(MAKE) local-ownership-set;
	[ -d .$(DATABASE_PATH)$(DATABASE_BACK) ] || touch .$(DATABASE_PATH)$(DATABASE_BACK)
	$(DOCKER) exec $(DATABASE_CONTAINER) sh -c 'pg_dump -d $(DATABASE_NAME) -U "$(DATABASE_USER)"' > $(ROOT_DIR)$(DATABASE_PATH)$(DATABASE_BACK)
	echo ${C_YEL}"$(PROJECT_NAME) DATABASE"${C_END}" backup has been created at "${C_BLU}"$(DATABASE_PATH)$(DATABASE_BACK)"${C_END}

postgres-sql-drop: ## drops and creates the postgres database into the container for reseting
	$(MAKE) local-ownership-set;
	$(DOCKER) exec -i $(DATABASE_CONTAINER) sh -c 'dropdb -f $(DATABASE_NAME) -U "$(DATABASE_USER)"; createdb $(DATABASE_NAME) -U "$(DATABASE_USER)"'
	echo ${C_YEL}"$(PROJECT_NAME) DATABASE"${C_END}" in container "${C_YEL}"$(DATABASE_CONTAINER)"${C_END}" has been deleted."

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
.PHONY: repo-flush repo-commit

repo-flush: ## clears local git repository cache specially for updating .gitignore on local IDE
	git rm -rf --cached .; git add .; git commit -m "fix: cache cleared for untracked files"

repo-commit: ## echoes common git commands
	echo "git add . && git commit -m \"feat: ... \" && git push -u origin [branch]"
	echo ${C_YEL}"For fixing pushed commit comment:"${C_END}
	echo "git commit --amend"
	echo "git push --force origin [branch]"

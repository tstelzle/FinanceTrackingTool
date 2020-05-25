# MAKEFILE https://github.com/tstelzle/FinanceTrackingTool
# AUTHORS: Tarek Stelzle
#          Richard Stewing

ORIGIN := $(shell git remote -v | grep push | cut -c 8- | rev | cut -c 8- | rev)
BRANCH := $(shell (git branch) | cut -c 3-)
DROP-STASH := git stash drop
CONTAINER-NAME := python_environment
MOUNTPOINT := -v $(PWD)/FinTrack/src:/usr/src
DOCKER-FLAGS := -d -t --rm
DOCKER-NAME := --name $(CONTAINER-NAME)
DOCKER-START-COMMAND := docker run $(DOCKER-FLAGS) $(MOUNTPOINT)  $(DOCKER-NAME) python-environment
START-COMMAND := /usr/local/bin/python main.py
SHELL-IN-CONTAINER := /bin/bash

# Targets that should be run each time they are requested
.PHONY: default docker-start docker-stop development-env production-env start-dev start-prod publish clean

default:
	@echo "Possible Targets:"
	@echo "\tdocker          - Rebuilds docker image"
	@echo "\tdocker-start    - Starts named ($(CONTAINER-NAME)) docker image"
	@echo "\tdocker-stop     - Stops named ($(CONTAINER-NAME)) docker image"
	@echo "\tdevelopment-env - Starts docker image with the current state in working directory"
	@echo "\tproduction-env  - Starts docker image with the current state of master"
	@echo "\tstart-dev       - Start docker image and FinTrack from the current working directoy"
	@echo "\tstart-prod      - Start docker image and FinTrack from the current state of master"
	@echo "\tclean           - Output files from working directory"
	@echo "\tpublish         - Commits all changed files to current branch ($(BRANCH)) and pushes it to origin ($(ORIGIN))"
	@echo "Arguments:"
	@echo "\tDROP-STASH      - Default: \"git stash drop\""
	@echo "\t                  Optional: Can be set to \"\" if the desired behavior is not delete the stash when reapplying it."
	@echo "\t                  Applies to Targets: \"production\""
	@echo "\tMSG             - Default: \"\""
	@echo "\t                  Required: Commit Message when committing and pushing the current branch."
	@echo "\t                  Applies to Targets: \"publish\""
	@echo "\tDOCKER-FLAGS    - Default: -d -t --rm"
	@echo "\t                  Optional: Add or remove flags docker images are started with."
	@echo "\t                  Applies to Targets: \"production-env\", \"development-env\", \"start-dev\", \"start-prod\""
	@echo "\tMOUNTPOINT      - Default: -v $(PWD)/FinTrack/src:/usr/src"
	@echo "\t                  Optional: Selects what directory is exposed to the docker container."
	@echo "\t                  Applies to Targets: \"production-env\", \"development-env\", \"start-dev\", \"start-prod\""


docker: FinTrack/requirements.txt Dockerfile
	docker build  -t python-environment .
	touch docker

docker-stop:
	docker container stop $(CONTAINER-NAME) | true

docker-start: docker docker-stop
	$(DOCKER-START-COMMAND)

development-env: docker-start
	docker exec -it $(CONTAINER-NAME) $(SHELL-IN-CONTAINER)

start-dev: docker-start
	docker exec -it $(CONTAINER-NAME) $(START-COMMAND)

production-env: docker docker-stop
	git stash
	git checkout master
	$(DOCKER-START-COMMAND)
	docker exec -it $(CONTAINER-NAME) $(SHELL-IN-CONTAINER)
	git checkout $(BRANCH)
	git stash apply
	$(DROP-STASH)

start-prod: docker docker-stop
	git stash
	git checkout master
	$(DOCKER-START-COMMAND)
	docker exec -it $(CONTAINER-NAME) $(START-COMMAND)
	git checkout $(BRANCH)
	git stash apply
	$(DROP-STASH)


clean:
	rm docker


publish:
	git commit -m "$(MSG)" -a
	git push

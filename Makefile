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
IGNORE-OUTPUT := > /dev/null 2>&1
SEQ := seq

# Space separated list of version and build numbers that are known to work as expected
SUPPORTED-DOCKER-VERSIONS := 19.03.8 19.03.8-ce
SUPPORTED-DOCKER-BUILDS   := afacb8b afacb8b7f0
SUPPORTED-DOCKER-VERSION-STRINGS = $(foreach i,$(shell $(SEQ) $(words $(SUPPORTED-DOCKER-VERSIONS))),\
  "Docker version $(word $i,$(SUPPORTED-DOCKER-VERSIONS)), build $(word $i,$(SUPPORTED-DOCKER-BUILDS))")

DOCKER-SUPPORT := $(if $(findstring $(shell docker --version),$(SUPPORTED-DOCKER-VERSION-STRINGS)),\
  "Supported Docker version detected.",\
  "Unkown Docker version detected.")

# Targets that should be run each time they are requested
.PHONY: default docker-start docker-stop development-env production-env start-dev start-prod publish clean check

default:
	@echo "Possible Targets:"
	@echo "  docker          - Rebuilds docker image"
	@echo "  docker-start    - Starts named ($(CONTAINER-NAME)) docker image"
	@echo "  docker-stop     - Stops named ($(CONTAINER-NAME)) docker image"
	@echo "  development-env - Starts docker image with the current state in working directory"
	@echo "  production-env  - Starts docker image with the current state of master"
	@echo "  start-dev       - Start docker image and FinTrack from the current working directoy"
	@echo "  start-prod      - Start docker image and FinTrack from the current state of master"
	@echo "  clean           - Output files from working directory"
	@echo "  publish         - Commits all changed files to current branch ($(BRANCH)) and pushes it to origin ($(ORIGIN))"
	@echo "  check           - Checks the installed docker version against known working versions"
	@echo "Arguments:"
	@echo "  DROP-STASH      - Default: \"git stash drop\""
	@echo "                    Optional: Can be set to \"\" if the desired behavior is not delete the stash when reapplying it."
	@echo "                    Applies to Targets: \"production\""
	@echo "  MSG             - Default: \"\""
	@echo "                    Required: Commit Message when committing and pushing the current branch."
	@echo "                    Applies to Targets: \"publish\""
	@echo "  DOCKER-FLAGS    - Default: -d -t --rm"
	@echo "                    Optional: Add or remove flags docker images are started with."
	@echo "                    Applies to Targets: \"production-env\", \"development-env\", \"start-dev\", \"start-prod\""
	@echo "  MOUNTPOINT      - Default: -v $(PWD)/FinTrack/src:/usr/src"
	@echo "                    Optional: Selects what directory is exposed to the docker container."
	@echo "                    Applies to Targets: \"production-env\", \"development-env\", \"start-dev\", \"start-prod\""
	@echo "  IGNORE-OUTPUT   - Default: > /dev/null 2>&1"
	@echo "                    Optional: Can be set to \"\" to enable output for all commands"
	@echo "                    Applies to Targets: \"docker-stop\", \"production-env\", \"start-prod\""


check:
	@echo $(DOCKER-SUPPORT)


.docker: FinTrack/requirements.txt Dockerfile
	docker build  -t python-environment .
	touch .docker

docker: .docker

docker-stop:
	@docker container stop $(CONTAINER-NAME) $(IGNORE-OUTPUT) | true

docker-start: docker docker-stop
	$(DOCKER-START-COMMAND)

development-env: docker-start
	docker exec -it $(CONTAINER-NAME) $(SHELL-IN-CONTAINER)

start-dev: docker-start
	docker exec -it $(CONTAINER-NAME) $(START-COMMAND)

production-env: docker docker-stop
	@git stash $(IGNORE-OUTPUT)
	@git checkout $(IGNORE-OUTPUT)
	$(DOCKER-START-COMMAND)
	docker exec -it $(CONTAINER-NAME) $(SHELL-IN-CONTAINER)
	@git checkout $(BRANCH) $(IGNORE-OUTPUT)
	@git stash apply $(IGNORE-OUTPUT)
	@$(DROP-STASH) $(IGNORE-OUTPUT)


start-prod: docker docker-stop
	@git stash $(IGNORE-OUTPUT)
	@git checkout master $(IGNORE-OUTPUT)
	$(DOCKER-START-COMMAND)
	docker exec -it $(CONTAINER-NAME) $(START-COMMAND)
	@git checkout $(BRANCH) $(IGNORE-OUTPUT)
	@git stash apply $(IGNORE-OUTPUT)
	@$(DROP-STASH) $(IGNORE-OUTPUT)


clean:
	rm .docker


publish:
	git commit -m "$(MSG)" -a
	git push

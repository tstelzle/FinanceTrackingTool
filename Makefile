# MAKEFILE https://github.com/tstelzle/FinanceTrackingTool
# AUTHORS: Tarek Stelzle
#          Richard Stewing

ORIGIN := $(shell git remote -v | grep push | cut -c 8- | rev | cut -c 8- | rev)
BRANCH := $(shell (git branch) | cut -c 3-)
DROP-STASH := git stash drop

# Targets that should be run each time they are requested
.PHONY: default development clean docker-rm

default:
	@echo "Possible Targets:"
	@echo "\tdocker      - Rebuilds docker image"
	@echo "\tdevelopment - Starts docker image with the current state in working directory"
	@echo "\tproduction  - Starts docker image with the current state of master"
	@echo "\tclean       - Output files from working directory"
	@echo "\tpublish     - Commits all changed files to current branch ($(BRANCH)) and pushes it to origin ($(ORIGIN))"
	@echo "Arguments:"
	@echo "\tDROP-STASH  - Default: \"git stash drop\""
	@echo "\t              Optional: Can be set to \"\" if the desired behavior is not delete the stash when reapplying it."
	@echo "\t              Applies to Targets: \"production\""
	@echo "\tMSG         - Default: \"\""
	@echo "\t              Required: Commit Message when committing and pushing the current branch."
	@echo "\t              Applies to Targets: \"publish\""

docker: FinTrack/requirements.txt Dockerfile
	docker build  -t python-environment .
	touch docker

docker-rm:
	docker container stop python_environment
	docker rm python_environment

development: docker 
	docker run -it -v $(PWD)/FinTrack/src:/usr/src --rm --name python_environment python-environment

production: docker
	git stash
	git checkout master
	docker run -it -v $(PWD)/FinTrack/src:/usr/src --rm --name python_environment python-environment
	git checkout $(BRANCH)
	git stash apply
	$(DROP-STASH)

clean:
	rm docker


publish:
	git commit -m "$(MSG)" -a
	git push

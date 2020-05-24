# MAKEFILE https://github.com/tstelzle/FinanceTrackingTool
# AUTHORS: Tarek Stelzle
#          Richard Stewing

ORIGIN := https://github.com/tstelzle/FinanceTrackingTool
BRANCH := $(shell (git branch) | cut -c 3-)
DROP-STASH := git stash drop

# Targets that should be run each time they are requested
.PHONY: default development clean docker-rm

default:
	@echo "Possible Targets:"
	@echo "docker      - rebuilds docker image"
	@echo "development - starts docker image with the current state in working directory"
	@echo "production  - starts docker image with the current state of master"
	@echo "clean       - output files from working directory"

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
	DROP-STASH

clean:
	rm docker



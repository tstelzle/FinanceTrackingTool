# MAKEFILE https://github.com/tstelzle/FinanceTrackingTool
# AUTHORS: Tarek Stelzle
#          Richard Stewing

ORIGIN = https://github.com/tstelzle/FinanceTrackingTool

.PHONY: default

default:
	@echo "Possible Targets:"
	@echo "docker      - rebuilds docker image"
	@echo "development - starts docker image with the current state in working directory"
	@echo "production  - starts docker image with the current state of $(ORIGIN) master"
	@echo "clean       - output files from working directory"

docker: requirements.txt
	docker build -t python-environment .

dev: docker src/*/*.py
	docker run -it --rm --name python_environment python-environment

# prod:
# 	docker exec -it python_environment git clone https://github.com/tstelzle/FincanceTrackingTool /usr/src/prodi \
#        	docker exec -it python_environment pyhton /usr/src/prod/main.py

clean:
	docker exec -it pyhton_environment rm -rf /usr/src/prod

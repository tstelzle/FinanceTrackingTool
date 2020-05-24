default: requirements.txt
	docker build -t python-environment .

dev: requirements.txt main.py
	docker run -it --rm --name python_environment python-environment

prod:
	docker exec -it python_environment git clone https://github.com/tstelzle/FincanceTrackingTool /usr/src/prodi \
       	docker exec -it python_environment pyhton /usr/src/prod/main.py

clean:
	docker exec -it pyhton_environment rm -rf /usr/src/prod

NAME ?= hello-world-kubernetes
INSTANCE ?= hello-world-kubernetes-instance
PORT ?= 43567

install:
	npm install

build:
	docker build -t $(NAME) .

run: build
	docker run -it --rm --entrypoint /bin/bash $(NAME) 

start: build
	docker run -i -t --name $(INSTANCE) -p $(PORT):8080 -d $(NAME)

log:
	docker logs $(INSTANCE)

bash:
	docker exec -it $(INSTANCE) /bin/bash

stop:
	docker stop $(INSTANCE) && docker rm $(INSTANCE)

test:
	curl http://localhost:$(PORT)/

test-health:
	curl http://localhost:$(PORT)/healthz

test-kill:
	curl http://localhost:$(PORT)/kill

clean:
	rm -rf node_modules

.PHONY: install build run test clean

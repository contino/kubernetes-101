NAME ?= hello-world-kubernetes
INSTANCE ?= hello-world-kubernetes-instance
PORT ?= 43567
VERSION-0 ?= 1.0.0
VERSION-1 ?= 1.0.1
VERSION-2 ?= 1.0.2

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

build-0:
	node ./version.js $(VERSION-0)
	docker build -t $(NAME):$(VERSION-0) .

build-1:
	node ./version.js $(VERSION-1)
	docker build -t $(NAME):$(VERSION-1) .
	node ./version.js $(VERSION-0)

build-2:
	node ./version.js $(VERSION-2)
	docker build -t $(NAME):$(VERSION-2) .
	node ./version.js $(VERSION-0)

build-all: build-0 build-1 build-2
	docker images $(NAME)

#Spin up the Pod using container defaults
demo-0:

#Spin up the Pod overridding env variables explicitly
demo-1:

#Spin up the Pod overridding env variables pointing to configmap and secrets. Also configure configmap and secrets as volume mounts
demo-2:


.PHONY: install build run test clean

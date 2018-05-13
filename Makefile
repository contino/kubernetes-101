NAME ?= hello-world-kubernetes
INSTANCE ?= hello-world-kubernetes-instance
CONTAINER-EXPOSED-PORT ?= 8080
PROXY-PORT ?= 32500
VERSION-0 ?= 1.0.0
VERSION-1 ?= 1.0.1
VERSION-2 ?= 1.0.2

install:
	npm install

build:
	docker build -t $(NAME) .

run: build
	docker run -it --rm --entrypoint /bin/ash $(NAME) 

start: build
	docker run -i -t --name $(INSTANCE) -p $(PROXY-PORT):$(CONTAINER-EXPOSED-PORT) -d $(NAME)

log:
	docker logs $(INSTANCE)

bash:
	docker exec -it $(INSTANCE) /bin/ash

stop:
	docker stop $(INSTANCE) && docker rm $(INSTANCE)

test:
	curl http://localhost:$(PROXY-PORT)/

test-health:
	curl http://localhost:$(PROXY-PORT)/healthz

test-kill:
	curl http://localhost:$(PROXY-PORT)/kill

test-small-leak:
	curl http://localhost:$(PROXY-PORT)/small-leak

test-big-leak:
	curl http://localhost:$(PROXY-PORT)/big-leak

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

#Cleanup any leftovers so we can try demo again
demo-cleanup:
	kubectl delete deployments -l name=hello-world-kubernetes-deployment
	kubectl delete services -l name=hello-world-kubernetes-service
	kubectl delete secret -l name=hello-world-kubernetes-secret
	kubectl delete configmap -l name=hello-world-kubernetes-configmap

#Create a deployment
demo-1:
	kubectl apply -f ./kubernetes/1-deployment.yml

#Create a service
demo-2:
	kubectl apply -f ./kubernetes/2-service.yml

#Spin up the Pod overridding env variables explicitly
demo-3:
	kubectl apply -f ./kubernetes/3-env-explicit.yml

#Spin up the Pod overridding env variables pointing to configmap and secrets. Also configure configmap and secrets as volume mounts
demo-4:
	kubectl apply -f ./kubernetes/4-configmaps-and-secrets.yml

#Change configmap and secret which shows runtime configuration
demo-5:
	kubectl apply -f ./kubernetes/5-configmaps-and-secrets-runtime-configuration.yml

.PHONY: install build run test clean
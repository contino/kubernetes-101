NAME ?= hello-world-kubernetes
INSTANCE ?= hello-world-kubernetes-instance
CONTAINER-EXPOSED-PORT ?= 8080
PROXY-PORT ?= 32500
VERSION-0 ?= 1.0.0
VERSION-1 ?= 1.0.1
VERSION-2 ?= 1.0.2
MINIKUBE-IP=`minikube ip`

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
	kubectl delete deployments -l name=hello-world-kubernetes-deployment --now
	kubectl delete services -l name=hello-world-kubernetes-service --now
	kubectl delete secret -l name=hello-world-kubernetes-secret --now
	kubectl delete configmap -l name=hello-world-kubernetes-configmap --now

#Create a deployment
demo-1: 
	kubectl get pods
	kubectl get deployments
	kubectl apply -f ./kubernetes/1-deployment.yml
	sleep 5
	kubectl get pods
	kubectl get deployments
	sleep 8
	kubectl get pods
	kubectl get deployments

#Create a service
demo-2:
	kubectl get services
	kubectl apply -f ./kubernetes/2-service.yml
	sleep 5
	kubectl get services
	curl http://$(minikube ip):$(PROXY-PORT)/
#	curl http://localhost:$(PROXY-PORT)/

#Health check failing. Container gets recreated.
demo-3:
	kubectl get pods
	curl http://$(MINIKUBE-IP):$(PROXY-PORT)/
	curl http://$(MINIKUBE-IP):$(PROXY-PORT)/kill
#	curl http://localhost:$(PROXY-PORT)/
#	curl http://localhost:$(PROXY-PORT)/kill
#	sleep 12
	kubectl get pods

#Health check failing. Container gets recreated.
demo-4:
	kubectl get pods
	curl http://localhost:$(PROXY-PORT)/
	curl http://localhost:$(PROXY-PORT)/big-leak
	timeout 5
	kubectl get pods

#Deploy dodgy container
demo-5:
	kubectl get deployments
	curl http://localhost:$(PROXY-PORT)/
	kubectl apply -f ./kubernetes/5-new-version-faulty.yml
	timeout 12
	kubectl get deployments
	curl http://localhost:$(PROXY-PORT)/
	
#Deploy fixed version
demo-6:
	kubectl get deployments
	curl http://localhost:$(PROXY-PORT)/
	kubectl apply -f ./kubernetes/6-new-version-good.yml
	timeout 12
	kubectl get deployments
	curl http://localhost:$(PROXY-PORT)/

#Spin up the Pod overridding env variables explicitly
demo-7:
	curl http://localhost:$(PROXY-PORT)/
	kubectl apply -f ./kubernetes/7-env-explicit.yml
	timeout 12
	curl http://localhost:$(PROXY-PORT)/

#Spin up the Pod overridding env variables pointing to configmap and secrets. Also configure configmap and secrets as volume mounts
demo-8:
	curl http://localhost:$(PROXY-PORT)/
	kubectl apply -f ./kubernetes/8-configmaps-and-secrets.yml
	timeout 12
	curl http://localhost:$(PROXY-PORT)/

#Change configmap and secret which shows runtime configuration
demo-9:
	curl http://localhost:$(PROXY-PORT)/
	kubectl apply -f ./kubernetes/9-configmaps-and-secrets-runtime-configuration.yml
	timeout 12
	curl http://localhost:$(PROXY-PORT)/	


.PHONY: install build run test clean
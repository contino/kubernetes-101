# Kubernetes 101

This project will demonstrate the basic features of Kubernetes.

## Getting Started

Download and install the pre-requisites

### Prerequisites

- Docker
- Kubernetes
- Node
- Make

> Note: if you're using minikube on mac or linux host and you want to reuse docker daemon from the vm created by minikube avoiding to push images to registries do the following: 
>
>```eval $(minikube docker-env)```
>
>Further info [here](https://github.com/kubernetes/minikube/blob/0c616a6b42b28a1aab8397f5a9061f8ebbd9f3d9/README.md#reusing-the-docker-daemon)

## Demo

It is assumed that we are running a local Kubernetes cluster. This is why the loadbalancer type is set to `NodePort` instead of `Loadbalancer`.

Ensure that container builds and works.
```
make start
make test
make stop
```

Build the three versions of the container for the demos.
```
make build-all
```

Make sure that Kubernetes does not have any pre-existing demo configuration.
```
make demo-cleanup
```

Demo 1 - Spin up a Kubernetes Pod with a deployment
```
make demo-1
```
Outcome: A pod has been created, so its running in Kubernetes.


Demo 2 - Make Kuberentes pod available via Kubernetes service
```
make demo-2
```
Outcome: a pod can now be accessed externally. So we can make http requests against the pod now.

Its interesting to run a few http requests and see them be load balanced between the different pods.
The http response includes useful bit of info:
* Node name
* The version of the app that is running
* ENV variables
* Start time configuration (configmaps & secrets)
* Run time configuration (configmaps & secrets)
* Memory used by host (Often people confuse this with the memory actually allocated to the container)
* Memory user by container


Demo 3 - Health check failing. 
```
make demo-2
make demo-3
```
Outcome: Kubernetes will restart containers that fail health checks. The restart count will be incremented.

Demo 4 - Maximum memory exceeded. 
```
make demo-2
make demo-4
```
Outcome: Kubernetes will immediatly restart containers that exceed their maximum memory limits. The restart count will be incremented. 

Demo 5 - Deploy a faulty container & have no downtime
```
make demo-5
```
Outcome: Kubernetes will attempt to deploy new pods, but as they fail the readiness check it will not get read of old pods. So requests to service will always return a version of 1.0.0 instead of 1.0.1. 

Demo 6 - Deploy a fixed container & have no downtime
```
make demo-6
```
Outcome: Kubernetes will attempt to deploy new pods, and as they pass the readiness check it will get read of old pods. So requests to service will return a version of 1.0.2 instead of 1.0.0.

Demo 7 - Override container ENV variables with explicit values
```
make demo-7
```
Outcome: Only ENV has changed.
* ENV configmap is `2nd env config` and secret is `2nd env secret`. 
* Start time configmap is `undefined` and secret is `undefined` 
* Run time configmap is `undefined` and secret is `undefined` 

Demo 8 - Spin up the Pod overridding env variables pointing to configmap and secrets. Also configure configmap and secrets as volume mounts
```
make demo-8
```
Outcome: ENV, start time and runtime config has changed.
* ENV configmap is `3rd env config` and secret is `3rd env secret`. 
* Start time configmap is `3rd env config` and secret is `3rd env secret`.
* Run time configmap is `3rd env config` and secret is `3rd env secret`.


Demo 9 - Change configmap and secret which shows runtime configuration. Note: it takes ages (can be > 1min) for Pods to pick up configmap and secret changes, so keep running `make test` until the runtime configmaps and secrets have been updated.
```
make demo-8
make demo-9
```
Outcome: Runtime config has changed, without having to restart the container. The updates may take longer then 1 min. So keep making http requests until the run time values change.
* ENV configmap is `3rd env config` and secret is `3rd env secret`. 
* Start time configmap is `3rd env config` and secret is `3rd env secret`.
* Run time configmap is `4th env config` and secret is `4th env secret`.

## Contributing

Please read [CONTRIBUTING.md](https://github.com/contino/kubernetes-101) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Taliesin Sisson** - *Initial work* - [taliesins](https://github.com/taliesins)

See also the list of [contributors](https://github.com/contino/kubernetes-101/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


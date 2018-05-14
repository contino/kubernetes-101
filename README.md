# Kubernetes 101

This project will demonstrate the basic features of Kubernetes.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

- Docker
- Kubernetes
- Node
- Make

### Installing

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

Demo 1 - Spin up a Kubernetes Pod with a deployment
```
make demo-1
```

Demo 2 - Make Kuberentes pod available via Kubernetes service
```
make demo-2
```

Demo 3 - Health check failing. Container gets recreated.
```
make demo-2
make demo-3
```

Demo 4 - Maximum memory exceeded. Container gets recreated.
```
make demo-2
make demo-4
```

Demo 5 - Deploy a faulty container & have no downtime
```
make demo-5
```

Demo 5 - Deploy a fixed container & have no downtime
```
make demo-6
```

Demo 7 - Override container ENV variables with explicit values
```
make demo-7
```

Demo 8 - Spin up the Pod overridding env variables pointing to configmap and secrets. Also configure configmap and secrets as volume mounts
```
make demo-8
```

Demo 9 - Change configmap and secret which shows runtime configuration.
```
make demo-8
make demo-9
```

## Contributing

Please read [CONTRIBUTING.md](https://github.com/contino/kubernetes-101) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

* **Taliesin Sisson** - *Initial work* - [taliesins](https://github.com/taliesins)

See also the list of [contributors](https://github.com/contino/kubernetes-101/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration
* etc


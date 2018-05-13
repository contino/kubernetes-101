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

Demo 1 - Spin up a Kubernetes Pod 
```
make demo-1
```

Demo 2 - Make container available via Kubernetes service
```
make demo-2
make test
```

Demo 3 - Override container ENV variables with explicit values
```
make demo-3
make test
```

Demo 4 - Override container ENV variables with configmap and secret values. Expose configmap and secrets via Kubernetes volume.
```
make demo-4
make test
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


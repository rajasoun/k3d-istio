# Getting Started

Deploy a local K3D Kubernetes development cluster that will use Istio as the service mesh.

## Pre Requisites 

1. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** is an easy-to-install application for your Mac, Linux, or Windows environment that enables you to build and share containerized applications and microservices.
1. **[k3s](https://k3s.io/)** is a efficient and lightweight fully compliant Kubernetes distribution.
1. **[k3d](https://k3d.io/)** is a utility designed to easily run k3s in Docker.It provides a simple CLI to create, run, delete a full compliance Kubernetes cluster with 0 to n worker nodes.
1. **[kubectl](https://kubernetes.io/docs/tasks/tools/)** is Kubernetes command-line tool and allows to run commands against Kubernetes clusters. It provides a simple CLI to to deploy applications, inspect and manage cluster resources, and view logs. 
1. **[helm](https://helm.sh/)** helps manage Kubernetes applications.Helm Charts helps to define, install, and upgrade even the most complex Kubernetes application.
1. **[k9s](https://k9scli.io/)**  is a terminal based UI to interact with your Kubernetes clusters. It helps to make it easier to navigate, observe and manage deployed applications


## Automation All in One Script 

Use below script to setup

```sh
scripts/all.sh setup
```

## Manual Steps for Learning 

## Pre Requisites 

Install k3d, istio, kubectl, helm. k9s
```sh
scripts/pre-requisites.sh setup
```

## k3d

Provision k3d cluster using [config/k3d-config.yaml](config/k3d-config.yaml)

```sh
k3d cluster create --config "config/k3d-config.yaml" 
source scripts/lib/tools.sh  
kubectl wait --for=condition=Ready pods --all -n kube-system
```

In Other Terminal 

```sh
k9s
```

## istio

Provision istio 

```sh
istioctl x precheck 
istioctl install --set profile=default -y 
kubectl label namespace default istio-injection=enabled
istioctl analyze -A
```


## Apps

Hello World
Refernce: 
1. https://github.com/istio/istio/tree/master/samples/helloworld
1. https://istio.io/latest/docs/tasks/traffic-management/ingress/gateway-api/

Provision App 

```sh
RESOURCES_PATH=apps
kubectl create namespace apps
kubectl apply  -f $RESOURCES_PATH/helloworld.yaml -n apps
```

There are two ways to expose Apps 

1. Expose App using Istio Gateway

```sh
RESOURCES_PATH=apps
kubectl delete -f $RESOURCES_PATH/helloworld-gateway-api.yaml -n apps
kubectl apply  -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
kubectl wait --for=condition=Ready pods --all -n apps 
```

OR 

2. Expose App using Kubernetes Gateway API

```sh
RESOURCES_PATH=apps
kubectl get crd gateways.gateway.networking.k8s.io || \
    { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl apply -f -; }
istioctl install --set profile=minimal -y
kubectl delete -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
kubectl apply  -f $RESOURCES_PATH/helloworld-gateway-api.yaml -n apps
kubectl wait --for=condition=Ready pods --all -n apps 
```

Test App

```sh
source scripts/lib/gateway.sh
curl http://$GATEWAY_URL/hello
```
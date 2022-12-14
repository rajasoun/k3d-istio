# Getting Started

Deploy a local K3D Kubernetes development cluster that will use Istio as the service mesh.

## Pre Requisites 

1. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** is an easy-to-install application for your Mac, Linux, or Windows environment that enables you to build and share containerized applications and microservices.
1. **[k3s](https://k3s.io/)** is a efficient and lightweight fully compliant Kubernetes distribution.
1. **[k3d](https://k3d.io/)** is a utility designed to easily run k3s in Docker.It provides a simple CLI to create, run, delete a full compliance Kubernetes cluster with 0 to n worker nodes.
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
scripts/k3d.sh setup
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
scripts/istio.sh setup
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
istioctl install --set profile=default -y
kubectl apply  -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
kubectl wait --for=condition=Ready pods --all -n apps 
```

OR 

2. Expose App using Kubernetes Gateway API

```sh
RESOURCES_PATH=apps
kubectl delete -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
istioctl install --set profile=minimal -y

kubectl get crd gateways.gateway.networking.k8s.io || \
    { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl apply -f -; }
    
kubectl apply  -f $RESOURCES_PATH/helloworld-gateway-api.yaml -n apps
kubectl wait --for=condition=Ready pods --all -n apps 
```

Test App

```sh
source scripts/lib/gateway.sh
curl http://$GATEWAY_URL/hello
```


## Monitoring 

```sh
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.15/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.15/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/jaeger.yaml
```

## tekton 

https://tekton.dev/ 

```sh
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl get pods --namespace tekton-pipelines --watch
```

### tektron dashboard 

```sh
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml
kubectl get pods --namespace tekton-pipelines --watch
kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097
```

## Decision Logs 

1. Istio service mesh included to replicate production setup
1. Initially /etc/hosts was used for mapping custom domain names to 127.0.0.1 in Host OS. Now it is replaced with https://local.gd/
1. Use tellerops teller fro AWS secrets Management in place of .env. Ref: https://github.com/tellerops/teller

### Under Evaluation 

1. Tektron fro CI/CD

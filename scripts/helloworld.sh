#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Reference: https://github.com/istio/istio/tree/master/samples/helloworld

export RESOURCES_PATH="apps"

function setup(){
    kubectl create namespace apps
    kubectl apply  -f $RESOURCES_PATH/helloworld.yaml -n apps
    kubectl apply  -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
    kubectl get pods -n apps
    kubectl wait --for=condition=Ready pods --all -n apps 
    source scripts/lib/gateway.sh
    curl http://$GATEWAY_URL/hello
}

function teardown(){
    kubectl delete -f $RESOURCES_PATH/helloworld.yaml
    kubectl delete -f $RESOURCES_PATH/helloworld-gateway.yaml
    kubectl delete namespace apps
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
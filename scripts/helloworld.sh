#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
# BASE_DIR="$(git rev-parse --show-toplevel)"
# Reference: https://github.com/istio/istio/tree/master/samples/helloworld

export RESOURCES_PATH="apps"
source "scripts/lib/tools.sh"

function setup(){
    gateway_type="$2"
    echo "Gateway Type : $gateway_type"
    kubectl create namespace apps
    kubectl label namespace apps istio-injection=enabled
    kubectl apply -f $RESOURCES_PATH/helloworld.yaml

    choice=$( tr '[:upper:]' '[:lower:]' <<<"$gateway_type" )
    case $choice in
        istio-gateway)
            kubectl delete -f $RESOURCES_PATH/helloworld-gateway-api.yaml -n apps
            istioctl install --set profile=default -y
            kubectl apply  -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
        ;;
        k8s-gateway)
            kubectl delete -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
            istioctl install --set profile=minimal -y
            kubectl apply  -f $RESOURCES_PATH/helloworld-gateway-api.yaml -n apps
        ;;
        *);;
    esac
    kubectl wait --for=condition=Ready pods --all -n apps 
    source scripts/lib/gateway.sh
    curl http://$GATEWAY_URL/hello
    echo -e "${GREEN}helloworld app with istio gateway Installation Sucessfull${NC}"
}

function teardown(){
    gateway_type="$2"
    echo "Gateway Type : $gateway_type"

    kubectl delete -f $RESOURCES_PATH/helloworld.yaml
    choice=$( tr '[:upper:]' '[:lower:]' <<<"$gateway_type" )
    case $choice in
        istio-gateway)
            kubectl delete  -f $RESOURCES_PATH/helloworld-gateway.yaml -n apps
        ;;
        k8s-gateway)
            kubectl delete  -f $RESOURCES_PATH/helloworld-gateway-api.yaml -n apps
        ;;
        *);;
    esac
    kubectl delete namespace apps
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
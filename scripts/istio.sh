#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

export CLUSTER_NAME=${CLUSTER_NAME:-"spike"}

# Reference: https://brettmostert.medium.com/k3d-kubernetes-istio-service-mesh-286a7ba3a64f

source "$SCRIPT_LIB_DIR/lib/tools.sh"

function setup(){
    istioctl x precheck 
    istioctl version
    choice=$( tr '[:upper:]' '[:lower:]' <<<"$gateway_type" )
    # istio configuration Profile - https://istio.io/latest/docs/setup/additional-setup/config-profiles/
    # Use the default configuration profile
     istioctl install --set profile=default -y
    # Add a namespace label to instruct Istio to automatically inject Envoy 
    # sidecar proxies when you deploy your application later
    kubectl label namespace default istio-injection=enabled
     # Ensure that there are no issues with the configuration
    istioctl analyze -A
    
    kubectl get crd gateways.gateway.networking.k8s.io || \
    { 
        kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl apply -f -; 
    }
    echo -e "${GREEN}istio Installation Sucessfull${NC}"
}

function teardown(){
    #kubectl delete -f $HOME/.istioctl/samples/addons
    istioctl uninstall -y --purge
    kubectl delete namespace istio-system
    kubectl label namespace default istio-injection-
    kubectl get crd gateways.gateway.networking.k8s.io && \
        {   
            kubectl delete gateways.gateway.networking.k8s.io gateway -n istio-ingress
            kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl delete -f -; 
        }
    echo -e "${GREEN}istio teardown Sucessfull${NC}"
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
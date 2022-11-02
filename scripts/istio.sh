#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

export CLUSTER_NAME=${CLUSTER_NAME:-"spike"}

# Reference: https://brettmostert.medium.com/k3d-kubernetes-istio-service-mesh-286a7ba3a64f

source "$SCRIPT_LIB_DIR/lib/tools.sh"

function setup(){
    gateway_type="$2"
    echo "Gateway Type : $gateway_type"
    istioctl x precheck 
    choice=$( tr '[:upper:]' '[:lower:]' <<<"$gateway_type" )
    # istio configuration Profile - https://istio.io/latest/docs/setup/additional-setup/config-profiles/
    # Use the minimal configuration profile
    istioctl install --set profile=minimal -y
    # Add a namespace label to instruct Istio to automatically inject Envoy 
    # sidecar proxies when you deploy your application later
    kubectl label namespace default istio-injection=enabled
     # Ensure that there are no issues with the configuration
    istioctl analyze -A
    
    case $choice in
        istio-gateway)
            # Use the default configuration profile
            istioctl install --set profile=default -y
            # Determine if your Kubernetes cluster is running in an environment that supports external load balancers:
            kubectl get svc istio-ingressgateway -n istio-system
        ;;
        k8s-gateway)
            # Install Gateway API CRDs 
            kubectl get crd gateways.gateway.networking.k8s.io || \
                { 
                    kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl apply -f -; 
                }
        ;;
        *);;
    esac
    echo -e "${GREEN}istio Installation Sucessfull${NC}"
}

function teardown(){
    #kubectl delete -f $HOME/.istioctl/samples/addons
    gateway_type="$2"
    echo "Gateway Type : $gateway_type"

    istioctl uninstall -y --purge
    istioctl uninstall -y --purge
    kubectl delete namespace istio-system
    kubectl label namespace default istio-injection-
    choice=$( tr '[:upper:]' '[:lower:]' <<<"$gateway_type" )
    case $choice in
        istio-gateway);;
        k8s-gateway)
            kubectl get crd gateways.gateway.networking.k8s.io && \
                {   kubectl delete httproute http;
                    kubectl delete gateways.gateway.networking.k8s.io gateway -n istio-ingress
                    kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.5.0" | kubectl delete -f -; 
                }
        ;;
        *);;
    esac
    echo -e "${GREEN}istio teardown Sucessfull${NC}"
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
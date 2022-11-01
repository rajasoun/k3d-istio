#!/usr/bin/env bash

source <(kubectl completion zsh)
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

echo "INGRESS_HOST=$INGRESS_HOST"
echo "INGRESS_PORT=$INGRESS_PORT"
echo "SECURE_INGRESS_PORT=$SECURE_INGRESS_PORT"
echo "TCP_INGRESS_PORT=$TCP_INGRESS_PORT"


# Docker Desktop 
export INGRESS_HOST=k3d.local # mapping in /etc/hosts to 127.0.0.1
export GATEWAY_URL=$INGRESS_HOST
echo -e "\nGATEWAY_URL : $GATEWAY_URL"
#!/usr/bin/env bash

source <(kubectl completion zsh)

# Docker Desktop 
export INGRESS_HOST=k3d.local # mapping in /etc/hosts to 127.0.0.1
export GATEWAY_URL=$INGRESS_HOST
echo -e "\nGATEWAY_URL : $GATEWAY_URL"
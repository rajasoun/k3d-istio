#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

export CLUSTER_NAME=${CLUSTER_NAME:-"spike"}

function setup(){
    # try k3d cluster create $CLUSTER_NAME --k3s-arg="--disable=traefik@server:*"
    cat config/k3d-config.yaml | envsubst > /tmp/k3d-config.yaml
    try k3d cluster create --config  /tmp/k3d-config.yaml
    export KUBECONFIG=$(k3d kubeconfig write $CLUSTER_NAME)
    echo "export KUBECONFIG=${KUBECONFIG}"
    rm /tmp/k3d-config.yaml

    add_host_entry "127.0.0.1" "k3d.local"
    try source ${SCRIPT_LIB_DIR}/tools.sh
    
    # wait untill all pods are in Ready State
    try kubectl wait --for=condition=Ready pods --all -n kube-system
    # List Running Containers
    docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Ports}}'
    echo -e "${GREEN}k3d Installation Sucessfull${NC}"
}

function teardown(){
    try k3d cluster delete $CLUSTER_NAME
    remove_host_entry "k3d.local"
    #try k3d cluster delete -a
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
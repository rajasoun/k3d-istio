#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

export CLUSTER_NAME=${CLUSTER_NAME:-"spike"}

function setup(){
    try brew install k3d k9s 

    try wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

    # try k3d cluster create $CLUSTER_NAME --k3s-arg="--disable=traefik@server:*"
    try k3d cluster create --config "config/k3d-config.yaml"
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
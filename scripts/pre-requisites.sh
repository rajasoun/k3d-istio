#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

export CLUSTER_NAME=${CLUSTER_NAME:-"spike"}

function check_for_docker_desktop(){
    if [[ -n "$(docker info --format '{{.OperatingSystem}}' | grep 'Docker Desktop')" ]]; then
        echo -e "${GREEN}\nDocker Desktop found....${NC}"
    else
        echo -e "${RED}\nWARNING! Docker Desktop not installed:${NC}"
        echo -e "${YELLOW}  * Install docker desktop from <https://docs.docker.com/docker-for-mac/install/>\n${NC}"
        exit 1
    fi

}

function setup(){
    check_for_docker_desktop
    try brew install k3d k9s helm kubectl
    echo -e "${GREEN}Pre Requisites Installation Sucessfull${NC}"
}

function teardown(){
    try brew uninstall k3d k9s helm kubectl
    brew cleanup
    echo -e "${GREEN}Pre Requisites Teardown Installation Sucessfull${NC}"
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
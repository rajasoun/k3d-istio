#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

export CLUSTER_NAME=${CLUSTER_NAME:-"spike"}

function install_apps(){
    pretty_print "Installing Package(s)..."
    PACKAGES=$(cat ${SCRIPT_LIB_DIR}/packages/brew.txt)
    brew install ${PACKAGES[@]}
}

function uninstall_apps(){
    pretty_print "UnInstalling Package(s)..."
    PACKAGES=$(cat ${SCRIPT_LIB_DIR}/packages/brew.txt)
    brew uninstall ${PACKAGES[@]}
}

function setup(){
    is_mac
    check_for_docker_desktop
    try install_apps
    # try wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    curl -sL https://istio.io/downloadIstioctl | sh -
    source "${SCRIPT_LIB_DIR}/lib/tools.sh"
    echo -e "${GREEN}Pre Requisites Installation Sucessfull${NC}"
}

function teardown(){
    rm -fr $HOME/.istioctl
    try uninstall_apps
    brew cleanup
    echo -e "${GREEN}Pre Requisites Teardown Installation Sucessfull${NC}"
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
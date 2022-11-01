#!/usr/bin/env bash

set -eo pipefail
IFS=$'\n\t'

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

function setup(){
    start=$(date +%s)
    scripts/pre-requisites.sh setup
    scripts/k3d.sh setup 
    scripts/istio.sh setup
    scripts/helloworld.sh setup
    end=$(date +%s)
    runtime=$((end-start))
    echo -e "${GREEN}Setup Successful | $(display_time $runtime) ${NC}" 
}

function teardown(){
    start=$(date +%s)
    scripts/helloworld.sh teardown
    scripts/istio.sh teardown
    scripts/k3d.sh teardown 
    scripts/pre-requisites.sh teardown
    end=$(date +%s)
    runtime=$((end-start))
    echo -e "${GREEN}Teardown Successful | $(display_time $runtime) ${NC}" 
}

source "${SCRIPT_LIB_DIR}/lib/main.sh" $@
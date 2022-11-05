#!/usr/bin/env bash

# SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"

NC=$'\e[0m' # No Color
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'
YELLOW='\033[1;33m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

# Path to your hosts file
hostsFile="/etc/hosts"

# Exception Handling
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# Add host entry to /etc/hosts
function add_host_entry() {
    ip=$1
    hostname=$2
    if [ -n "$(grep  "[[:space:]]$hostname" /etc/hosts)" ]; then
        yell "$hostname, already exists: $(grep $hostname $hostsFile)";
    else
        echo "Adding $hostname to $hostsFile...";
        try printf "%s\t%s\n" "$ip" "$hostname" | sudo tee -a "$hostsFile" > /dev/null;

        if [ -n "$(grep $hostname /etc/hosts)" ]; then
            echo "$hostname was added succesfully:";
            #echo "$(grep $hostname /etc/hosts)";
        else
            die "Failed to add $hostname";
        fi
    fi
}

# Remove host entry to /etc/hosts
function remove_host_entry() {
    hostname=$1
    # shellcheck disable=SC2143
    if [ -n "$(grep  "[[:space:]]$hostname" /etc/hosts)" ]; then
        echo "$hostname found in $hostsFile. Removing now...";
        try sudo sed -ie "/[[:space:]]$hostname/d" "$hostsFile";
    else
        yell "$hostname was not found in $hostsFile";
    fi
}

# Displays Time in mins and seconds
function display_time {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( D > 0 )) && printf '%d days ' $D
    (( H > 0 )) && printf '%d hours ' $H
    (( M > 0 )) && printf '%d minutes ' $M
    (( D > 0 || H > 0 || M > 0 )) && printf 'and '
    printf '%d seconds\n' $S
}

# Get IP Address of Mac
function get_ip_mac(){
    ip=$(ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2)
    echo "$ip"
}

# Get IP Address of Linux
function get_ip_linux(){
    ip=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
    echo "$ip"
}

# Pretty Print
function pretty_print() {
  printf "\n%b\n" "$1"
}

# Check if Mac
function is_mac(){
    if [[ $OSTYPE == "darwin"* ]]; then
        echo -e "Darwin OS Detected"
    else
        echo -e "Darwin OS is required to Run brew"
        exit 1
    fi
}

# Check if Docker Desktop is Running
function check_for_docker_desktop(){
    if [[ -n "$(docker info --format '{{.OperatingSystem}}' | grep 'Docker Desktop')" ]]; then
        echo -e "${GREEN}\nDocker Desktop found....${NC}"
    else
        echo -e "${RED}\nWARNING! Docker Desktop not installed:${NC}"
        echo -e "${YELLOW}  * Install docker desktop from <https://docs.docker.com/docker-for-mac/install/>\n${NC}"
        exit 1
    fi

}
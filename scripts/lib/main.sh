#!/usr/bin/env bash

SCRIPT_LIB_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "${SCRIPT_LIB_DIR}/os.sh"

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )
case $choice in
    setup)setup;;
    teardown)teardown;;
    *)
    echo "${RED}Usage: $0 < setup | teardown >${NC}"
cat <<-EOF
Commands:
---------
setup         -> Setup  
teardown      -> Teardown 
EOF
    ;;
esac

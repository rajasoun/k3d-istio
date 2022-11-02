#!/usr/bin/env bash

source <(kubectl completion zsh)
source <(helm completion zsh)
source <(k3d completion zsh)

export TERM=xterm-256color
export K9S_EDITOR=code 
export PATH=$HOME/.istioctl/bin:$PATH 

source <(istioctl completion zsh)

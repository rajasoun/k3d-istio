#!/usr/bin/env bash

export TERM=xterm-256color
export K9S_EDITOR=code 

PACKAGES="$(cat scripts/lib/packages/brew.txt | sed 's/#.*$//' | grep -v 'fetch\|tektoncd-cli\|kubectx')"
for pkg in  ${PACKAGES[@]}; do 
    echo -e "${GREEN}Applying zsh completion for $pkg${NC}" 
    source <($pkg completion zsh)
done 

source <(tkn completion zsh)
echo -e "${GREEN}Applying zsh completion for tkn${NC}" 

export PATH=$HOME/.istioctl/bin:$PATH 
if [ ! "$(command -v istioctl >/dev/null)" ];then 
    source <(istioctl completion zsh)
    echo -e "${GREEN}Applying zsh completion for istioctl${NC}" 
fi 


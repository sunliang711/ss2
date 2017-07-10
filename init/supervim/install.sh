#!/bin/bash
source functions.sh

if (($# < 1));then
    usage
fi

action=${1}
vim=${2}
proxy=${3}

echo "proxy: $proxy"
proxyOn "$proxy"

case $action in
    update)
        updateCfg $vim
        ;;
    install)
        install $vim "$proxy"
        ;;
    installYcm)
        installYcm $vim
        ;;
    uninstall)
        uninstall $vim
        ;;
    installFont)
        installFont
        ;;
    installVimGo)
        installVimGo
        ;;
    *)
        usage
        ;;
esac

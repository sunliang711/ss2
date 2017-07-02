#!/bin/bash
source functions.sh

if (($# < 1));then
    usage
fi

action=${1}
vim=${2}

proxyOn

case $action in
    update)
        updateCfg $vim
        ;;
    install)
        install $vim
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

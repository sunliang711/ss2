#!/bin/bash

USAGE="usage: $(basename $0) {install|uninstall|reinstall}"

if (($# == 0));then
    echo "$USAGE" >& 2
    exit 0
fi
destPath=""
OS=""
case $(uname) in
    "Darwin")
        OS="darwin"
        ;;
    "Linux")
        OS="linux"
        ;;
    *)
        echo "Unknown os,Quit!"
        exit 1;;
esac


startLine="##CUSTOM BEGIN"
endLine="##CUSTOM END"

install(){
    shell=${1:?"missing shell type"}
    case "$shell" in
        bash)
            if [[ "$OS" == linux ]];then
                cfgFile=$HOME/.bashrc
            else
                #mac os
                cfgFile=$HOME/.bash_profile
            fi
            ;;
        zsh)
            cfgFile=$HOME/.zshrc
            ;;
        *)
            echo -e "Only support bash or zsh! ${RED}\u2717${RESET}"
            exit 1
            ;;
    esac
    #install custom config
    #the actual config is in file ~/.bashrc(for linux) or ~/.bash_profile(for mac)

    #grep for $startLine quietly
    if grep  -q "$startLine" $cfgFile;then
        echo "Already installed,Quit!"
        exit 1
    else
        echo "Install setting of $shell..."
        rc=/etc/shellrc
        if [ ! -e $rc ];then
            echo "cp shellrc to $rc,need root privilege."
            sudo cp shellrc  $rc
        fi
        #insert header
        echo "$startLine" >> $cfgFile

        #insert body
        echo "[ -f $rc ] && source $rc" >> $cfgFile

        #insert tailer
        echo "$endLine" >> $cfgFile
        echo "Done."
    fi
}

uninstall(){
    shell=${1:?"missing shell type"}
    case "$shell" in
        bash)
            if [[ "$OS" == linux ]];then
                cfgFile=$HOME/.bashrc
            else
                #mac os
                cfgFile=$HOME/.bash_profile
            fi
            ;;
        zsh)
            cfgFile=$HOME/.zshrc
            ;;
        *)
            echo -e "Only support bash or zsh! ${RED}\u2717${RESET}"
            exit 1
            ;;
    esac
    echo "Uninstall setting of $shell..."
    #uninstall custom config
    #delete lines from header to tailer
    sed -ibak "/$startLine/,/$endLine/ d" $cfgFile
    rm ${cfgFile}bak
    if [ -e /etc/shellrc ];then
        echo "remove /etc/shellrc,need root privilege."
        sudo rm /etc/shellrc
    fi
    echo "Done."
}

reinstall(){
    uninstall bash
    uninstall zsh
    install bash
    install zsh
}

case "$1" in
    install | ins*)
        install bash
        install zsh
        exit 0
        ;;
    uninstall | unins*)
        uninstall bash
        uninstall zsh
        exit 0
        ;;
    reinstall | reins*)
        reinstall
        exit 0
        ;;
    --help | -h | --h* | *)
        echo "$USAGE" >& 2
        exit 0
        ;;
esac
#vim setf sh

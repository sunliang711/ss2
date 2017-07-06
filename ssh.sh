#!/bin/bash
sshCopy(){
    if (($#<1));then
        echo "Usage: $(basename $0) [-p port-value] remoteUser@remoteHost"
        return 1
    fi

    while getopts "p:" arg
    do
        case $arg in
            p)
                remotePort=$OPTARG
                ;;
        esac
    done
    shift $(($OPTIND-1))
    if [ -n "$remotePort" ];then
        echo "remotePort:$remotePort"
    fi
    userAtHost=$1

    comment="$(whoami)@$(hostname)  Generated on $(date +%FT%H:%M:%S)"
    if [ ! -e ~/.ssh/id_rsa ];then
        ssh-keygen -t rsa -b 4096 -C "$comment" -N "" -f ~/.ssh/id_rsa
    fi

    if [ -n "$remotePort" ];then
        ssh-copy-id -p $remotePort "$userAtHost"
    else
        ssh-copy-id "$userAtHost"
    fi
}

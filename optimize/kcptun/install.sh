#!/bin/bash
if (($EUID!=0));then
    echo "Need root priviledge!"
    exit 1
fi

ROOT=/kcptun
if [ -d "$ROOT" ];then
    $ROOT/kcptun stop
    rm -rf "$ROOT"
fi
mkdir -pv "$ROOT"

fullpath="$PWD/$0"
#本文件所在位置
realpath=$(dirname "$fullpath")
cd $realpath

cp core/server_linux_amd64 "$ROOT"
cp core/config.json "$ROOT"
cp kcptun "$ROOT"

if ! grep -q "kcptun start" /etc/rc.local;then
    sed -i "/^exit 0/i$ROOT/kcptun start" /etc/rc.local
fi

#add alias for kcptun
if ! grep -q "alias kcptun" ~/.bashrc;then
    echo "alias kcptun=\"$ROOT/kcptun\"" >> ~/.bashrc
fi

#start server
"$ROOT/kcptun" start

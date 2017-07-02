#!/bin/bash

if (($EUID!=0));then
    echo "need root privilege!"
    exit 1
fi
apt update -y
apt install -y libev-dev libudns-dev
#stop service if exists
systemctl stop ss-libev >/dev/null 2>&1

root=/opt/ss-libev
if [ -d "$root" ];then
    rm -rf "$root" >/dev/null 2>&1
fi
mkdir -p "$root"

#config file
cp ./on001.json "$root"
#apt install -y rng-tools

#cp ss-server
bindir=/usr/local/bin
mkdir -p "$bindir" >/dev/null 2>&1
cp ./ss-server "$bindir"
cp ./manager.sh "$bindir"
cp ./checkTraffic.sh "$bindir"
cp ./clearTraffic.sh "$bindir"
#delete job
crontab -l 2>/dev/null|grep -v checkTraffic.sh|crontab -
crontab -l 2>/dev/null|grep -v clearTraffic.sh|crontab -
#add job
 (crontab -l 2>/dev/null;echo "*/10 * * * * /usr/local/bin/checkTraffic.sh")|crontab -
 (crontab -l 2>/dev/null;echo "0 0 1 * * /usr/local/bin/clearTraffic.sh")|crontab -
#environment file
cp ./ss-libev.environment /etc/default

#service file
cp ./ss-libev.service /lib/systemd/system
cp ./ss-multi-port.sh "$root"

#shared library
cp ./lib/libmbedcrypto.so* /usr/local/lib
cp ./lib/libsodium.so* /usr/local/lib

ldconfig
systemctl daemon-reload
systemctl restart ss-libev
systemctl enable ss-libev



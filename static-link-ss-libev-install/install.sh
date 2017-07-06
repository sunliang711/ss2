#!/bin/bash
root=/opt/sslibev
db=$root/db
#TODO serviceFileDir may be difference on many OSes
serviceFileDir=/lib/systemd/system

check(){
    if ! command -v sqlite3 >/dev/null 2>&1;then
        echo "Error: need sqlite3 support!"
        exit 1
    fi
}
installss(){
    systemctl stop sslibev >/dev/null 2>&1
    rm -rf $root >/dev/null 2>&1
    mkdir -p $root >/dev/null 2>&1

    if ! command -v sqlite3 >/dev/null 2>&1;then
        echo "try to install sqlite3..."
        apt update >/dev/null 2>&1
        apt install -y sqlte3 || { echo "you mast install sqlite3 yourself."; }
    fi
    #create db
    sqlite3 "$db" "create table config(port int primary key,password text,method text,owner text,trafficLimit text,udpRelay int,fastOpen int,enabled int);" || { echo "create table config failed!"; exit 1; }

    #iptables.service plugin
    cp ./sslibev.sh /opt/iptables/plugin/ || { echo "You didn't install iptables service,install sslibev.sh plugin failed!"; }

    sed "s|ROOT|$root|" ./sslibev.service > "$serviceFileDir/sslibev.service"
    sed "s|ROOT|$root|" ./start.sh > "$root/start.sh"
    sed "s|ROOT|$root|" ./ssserver.sh > /usr/local/bin/ssserver.sh

    chmod +x "$root/start.sh"
    chmod +x /usr/local/bin/ssserver.sh

    tar xf ./ss-libev-binaries-static-link.tar.bzip2
    cp ./ss-libev-binaries-static-link/ss-server $root
    chmod +x "$root/ss-server"
    rm -rf ss-libev-binaries-static-link
    systemctl daemon-reload
}

check
installss

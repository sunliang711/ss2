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
    rm -rf $root >/dev/null 2>&1
    mkdir -p $root >/dev/null 2>&1

    #create db
    sqlite3 "$db" "create table config(port int primary key,password text,method text,udpRelay int,fastOpen int,enabled int);" || { echo "create table config failed!"; exit 1; }

    sed "s|ROOT|$root|" ./sslibev.service > "$serviceFileDir"
    sed "s|ROOT|$root|" ./start.sh > "$root/start.sh"
    sed "s|ROOT|$root|" ./ssserver.sh > /usr/local/bin/ssserver.sh

    chmod +x "$root/start.sh"
    chmod +x /usr/local/bin/ssserver.sh

    tar xf ./ss-libev-binaries-static-link.tar.bzip2 
    cd ss-libev-binaries-static-link
    cp ss-server $root 
    chmod +x "$root/ss-server" 
    rm -rf ss-libev-binaries-static-link
    cd -
}

check
installss

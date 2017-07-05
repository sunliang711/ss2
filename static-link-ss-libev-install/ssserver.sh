#!/bin/bash
#本脚本用来执行账户管理操作
#也就是修改sqlite3数据库的操作
db=ROOT/db
# sqlite3 "$db" "create table config(port int primary key,password text,method text,udpRelay int,fastOpen int,enabled int);" || { echo "create table config failed!"; exit 1; }
list(){
    echo -e ".header on\n.mode column\nselect * from config;" | sqlite3 "$db"
}
add(){
    if (( $#<3 ));then
        echo "usage: add port password method [udp-relay:1 or 0]"
        exit 1
    fi
    port=$1
    password=$2
    method=$3
    udpRelay=${4:-1}
    sqlite3 "$db" "insert into config(port,password,method,udpRelay,fastOpen,enabled) values($port,\"$password\",\"$method\",$udpRelay,1,1);" || { echo "add failed!"; exit 1; }
}

del(){
    if (($#<1));then
        echo "Usage: del port"
        exit 1
    fi
    port=$1
    sqlite3 "$db" "delete from config where port=$port;" || { echo "del failed!"; exit 1; }
}

enable(){
    if (($#<1));then
        echo "Usage: del port"
        exit 1
    fi
    port=$1
    sqlite3 "$db" "update config set enabled=1 where port=$port;" || { echo "enable port:$port failed!"; exit 1; }
}

disable(){
    if (($#<1));then
        echo "Usage: del port"
        exit 1
    fi
    port=$1
    sqlite3 "$db" "update config set enabled=0 where port=$port;" || { echo "enable port:$port failed!"; exit 1; }
}

update(){
    if (($#<3));then
        echo "Usage: update port new-password new-method [new-udpRelay new-fastOpen new-enabled]"
        exit 1
    fi
    port=$1
    password=$2
    method=$3
    #get old value of udpRelay fastOpen enabled
    old=$(sqlite3 "$db" "select udpRelay,fastOpen,enabled from config where port=$port;") || { echo "query port:$port failed!"; exit 1; }
    if [ -z "$old" ];then
        echo "Cannot find port $port config!"
        exit 1
    fi
    oldUdpRelay=$(echo "$old" | awk -F'|' '{print $1}')
    oldFastOpen=$(echo "$old" | awk -F'|' '{print $2}')
    oldEnabled=$(echo "$old" | awk -F'|' '{print $3}')
    udpRelay=${4:-$oldUdpRelay}
    fastOpen=${5:-$oldFastOpen}
    enabled=${6:-$oldEnabled}

    sqlite3 "$db" "update config set password=\"$password\",method=\"$method\",udpRelay=$udpRelay,fastOpen=$fastOpen,enabled=$enabled where port=$port;" || { echo "update port:$port failed!"; exit 1; }

}

usage(){
    echo "Usage: $(basename $0) CMD"
    echo
    echo "CMD:"
    echo -e "\t\tlist"
    echo -e "\t\tadd port password method [udpRelay: 0 or 1]"
    echo -e "\t\tdel port"
    echo -e "\t\tenable port"
    echo -e "\t\tdisable port"
    echo -e "\t\tupdate port password method [udpRelay] [fastOpen] [enabled]"
}
case $1 in
    list)
        list
        ;;
    add)
        add $2 $3 $4 $5
        ;;
    del)
        del $2
        ;;
    enable)
        enable $2
        ;;
    disable)
        disable $2
        ;;
    update)
        update $2 $3 $4 $5 $6 $7
        ;;
    *)
        usage
        ;;
esac

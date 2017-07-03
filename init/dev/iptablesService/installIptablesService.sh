#!/bin/bash

#TODO 根据不同的系统，serviceFileDir的位置不同，这里的是debian8的位置
serviceFileDir=/lib/systemd/system

setIptables(){
    if ! ls start-iptables >/dev/null 2>&1;then
        echo "没找到相关文件"
        echo "先cd到本脚本所在位置再执行!"
        exit 1
    fi
    #加入需要重装的话，当前的服务要先关掉
    systemctl stop iptables.service >/dev/null 2>&1

    root=/opt/iptables
    customRulesDir=$root/custom.rules.d
    stopScript=$root/stop-iptables
    startScript=$root/start-iptables

    rm -rf $root >/dev/null 2>&1
    mkdir -p $customRulesDir

    cp ./start-iptables $root
    cp ./stop-iptables $root
    cp ./header.rules $root
    cp ./tail.rules $root
    cp ./ss-libev-rules $customRulesDir

    #readonly
    chmod 400 "$root"/header.rules
    chmod 400 "$root"/tail.rules

    chmod +x "$startScript"
    chmod +x "$stopScript"

    sed -e "s+STARTSCRIPT+$startScript+" -e "s+STOPSCRIPT+$stopScript+" iptables.service > "$serviceFileDir/iptables.service"
    systemctl daemon-reload
    systemctl start iptables.service
    systemctl enable iptables.service
}
setIptables

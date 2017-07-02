#!/bin/bash
pid=`ps aux |grep -v grep |grep server_linux_amd64 | awk '{print $2}'`
if [ -n $pid ];then
    echo "kcptun server is running with pid: $pid"
else
    echo "kcptun server is not running"
fi

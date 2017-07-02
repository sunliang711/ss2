#!/bin/bash
pid=`ps aux |grep -v grep |grep server_linux_amd64 | awk '{print $2}'`

if [ ! -z "$pid" ];then
    kill $pid
    echo "kill process with pid: $pid"
else
    echo 'kcp server is not running!'
    echo 'Exit.'
fi

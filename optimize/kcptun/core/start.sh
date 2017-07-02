#!/bin/bash
# ./server_linux_amd64 -l :1240 -t 127.0.0.1:124 -key test -mtu 1400 -sndwnd 2048 -rcvwnd 256 -mode fast2 >kcptun.log 2>&1 &
if ps aux | grep -v grep | grep -q server_linux_amd64;then
	echo "kcptun server is already running."
	echo "exit"
	exit 1
fi

fullpath="$(pwd)/$0"
cd $(dirname $fullpath)
./server_linux_amd64 -c config.json >/dev/null 2>&1 &
if ps aux | grep -v grep | grep -q server_linux_amd64;then
	echo "kcptun server started."
else
	echo "kcptun server start failed!!"
fi

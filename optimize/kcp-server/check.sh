#!/bin/bash
#add the fowller line to crontab -e
#*/5 * * * * /root/kcp-server/check.sh
if ps aux | grep -v grep | grep kcp-server;then
	echo "$(date +%Y%m%d/%H:%M:%S) kcp-server is running" >> /root/kcp-server/check.log
else
	/etc/init.d/kcp-server start
	echo "$(date +%Y%m%d/%H:%M:%S) start kcp-server " >> /root/kcp-server/check.log
fi

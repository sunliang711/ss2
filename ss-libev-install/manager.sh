#!/bin/bash
#本脚本用于管理ss-libev端口配置，包括新增端口，修改端口，删除端口，查看所有端口
root=/opt/ss-libev
#TODO 新增或更新完一个端口时，要检查冲突

list(){
	allCfgFiles=$(ls ${root}/*.json)
    msgfile=/tmp/manager-list-output
    echo "Pager program is less." >$msgfile
	for cfg in ${allCfgFiles};do
		port=$(grep 'server_port' $cfg | grep -oP ':.+' | grep -oP '\d+')
		#port=$(grep 'server_port' $cfg | grep -oP ':\s*\d+\s*,' | grep -oP '\d+')
		password=$(grep 'password' $cfg | grep -oP ':.+' | grep -oP '(?<=")[^"]+(?=")')
		method=$(grep 'method' $cfg | grep -oP ':.+' | grep -oP '(?<=")[^"]+(?=")')
		owner=$(grep 'owner' $cfg | grep -oP ':.+' | grep -oP '(?<=")[^"]+(?=")')
		trafficLimit=$(grep 'traffic_limit' $cfg | grep -oP ':.+' | grep -oP '(?<=")[^"]+(?=")')
        echo "*****************************************************************************" >>$msgfile
		echo "cfg file is:$cfg" >> $msgfile
		echo "**port:$port password:$password method:$method owner:$owner trafficLimit:$trafficLimit" >> $msgfile
	done
    export LESSCHARSET=utf-8
    less $msgfile
}

add(){
    usage='usage: add port password owner(default:nobody) method(default:chacha20) traffic_limit(default:100)'
	port=$1
	password=$2
	owner=${3:-nobody}
	method=${4:-chacha20}
    trafficLimit=${5:-100}
	if [ -z "$port" ] || [ -z "$password" ];then
		echo "$usage"
		exit 1 
	fi
	cfgfile="on$(date +%s).json"
	cat > $root/$cfgfile<<EOF
{
	"server":"0.0.0.0",
	"server_port":$port,
	"password":"$password",
	"method":"$method",
	"local_port":1080,
	"owner":"$owner",
    "traffic_limit":"$trafficLimit",
	"timeout":60
}
EOF
    restart
}

delete(){
	usage="delete port"
	port=$1
	if [ -z "$port" ];then
		echo $usage
		exit 1
	fi
	
	allCfgFiles=$(ls ${root}/*.json)
	for cfg in ${allCfgFiles};do
		p=$(grep 'server_port' $cfg | grep -oP ':\s*\d+\s*,' | grep -oP '\d+')
		if [ "$p" == "$port" ];then
			rm $cfg
            restart
            return 0
		fi
	done
	echo "Not Found port:$port config file"
}


update(){
	usage="usage: update port"
	port=$1
	if [ -z "$port" ];then
		echo $usage
		exit 1
	fi
	
	allCfgFiles=$(ls ${root}/*.json)
	echo "allCfgFiles:$allCfgFiles"
	for cfg in ${allCfgFiles};do
		p=$(grep 'server_port' $cfg | grep -oP ':\s*\d+\s*,' | grep -oP '\d+')
		if [ "$p" == "$port" ];then
			vi $cfg
            return 0
		fi
	done
	echo "Not Found port:$port config file"

}

enable(){
	usage="usage: enable port"
	port=$1
	if [ -z "$port" ];then
		echo $usage
		exit 1
	fi
	
	allCfgFiles=$(ls ${root}/off*.json 2>/dev/null)
	for cfg in ${allCfgFiles};do
		p=$(grep 'server_port' $cfg | grep -oP ':\s*\d+\s*,' | grep -oP '\d+')
		if [ "$p" == "$port" ];then
            mv $cfg ${cfg/off/on}
            restart
            return 0
		fi
	done
	echo "Not Found port:$port config file"
}

disable(){
	usage="usage: disable port"
	port=$1
	if [ -z "$port" ];then
		echo $usage
		exit 1
	fi
	
	allCfgFiles=$(ls ${root}/on*.json 2>/dev/null)
	echo "allCfgFiles:$allCfgFiles"
	for cfg in ${allCfgFiles};do
		p=$(grep 'server_port' $cfg | grep -oP ':\s*\d+\s*,' | grep -oP '\d+')
		if [ "$p" == "$port" ];then
            mv $cfg ${cfg/on/off}
            restart
            return 0
		fi
	done
	echo "Not Found port:$port config file"
}

usage(){
	echo "usage: $(basename $0) CMD [Parameters]"
	echo "CMD:"
	echo "     list"
    echo "     add port password owner(default:nobody) method(default chacha20)"
	echo "     delete port"
	echo "     update port"
    echo "     enable port"
    echo "     disable port"
}

warning(){
	echo "Warning: Don't forget to update iptables and restart ss-libev service"
}

restart(){
    systemctl restart iptables
    systemctl restart ss-libev
}

case $1 in
	list)
		list
		;;
	add)
		add $2 $3 $4 $5
		warning
		;;
	delete)
		delete $2
		warning
		;;
	update)
		update $2
		warning
		;;
    enable)
        enable $2
        ;;
    disable)
        disable $2
        ;;
	*)
		usage
		;;
esac


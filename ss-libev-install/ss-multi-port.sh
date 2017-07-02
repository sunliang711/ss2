#!/bin/bash

if [ $# != 3 ];then
    echo "Usage: `basename $0` user daemon_opt"
    exit 1
fi

user_as=$1
daemon_opt=$2

pid_file_dir=/var/run/ss-libev
[ -d $pid_file_dir ] || mkdir $pid_file_dir
root=/opt/ss-libev

echo "start multi_port service:"

#all file begin with on and end with .json can be used as a config file of an instance
allCfgFiles=$(ls $root/on*.json)
index=0
for cfg in $allCfgFiles;do
    /usr/local/bin/ss-server -a $user_as -c $cfg -f ${pid_file_dir}/ss_${index}.pid $daemon_opt
    ((index+=1))
done

exit 0

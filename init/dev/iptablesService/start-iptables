#!/bin/bash
root=/opt/iptables
customRulesDir=$root/custom.rules.d

header=$root/header.rules
tail=$root/tail.rules
all=$root/all.rules

cat $header >$all
for i in $(ls $customRulesDir/*);do
    echo $i
    #可执行的脚本或程序则执行输出到$all
    if file $i | grep -q 'executable';then
        bash $i >>$all
    else
    #不可执行的文件则直接文件袁内容输出到$all
        cat $i >>$all
    fi
done
cat $tail >>$all

/sbin/iptables-restore $all

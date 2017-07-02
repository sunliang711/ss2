#!/bin/bash
root=/opt/traffic
#对于每个tcpxxxx文件，把它里面的内容写到tcpxxxx.total中，并注明上个月月份
#因为这个文件是在每个月1号0点执行的，统计的是上个月的数据
shopt -s extglob
allTrafficFiles=$(ls "$root"/tcp+([0-9]))

#取得上个月字符串形式，年/月的形式
thisYear=$(date +%Y)
thisMonth=$(date +%m)
if (($thisMonth==1));then
    ((y=$thisYear-1))
    lastMonth="${y}/12"
else
    ((m=$thisMonth-1))
    lastMonth="${thisYear}/$m"
fi

for f in $allTrafficFiles;do
    totalf="$f.total"
    echo -n "$lastMonth: " >> $totalf
    cat $f >> $totalf
    rm $f
done

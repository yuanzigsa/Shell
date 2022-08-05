#!/bin/sh
process=`ps -elf |grep 'node server'|grep -v grep |head -n 1 |awk '{printf $4}'`
#echo $process
if [ "$process" == "" ]; then
echo "iperf3服务端进程不存在，正在重启..."
iperf3 -s &
else
echo "iperf3服务端进程已存在，无需操作！"
fi;




#!/bin/bash
################################################################
#       Mem Used Script
#       eg. ./mem.sh 10G & to start testing
#       eg. ./mem.sh stop  to stop testing and clear env
#       update: 2020-04-21  Nobita
################################################################
num=$1
user=`whoami`
 
start()
{
if [ -d /tmp/memory ];then
        echo "the dir "/tmp/memory" is already exist!, use it." >> mem.log
else
        sudo mkdir /tmp/memory
        mount -t tmpfs -o size=$num tmpfs /tmp/memory
fi
dd if=/dev/zero of=/tmp/memory/block >> mem.log 2>&1
}
 
stop()
{
 
rm -rf /tmp/memory/block
umount /tmp/memory
rmdir /tmp/memory
if [ -d /tmp/memory ];then
        echo "Do not remove the dir \"/tmp/memory\", please check "
else
        echo "clear env is done!"
fi
}
main()
{
if [ $num == 'stop' ];then
        stop
elif [ $user != "root" ];then
        echo "please use the \"root\" excute script!"
        exit 1
else
        start
fi
}
 
if [ $# = 2 -o $# = 1 ];then
        main
else
        echo 'Usage: <./mem.sh 10G &> to start  or <./mem.sh stop>  to clear env'
fi

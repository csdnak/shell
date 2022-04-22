#!/bin/bash
#===========================================================================
#           FileName: cutlog.sh
#
#           Author  : WangXinKun
#
#           Created : 15:53,22/04/2022
#===========================================================================
# Delete the backup data to >=3 days before
# find $basepath -mtime +3 -name "*.sql.gz" -exec rm -rf {} \;
# find $basepath -mtime +3 -name "*.sql.gz" -exec rm -rf {} \; -or -mtime +3 -name "*-error.log" -exec rm -rf {} \;
# Backup file is saved in the directory, if it does not exist Create
date=$(date +%F -d -1day)
basepath=`pwd`

# 判断目录
if [ ! -d bak ] ; then
        mkdir -p bak
fi

# 备份日志
mv access.log bak/access_$date.log 
mv error.log bak/error_$date.log

# 向Nginx主进程发送USR1信号，重新打开日志文件
kill -s SIGUSR1 `cat ${basepath}/nginx.pid`

# 今日日志打包
tar -jcvf bak/$date.tar.gz bak/access_$date.log bak/error_$date.log

# 定期清除日志
find ${basepath}/bak -mtime +30 -name "*.gz" -exec rm -rf {} \;
find ${basepath}/bak -mtime +1 -name "*.log" -exec rm -rf {} \;

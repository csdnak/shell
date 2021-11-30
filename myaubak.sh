#!/bin/bash
#===========================================================================
#           FileName: mysql_bak.sh
#
#           Author  : WangXinKun
#
#           Created : 12:00,23/03/2020
#===========================================================================
# Backup file is saved in the directory, if it does not exist Create
basepath='/srv/bak_database/bak/'

if [ ! -d "$basepath" ]; then
  mkdir -p "$basepath"
fi

# mysql bakcup to /srv/bak_database/bak/
date_now=`date +"%Y-%m-%d-%H_%M_%S"`

/srv/program/mysql/mysql-5.7/bin/mysqldump --log-error=bak/xczwzn-$date_now-error.log --single-transaction -h 127.0.0.1 -P 3307 --set-gtid-purged=OFF -u root -p'hdzxzj!qazxsw2' xczwzn |gzip > bak/xczwzn-$date_now.sql.gz

# Delete the backup data to 30 days before
#find $basepath -mtime 30 -name "*.sql.gz" -exec rm -rf {} \;
find $basepath -mtime 30 -name "*.sql.gz" -exec rm -rf {} \; -or -mtime 30 -name "*-error.log" -exec rm -rf {} \;

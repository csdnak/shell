#!/bin/bash

date_now=`date +"%Y-%m-%d-%H_%M_%S"`

/srv/program/mysql-3307/mysql-5.7/bin/mysqldump --log-error=bak/iocc_yjzh-$date_now-error.log --single-transaction -h 127.0.0.1 -P 3307 --set-gtid-purged=OFF -u admin -p'Csdn@123' yjzh |gzip > bak/iocc_yjzh-$date_now.sql.gz

/srv/program/mysql-3307/mysql-5.7/bin/mysqldump --log-error=bak/qzfw-iocc-$date_now-error.log --single-transaction -h 127.0.0.1 -P 3307 --set-gtid-purged=OFF -u admin -p'Csdn@123' qzfw |gzip > bak/qzfw-iocc-$date_now.sql.gz



find /srv/bak_database/  -mtime +30 -name "*.sql.gz" -exec rm -rf {} \;
find /srv/bak_database/  -mtime +30 -name "*.log" -exec rm -rf {} \;

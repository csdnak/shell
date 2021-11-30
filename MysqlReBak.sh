#!/bin/bash
#===========================================================================
#           FileName: ReDump.sh
#
#           Author  : WangXinKun
#
#           Created : 20:00,09/06/2020
#===========================================================================
DATA_NOW=`date +"%Y-%m-%d-%H_%M_%S"`
BASEPATH="/var/mysql"
DATABASENAME=""
TABLENAME=""
AUSERNAME=""
APASSWORD=""
BUSERNAME=""
BPASSWORD=""
APORT=""
BPROT=""
AIP=""
BIP=""


#创建数据目录与备份目录
if [ ! -d "$BASEPATH/{myload,mybak}" ];
 then
     mkdir -p $BASEPATH/{myload,mybak}&&

     #从A库导出表数据
     mysqldump -h$AIP -P$APORT -u$AUSERNAME -p$APASSWORD  $DATABASENAME $TABLENAME > $BASEPATH/myload/Atable-$DATA_NOW.sql 2>/dev/null

     #B库中表进行备份
     mysqldump -h$BIP -P$BPORT -u$BUSERNAME -p$BPASSWORD  $DATABASENAME $TABLENAME | gzip > $BASEPATH/mybak/Btable-$DATA_NOW.sql.gz 2>/dev/null

     #B数据库中删除之前导入的表
     mysql -h$BIP -P$BPORT -u$BUSERNAME -p$BPASSWORD -e "DROP TABLE $DATABASENAME.$TABLENAME" 2>/dev/null

     #把表数据导入B库
     mysql -h$BIP -P$BPORT -u$BUSERNAME -p$BPASSWORD $DATABASENAME  < $BASEPATH/myload/Atable-$DATA_NOW.sql 2>/dev/null

     #删除数据库表文件
     cd $BASEPATH/myload/&&rm -rf *.sql

     #删除超过30天的备份包
     find $BASEPATH/mybak/ -mtime 30 -name "*.sql.gz" -exec rm -rf {} \;
 else
     echo "文件夹已经存在"
fi


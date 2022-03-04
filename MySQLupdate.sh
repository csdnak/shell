#!/bin/bash
#===========================================================================
#           FileName: MySQL-Update
#
#           Author  : WangXinKun
#
#           Created : 17:53,03/03/2022
#===========================================================================
#不改变数据文件，升级速度快；但，不可以跨操作系统，不可以跨大版本（5.5—>5.7）
#注：升级不同版本替换二进制包即可
SysBase=`pwd`

read -p "Please input mysql port: " port

echo "停止数据库..."
cd /srv/program/mysql-${port}/mysql-5.7
./bin/mysqladmin -S ./mysql.sock -uroot  shutdown >/dev/null 2>&1

echo "备份..."
cd .. && mv mysql-5.7 mysql-5.7_bak

echo "替换二进制包..."
cd /srv/soft/ && tar -xf  mysql-anzhuang-5.7.36.tar.gz
cd mysql-anzhuang/mysql-7777/ && mv mysql-5.7   /srv/program/mysql-${port}/

echo "替换配置文件..."
cd /srv/program/mysql-${port}/mysql-5.7 && rm -rf startup.sh shutdown.sh my7777.cnf
cp ../mysql-5.7_bak/{startup.sh,shutdown.sh,my${port}.cnf} .

echo "数据库检查..."
./bin/mysqld_safe --defaults-file=/srv/program/mysql-${port}/mysql-5.7/my${port}.cnf & >/dev/null 2>&1 && sleep 10
./bin/mysql_upgrade -S mysql.sock  &&

echo "升级成功，当前数据库版本:"
./bin/mysql -S ./mysql.sock -P${port}  -uroot  -e"select version();"


rm -rf /srv/soft/mysql-anzhuang
rm -rf ${SysBase}/MySQLupdate.sh
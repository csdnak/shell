#!/bin/bash
#===========================================================================
#           FileName: clearlog.sh
#
#           Author  : WangXinKun
#
#           Created : 11:17,18/04/2022
#===========================================================================
# Delete the backup data to 3 days before
# find $basepath -mtime +3 -name "*.sql.gz" -exec rm -rf {} \;
# find $basepath -mtime +3 -name "*.sql.gz" -exec rm -rf {} \; -or -mtime +3 -name "*-error.log" -exec rm -rf {} \;
# Backup file is saved in the directory, if it does not exist Create
LogPath='/srv/program/garbage/logs'
Save_days=3

# date 
date_now=`date +"%Y-%m-%d-%H_%M_%S"`

# path check
if [ ! -d "$LogPath" ]; then
  echo "ERROR:$basepath path is not found!"
fi

# main_log
# Delete the backup data to 3 days before
CollectLogPath="$LogPath/collect-system"
function collect {
	find $CollectLogPath/{error,total} -type f -mtime +$Save_days -name "*.log" -exec rm -rf {} \; &>/dev/null
}

DataLogPath="$LogPath/data-receive"
function data {
	find $DataLogPath/{error,total} -type f -mtime +$Save_days -name "*.log" -exec rm -rf {} \; &>/dev/null
}

DemoLogPath="$LogPath/demo-assistant"
function demo {
	find $DemoLogPath/{error,total} -type f -mtime +$Save_days -name "*.log" -exec rm -rf {} \; &>/dev/null
}

KafkaLogPath="$LogPath/kafka-receive"
function kafka {
	find $KafkaLogPath/{error,total} -type f -mtime +$Save_days -name "*.log" -exec rm -rf {} \; &>/dev/null
}

XCLogPath="$LogPath/xiaochengxu"
function xc {
	find $XCLogPath/{error,info,total} -type f -mtime +$Save_days -name "*.log" -exec rm -rf {} \; &>/dev/null
} 

XXLogPath="$LogPath/xxl-job"
function xxlog {
	find $XXLogPath/{error,total} -type f -mtime +$Save_days -name "*.log" -exec rm -rf {} \; &>/dev/null
}

# run program
case $1 in
clean)
	collect &&
	echo "[ $date_now ] [clear] [$CollectLogPath]	>=$Save_days days log Successfully." >> clearlog.log
	data &&
	echo "[ $date_now ] [clear] [$DataLogPath]		>=$Save_days days log Successfully." >> clearlog.log
	demo  &&
	echo "[ $date_now ] [clear] [$DemoLogPath]		>=$Save_days days log Successfully." >> clearlog.log
	kafka  &&
	echo "[ $date_now ] [clear] [$KafkaLogPath]		>=$Save_days days log Successfully." >> clearlog.log
	xc &&
	echo "[ $date_now ] [clear] [$XCLogPath]		>=$Save_days days log Successfully." >> clearlog.log
	xxlog &&
	echo "[ $date_now ] [clear] [$XXLogPath]		>=$Save_days days log Successfully." >> clearlog.log
;;
*)
	exit 0
;;
esac

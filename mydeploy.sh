#!/bin/bash

# Dir List
# mkdir -p /deploy/code/web-demo
# mkdir -p /deploy/config/web-demo/base
# mkdir -p /deploy/config/web-demo/other
# mkdir -p /deploy/tar
# mkdir -p /deploy/tmp
# mkdir -p /opt/webroot
# mkdir /webroot
# chown -R www.www /deploy
# chown -R www.www /opt/webroot
# chown -R www.www /webroot


# SSH Port
SSH_PORT="6122"

# Node List
NODE_IP="192.168.200."
PRE_LIST="221"
GROUP1_LIST="222"

# Date/Time Veriables
LOG_DATE='date "+%Y-%m-%d"'
LOG_TIME='date "+%H-%M-%S"'

CDATE=`date "+%Y-%m-%d"`
CTIME=`date "+%H-%M-%S"`

# Shell Env
SHELL_NAME="deploy.sh"
SHELL_DIR="/home/www"
SHELL_LOG="${SHELL_DIR}/${SHELL_NAME}.log"

# Code Env
PRO_NAME="web-demo"
CODE_DIR="/deploy/code/web-demo"
CONFIG_DIR="/deploy/config/web-demo"
TMP_DIR="/deploy/tmp"
TAR_DIR="/deploy/tar"
LOCK_FILE="/tmp/deploy.lock"

usage(){
	echo $"Usage:  $0 [ deploy | rollback]"
}

writelog(){
   LOGINFO=$1
   echo "${CDATE}  ${CTIME}: ${SHELL_NAME} : ${LOGINFO} " >> ${SHELL_LOG}

}


shell_lock(){
	touch ${LOCK_FILE}
}

url_test(){
        URL=$1
	echo -e "\033[1;32m[INFO]: Add to cluster...\033[0m"
        curl -s --head $URL | grep '200 OK' &>/dev/null &&  echo -e "\033[1;32m[INFO]: HTTP/1.1 200 OK...\033[0m"
        if [ $? -ne 0 ];then
                shell_unlock;
                writelog "test error";
		echo -e "\033[1;31m[ERROR]: This is project deploy Filad !\033[0m"
	else
		echo -e "\033[1;32m[INFO]: This is project deploy Successfully!\033[0m"
        fi
}

shell_unlock(){
	rm -f ${LOCK_FILE}
}

code_get(){
	writelog  "code_get";
	cd $CODE_DIR && git pull
	cp -r ${CODE_DIR} ${TMP_DIR}/
	API_VERL=$(git show | grep commit | xargs | cut -d ' ' -f2)
        API_VER=`echo ${API_VERL:0:6}`
}

code_build(){
	echo code_build

}

code_config(){
	writelog "code_config"
	/bin/cp -r ${CONFIG_DIR}/base/* ${TMP_DIR}/"${PRO_NAME}"
	PKG_NAME="${PRO_NAME}"_"$API_VER"_"${CDATE}-${CTIME}"
	cd ${TMP_DIR} && mv ${PRO_NAME} ${PKG_NAME}
}

code_tar(){
	writelog "code_tar"
	cd ${TMP_DIR} && tar czf ${PKG_NAME}.tar.gz ${PKG_NAME}
	writelog "${PKG_NAME}.tar.gz"


}

code_scp(){
	writelog "code_scp"
        for number in $PRE_LIST $GROUP1_LIST
           do
                for num in $number
                   do
                        scp -P ${SSH_PORT} ${TMP_DIR}/${PKG_NAME}.tar.gz ${NODE_IP}$num:/opt/webroot/
                done
        done
}


pre_deploy(){
	writelog "remove from cluster"
        for number in $PRE_LIST 
           do
                for num in $number
                   do
			ssh -p ${SSH_PORT} ${NODE_IP}$num  "cd /opt/webroot && tar zxf ${PKG_NAME}.tar.gz"
			ssh -p ${SSH_PORT} ${NODE_IP}$num  "rm -f /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo"
                done
        done
}

pre_test(){
        for number in $PRE_LIST
           do
                for num in $number
                   do
			url_test "http://${NODE_IP}$num/index.html";
                done
        done
}

group1_deploy(){
	writelog "remove from cluster"
        for number in  $GROUP1_LIST
           do
                for num in $number
                   do
			ssh -p ${SSH_PORT} ${NODE_IP}$num  "cd /opt/webroot && tar zxf ${PKG_NAME}.tar.gz"
			ssh -p ${SSH_PORT} ${NODE_IP}$num  "rm -f /webroot/web-demo && ln -s /opt/webroot/${PKG_NAME} /webroot/web-demo"
			scp -P ${SSH_PORT} ${CONFIG_DIR}/other/192.168.200.222.crontab.xml ${NODE_IP}$num:/webroot/web-demo/crontab.xml
                done
        done
}

group1_test(){
        for number in $GROUP1_LIST
           do   
                for num in $number
                   do   
                        url_test "http://${NODE_IP}$num/index.html";
                done
        done
}



rollback(){
	writelog "rollback"
        for number in $PRE_LIST $GROUP1_LIST
           do
                for num in $number
                   do
                        ssh -p ${SSH_PORT} ${NODE_IP}$num  "rm -f /webroot/web-demo && ln -s /opt/webroot/$ROLLBACK_VER /webroot/web-demo"
                done
        done
}

main(){
   if [ -f $LOCK_FILE ];then
	echo "Deploy is running" && exit;
   fi
    DEPLOY_METHOD=$1
    ROLLBACK_VER=$2
    case $DEPLOY_METHOD in
	deploy)
		shell_lock;
		code_get;
		code_build;
		code_config;
		code_tar;
		code_scp;
		pre_deploy;
		pre_test;
		group1_deploy;
		group1_test;
		shell_unlock;
		;;
	rollback)
		shell_lock;
        	if [ "$2" == "list" ]
         	 then 
		 	ls -l /opt/webroot/*.tar.gz
		elif [ "$2" != ""  ]
		 then
                        if [ -d /opt/webroot/$2 ];then
                                rollback $ROLLBACK_VER;
                                pre_test;
                                group1_test;
                        else
                                echo -e "\033[1;31m[ERROR]: Directory is not found!\033[0m"
                        fi
   	        else 
           	        echo " Usage:  $0 rollback [ list | version] "
    	   	fi
		shell_unlock;
		;;
	*)
		usage;
    esac
}
main $1 $2 


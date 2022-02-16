#!/bin/bash
#========================
#run "sed -i 's/\r$//' start.sh" 
#========================
cecho () {
echo -e  "                  |  \033[1;32mC\033[0m    \033[1;33mS\033[0m    \033[1;35mD\033[0m    \033[1;36mN\033[0m    \E[1;35m阿\033[0m    \033[1;34m坤\033[0m     |"
}
echo     '                                 .-"""-.                '
echo     "                                / .===. \               "
echo     "                                \/ 6 6 \/               "
echo     "                                ( \___/ )               "
echo     "                   _________ooo__\_____/_____________   "
echo     "                  /                                  \  "
                                            cecho
echo     "                  \_______________________ooo________/  "
echo     "                                 |  |  |                "
echo     "                                 |_ | _|                "
echo     "                                 |  |  |                "
echo     "                                 |__|__|                "
echo     "                                 /-'Y'-\                "
echo     "                                (__/ \__)               "

m=！
echo    "=====================Oo欢迎使用安全脚本,祝您使用愉快oO==========================="
echo -e "                           \033[36mOo安全检测开始oO\033[0m                               "
#开始
#echo -e "\033[1;32mrunning...\033[0m"

#SBL-System-Linux-01-01
result=`awk -F: '($3 == 0) { print $1 }' /etc/passwd`
if [ $result == root ]
    then
          echo -e "\033[34m01.\033[0m\033[35mSBL-System-Linux-01-01$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m01.\033[0m\033[35mSBL-System-Linux-01-01$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-01-02
result2=`awk -F: '($2 == "") { print $1 }' /etc/shadow`
if [ "$result2" == "" ]
    then
          echo -e "\033[34m02.\033[0m\033[35mSBL-System-Linux-01-02$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m02.\033[0m\033[35mSBL-System-Linux-01-02$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-01-03
result3=`cut -d: -f1 /etc/passwd &>/dev/null && echo $?`
if [ $? == "0" ]
    then
          echo -e "\033[34m03.\033[0m\033[35mSBL-System-Linux-01-03$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m03.\033[0m\033[35mSBL-System-Linux-01-03$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-02-01
#原始值：99999
sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g"  /etc/login.defs
result4=`cat /etc/login.defs | grep ^PASS_MAX_DAYS | awk  -F" " '{print $2}'`
if [ $result4 == "90" ]
    then
          echo -e "\033[34m04.\033[0m\033[35mSBL-System-Linux-02-01$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m04.\033[0m\033[35mSBL-System-Linux-02-01$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-02-02
#原始值：0
sed -i "s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/g"  /etc/login.defs
result5=`cat /etc/login.defs | grep ^PASS_MIN_DAYS | awk  -F" " '{print $2}'`
if [ $result5 == "1" ]
    then
          echo -e "\033[34m05.\033[0m\033[35mSBL-System-Linux-02-02$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m05.\033[0m\033[35mSBL-System-Linux-02-02$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-02-03
#原始值：5
sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN    8/g"  /etc/login.defs
result6=`cat /etc/login.defs | grep ^PASS_MIN_LEN | awk  -F" " '{print $2}'`
if [ $result6 == "8" ]
    then
          echo -e "\033[34m06.\033[0m\033[35mSBL-System-Linux-02-02$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m06.\033[0m\033[35mSBL-System-Linux-02-02$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-02-04
#原始值：7
sed -i "s/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/g"  /etc/login.defs
result7=`cat /etc/login.defs | grep ^PASS_WARN_AGE | awk  -F" " '{print $2}'`
if [ $result7 == "14" ]
    then
          echo -e "\033[34m07.\033[0m\033[35mSBL-System-Linux-02-04$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m07.\033[0m\033[35mSBL-System-Linux-02-04$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-03-01
#结果为：空正常
result8=`echo $PATH | sed 's|:|\n|g' | grep "\."`
if [ "$result8" == "." ]
    then
		  echo -e "\033[34m08.\033[0m\033[35mSBL-System-Linux-03-01$m\033[0m        \033[1;31m[Failed]\033[0m"
		  echo "$result8"
else
          echo -e "\033[34m08.\033[0m\033[35mSBL-System-Linux-03-01$m\033[0m        \033[1;32m[OK]\033[0m"
fi

#SBL-System-Linux-03-02
chmod +644 /etc/passwd &&
chmod +000 /etc/shadow &&
chmod +644 /etc/group  &&
chmod +644 /etc/services &&
echo -e "\033[34m09.\033[0m\033[35mSBL-System-Linux-03-02$m\033[0m        \033[1;32m[OK]\033[0m" ||
echo -e "\033[34m09.\033[0m\033[35mSBL-System-Linux-03-02$m\033[0m        \033[1;31m[Failed]\033[0m"

#SBL-System-Linux-03-03
chmod +755 /etc          &&
chmod +755 /etc/security &&
chmod +755 /etc/rc.d     &&
echo -e "\033[34m10.\033[0m\033[35mSBL-System-Linux-03-03$m\033[0m        \033[1;32m[OK]\033[0m" ||
echo -e "\033[34m10.\033[0m\033[35mSBL-System-Linux-03-03$m\033[0m        \033[1;31m[Failed]\033[0m"

#SBL-System-Linux-03-04
#结果为：002/022为正常
num1=`cat /etc/profile | grep -i "umask 002" | awk -F" " '{printf $2}' && cat /etc/bashrc | grep -i "umask 022" | awk -F" " '{print $2}'`
num2=`cat /etc/csh.cshrc | grep -i "umask 002" | awk -F" " '{printf $2}' && cat /etc/bashrc | grep -i "umask 022" | awk -F" " '{print $2}'`
num3=`cat /etc/bashrc | grep -i "umask 002" | awk -F" " '{printf $2}' && cat /etc/bashrc | grep -i "umask 022" | awk -F" " '{print $2}'`
number=`echo "$num1$num2$num3"`
if [ "$number" == "002022002022002022" ]
    then
          echo -e "\033[34m11.\033[0m\033[35mSBL-System-Linux-03-04$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m11.\033[0m\033[35mSBL-System-Linux-03-04$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-04-01
#结果为：authpriv.*   /var/log/secure
char1=`cat /etc/rsyslog.conf | grep ^authpriv.*`
char2="authpriv.*                                              /var/log/secure"
if [ "$char1" == "$char2" ]
    then
          echo -e "\033[34m12.\033[0m\033[35mSBL-System-Linux-04-01$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m12.\033[0m\033[35mSBL-System-Linux-04-01$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL- System- Linux-05-01
#原始值：yes
sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g"  /etc/ssh/sshd_config
result9=`cat /etc/ssh/sshd_config | grep PermitRootLogin | head -n 1`
if [ "$result9" == "PermitRootLogin no" ]
    then
          echo -e "\033[34m13.\033[0m\033[35mSBL-System-Linux-05-01$m\033[0m        \033[1;32m[OK]\033[0m"
else
          sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g"  /etc/ssh/sshd_config &&
		  echo -e "\033[34m13.\033[0m\033[35mSBL-System-Linux-05-01$m\033[0m        \033[1;32m[OK]\033[0m"
fi

#SBL- System- Linux-05-02
yum  -y remove telnet &>/dev/null && 
systemctl start sshd &&
echo -e "\033[34m14.\033[0m\033[35mSBL-System-Linux-05-02$m\033[0m        \033[1;32m[OK]\033[0m" ||
echo -e "\033[34m14.\033[0m\033[35mSBL-System-Linux-05-02$m\033[0m        \033[1;31m[Failed]\033[0m"

#SBL- System- Linux-05-03
#原始值：无
result10=`cat /etc/hosts.allow |grep ^sshd`
if [ "$result10" == "" ]
    then
		echo "sshd:192.168.:allow"  >> /etc/hosts.allow
		echo "sshd:ALL"  >> /etc/hosts.deny
fi
result10=`cat /etc/hosts.deny |grep ^sshd`
if [ "$result10" == "sshd:ALL" ]
    then
          echo -e "\033[34m15.\033[0m\033[35mSBL-System-Linux-05-03$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m15.\033[0m\033[35mSBL-System-Linux-05-03$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-06-01
#原始值：systemctl stop firewalld && systemctl disable firewalld
systemctl start firewalld  && 
systemctl enable firewalld &>/dev/null &&
echo -e "\033[34m16.\033[0m\033[35mSBL-System-Linux-06-01$m\033[0m        \033[1;32m[OK]\033[0m" 

#SBL-System-Linux-06-02
systemctl stop snmpd       &>/dev/null &&  
systemctl disable snmpd    &>/dev/null
echo -e "\033[34m17.\033[0m\033[35mSBL-System-Linux-06-02$m\033[0m        \033[1;32m[OK]\033[0m" 

#SBL-System-Linux-06-03
chkconfig --list  &>/dev/null &&
echo -e "\033[34m18.\033[0m\033[35mSBL-System-Linux-06-03$m\033[0m        \033[1;32m[OK]\033[0m" 

#SBL-System-Linux-06-04
chkconfig --list  &>/dev/null &&
echo -e "\033[34m19.\033[0m\033[35mSBL-System-Linux-06-04$m\033[0m        \033[1;32m[OK]\033[0m" 

#SBL-System-Linux-07-01
result11=`find / -name .rhosts`
result12=`find / -name .netrc`
if [ "$result11" == "" ]
    then
		if [ "$result12" == "" ]
		    then
				echo -e "\033[34m20.\033[0m\033[35mSBL-System-Linux-07-01$m\033[0m        \033[1;32m[OK]\033[0m"
		fi
else
          echo -e "\033[34m20.\033[0m\033[35mSBL-System-Linux-07-01$m\033[0m        \033[1;31m[Failed]\033[0m"
fi

#SBL-System-Linux-08-01
useradd user1 &&
sed -i "/^root/a user1    ALL=(ALL)       ALL"  /etc/sudoers && echo "Csdn@123" | passwd --stdin user1&>/dev/null
result13=`cat /etc/sudoers |grep ^user1`
if [ "$result13" == "user1    ALL=(ALL)       ALL" ]
    then
          echo -e "\033[34m21.\033[0m\033[35mSBL-System-Linux-08-01$m\033[0m        \033[1;32m[OK]\033[0m"
else
          echo -e "\033[34m21.\033[0m\033[35mSBL-System-Linux-08-01$m\033[0m        \033[1;31m[Failed]\033[0m"
fi




### firewalld--TCP
# tcp6-port
netstat -tpln | awk 'NR>2' | grep  tcp6 |awk '{print $4}'  |awk -F: '{print $4}' >> ./test-tcp6 
netstat -tpln | awk 'NR>2' | grep  tcp6 |awk '{print $4}'  |awk -F: '{print $2}' >> ./test-tcp6 
#  delete null
sed -i '/^ *$/d' ./test-tcp6
# tcp-port
netstat -tpln | awk 'NR>2' | grep -v tcp6 |awk '{print $4}'  |awk -F: '{print $2}' >> ./test-tcp
#  delete null
sed -i '/^ *$/d' ./test-tcp
#
for i in  $(cat ./test-tcp)
do
	firewall-cmd --zone=public --add-port=$i/tcp --permanent &>/dev/null
	#echo "$i"  >> port.txt
done

for i in $(cat ./test-tcp6)
do
	for h in $(cat ./test-tcp )
	do
		if [ $i == $h ];then
			# echo "repeat"
			break
		else
			firewall-cmd --zone=public --add-port=$i/tcp --permanent &>/dev/null
			#echo "$i"  >> port.txt
		fi
	done
done
firewall-cmd --reload &>/dev/null && echo -e "\033[34m22.\033[0m\033[35mSBL-System-Linux-08-02$m\033[0m        \033[1;32m[OK]\033[0m"
firewall-cmd --zone=public --list-ports >> port.txt

rm -rf ruler-1.sh && rm -rf test-tcp*  &&
echo    "                  --------------自动检测完成!---------------                    "
echo    "==============================期待您的再次使用！！==============================="

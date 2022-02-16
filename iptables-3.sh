################oraclefirewall.sh##############################
#-- 删除一条规则
#iptables -D INPUT 11 （注意，这个11是行号，是iptables -L INPUT --line-numbers 所打印出来的行号）
#!/bin/bash
LC_ADDR=192.168.200.201
LO_ADDR=127.0.0.1

#必备工具
yum -y install iptables-services >/dev/null 2>&1


#关闭firewalld
systemctl stop firewalld 
systemctl disable firewalld >/dev/null 2>&1

#清除现有的规
iptables -F

#封闭进入
iptables -P INPUT DROP

#允许本机和本机联系
iptables -A INPUT -p ALL -s $LC_ADDR -d $LC_ADDR -j ACCEPT
iptables -A INPUT -p ALL -s $LO_ADDR -d $LO_ADDR -j ACCEPT

#开启Ping
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

#没有漏洞的port可添加此策略（后期添加）
#iptables -A INPUT -s 0.0.0.0/0 -p tcp --dport 5099 -j ACCEPT
#iptables -I INPUT -p ALL -s 192.168.200.61 -d 192.168.200.202 -j ACCEPT
#iptables -A OUTPUT -p ALL -s 192.168.200.202 -d 192.168.200.61 -j ACCEPT

#特殊ip
iptables -A INPUT -p ALL -s 210.12.168.169 -d 192.168.200.201 -j ACCEPT
iptables -A INPUT -p ALL -s 10.111.62.218 -d 192.168.200.201 -j ACCEPT

#二层
iptables -A INPUT -s 10.165.114.0/24 -j ACCEPT
#六层
iptables -A INPUT -s 192.168.61.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.62.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.63.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.64.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.65.0/24 -j ACCEPT
#四层
iptables -A INPUT -s 192.168.82.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.83.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.84.0/24 -j ACCEPT
#云平台
iptables -A INPUT -s 192.168.200.0/24 -j ACCEPT

#vpn
iptables -A INPUT -s 192.168.45.0/24 -j ACCEPT


#对进来的包的状态进行检测。已经建立tcp连接的包以及该连接相关的包允许通过
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 

#保存 安装iptables-service
service iptables save
systemctl restart iptables
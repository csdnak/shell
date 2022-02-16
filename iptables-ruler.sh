#!/bin/bash
#关闭
systemctl stop firewalld
systemctl disabled firewalld

#没有漏洞的port可添加此策略（后期添加）
#iptables -A INPUT -s 0.0.0.0/0 -p tcp --dport 5099 -j ACCEPT

#二层
iptables -A INPUT -s 10.165.114.0/24 -j ACCEPT
#六层
iptables -A INPUT -s 192.168.61.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.62.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.63.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.64.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.65.0/24 -j ACCEPT
#四层
iptables -A INPUT -s 192.168.83.0/24 -j ACCEPT
iptables -A INPUT -s 192.168.84.0/24 -j ACCEPT
#云平台
iptables -A INPUT -s 192.168.200.0/24 -j ACCEPT

#vpn
iptables -A INPUT -s 192.168.45.0/24 -j ACCEPT

#icmp
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 

iptables -A INPUT -s 0.0.0.0/0 -j REJECT

#保存 安装iptables-service

service iptables save
systemctl restart iptables
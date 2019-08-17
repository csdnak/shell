#!/bin/bash
# TsengYia 2016.06.25
num=$(hostname -s | grep -oE '[0-9]+$')
[ -z "$num" ] && num=0
system1="server${num}"
system2="desktop${num}"
domain="example.com"
ip1="172.25.${num}.11"
ip2="172.25.${num}.10"
> /tmp/pass.rec
ok() {
    echo -e "\033[32mpass\033[0m"
    echo pass >> /tmp/pass.rec
}
failed() {
    echo -e "\033[31mfailed\033[0m";
    echo failed >> /tmp/pass.rec
}

echo "######## Check-Report for $system2 #######"
echo -n "01. checking selinux status .... "
getenforce | grep -qw Enforcing && ok || failed

echo -n "02. checking ssh access .... "
grep -qE " *DenyUsers.*\*@(my133.org|172.34.0.)" /etc/ssh/sshd_config || firewall-cmd --list-all --zone=block 2> /dev/null | grep -qw "172.34.0.0/24" || firewall-cmd --list-all --zone=drop 2> /dev/null | grep -qw "172.34.0.0/24" && ok || failed

echo -n "03. checking alias .... "
alias qstat 2> /dev/null | grep -qE "/bin/ps +-Ao +pid,tt,user,fname,rsz" && ok || failed

echo -n "04. checking firewall configuration .... "
systemctl is-active firewalld &> /dev/null && firewall-cmd --list-all --zone=block 2> /dev/null | grep -qw "172.34.0.0/24" || firewall-cmd --list-all --zone=drop 2> /dev/null | grep -qw "172.34.0.0/24" && firewall-cmd --list-all --zone=trusted  | grep -qw default && ok || failed

echo -n "05. checking teambridge .. .."
ifconfig team0 2> /dev/null | grep -qw 172.16.3.25 && ok || failed

echo -n "06. checking ipv6 address .. .. "
ip add list eth0 | grep -qw "2003:ac18::306/64" && ping6 -c3 -i 0.2 -W1 2003:ac18::305 &> /dev/null && ok || failed

echo -n "07. checking smtp-nullclient mail .. .. "
grep -qw "Subject: Test1" /var/mail/student && ok || failed

echo -n "08. checking samba server .. .."
mkdir -p /tmp/mnt ; mount -o username=harry,password=migwhisk //${system1}/common /tmp/mnt &> /dev/null && ok && umount /tmp/mnt || failed

echo -n "09. checking multiuser samba .. .. "
mount | grep -qE "^//(${system1}|${ip1}).*/devops on /mnt/dev .*sec=ntlmssp.*" && mount -o username=chihiro,password=atenorth,multiuser,sec=ntlmssp //${system1}/devops /tmp/mnt && ok && umount /tmp/mnt || failed

echo -n "10. checking NFS server .. .."
showmount -e ${system1} 2> /dev/null | grep -qw "^/public" && showmount -e ${system1} 2> /dev/null | grep -qw "^/protected"  && ok || failed

echo -n "11. checking NFS client .. .. "
wget http://classroom/pub/keytabs/${system2}.keytab -O /tmp/${system2}.keytab &> /dev/null
diff /etc/krb5.keytab /tmp/${system2}.keytab &> /dev/null && systemctl is-active nfs-secure &> /dev/null && mount | grep -qE "^(${system1}|${ip1}).*/public .*/mnt/nfsmount .*" && mount | grep -qE "^(${system1}|${ip1}).*/protected .*/mnt/nfssecure.*" && ok || failed

echo -n "12. checking web-default .. .. "
yum -y install elinks &> /dev/null ; elinks -dump http://${system1}.${domain} 2> /dev/null | grep -qw "Default Site." && ok || failed

echo -n "13. checking web-HTTPS .. .. "
wget https://${system1}.${domain} 2>&1 | grep -q "North Carolina" && ok || failed

echo -n "14. checking web-virtualhost .. .. "
elinks -dump http://www${num}.${domain} 2> /dev/null | grep -qw "Virtual Site." && ok || failed

echo -n "15. checking web-access controll .. .. "
elinks -dump http://${system1}.${domain}/private 2> /dev/null | grep -qw "Forbidden" && ok || failed

echo -n "16. checking web-dynamic WSGI .. .. "
elinks -dump http://webapp${num}.${domain}:8909 2> /dev/null | grep -qw "UNIX EPOCH time is now:" && ok || failed

echo -n "17. checking shell script .. .. "
echo "skiped"
echo -n "18. checking batch users .. .. "
echo "skiped"
echo -n "19. checking iSCSI server .. .. "
echo "skiped"

echo -n "20. checking iSCSI client .. .. "
df -h /mnt/data 2> /dev/null | grep -qE "^/dev/sda1 +2.0G +" && ok || failed

echo -n "21. checking MariaDB deployment .. .. "
echo "skiped"
echo -n "22. checking MariaDB select .. .. "
echo "skiped"
echo "######## ######## ########  ######## ######## #######"

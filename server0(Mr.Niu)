#!/bin/bash
# TsengYia 2016.06.25
#num=$(hostname -s | grep -oE '[0-9]+$')
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
    echo -e "\033[31mfailed\033[0m"
    echo failed >> /tmp/pass.rec
}

echo "######## Check-Report for $system1 #######"
echo -n "01. checking selinux status .... "
getenforce | grep -qw Enforcing && ok || failed

echo -n "02. checking ssh access .... "
grep -qE " *DenyUsers.*\*@(my133.org|172.34.0.)" /etc/ssh/sshd_config || firewall-cmd --list-all --zone=block 2> /dev/null | grep -qw "172.34.0.0/24" || firewall-cmd --list-all --zone=drop 2> /dev/null | grep -qw "172.34.0.0/24" && ok || failed

echo -n "03. checking alias .... "
alias qstat &> /dev/null && alias qstat | grep -qE "/bin/ps +-Ao +pid,tt,user,fname,rsz" && ok || failed

echo -n "04. checking firewall configuration .... "
systemctl is-active firewalld &> /dev/null && firewall-cmd --list-all --zone=block 2> /dev/null | grep -qw "172.34.0.0/24" || firewall-cmd --list-all --zone=drop 2> /dev/null | grep -qw "172.34.0.0/24" && firewall-cmd --list-all --zone=trusted  | grep -qw default && firewall-cmd --list-all --zone=trusted  | grep -qw "port=5423:proto=tcp:toport=80" && ok || failed

echo -n "05. checking teambridge .. .."
ifconfig team0 2> /dev/null | grep -qw 172.16.3.20 && ok || failed

echo -n "06. checking ipv6 address .. .. "
ip add list eth0 | grep -qw "2003:ac18::305/64" && ping6 -c3 -i 0.2 -W1 2003:ac18::306 &> /dev/null && ok || failed

echo -n "07. checking smtp-nullclient mail .. .. "
lab smtp-nullclient grade | grep -q PASS && ok || failed
echo "Mail Data" | mail -s "Test1" student 2> /dev/null

echo -n "08. checking samba server .. .."
yum -y install cifs-utils samba-client &> /dev/null ; mkdir -p /tmp/mnt ; mount -o username=harry,password=migwhisk //${system1}/common /tmp/mnt &> /dev/null && ok && umount /tmp/mnt || failed

echo -n "09. checking multiuser samba .. .. "
getfacl -p /devops 2> /dev/null | grep -q "user:chihiro:rwx" && mount -o username=chihiro,password=atenorth,multiuser,sec=ntlmssp //${system1}/devops /tmp/mnt && ok && umount /tmp/mnt || failed

echo -n "10. checking NFS server .. .. "
wget http://classroom/pub/keytabs/${system1}.keytab -O /tmp/${system1}.keytab &> /dev/null
diff /etc/krb5.keytab /tmp/${system1}.keytab &> /dev/null && ls -ld /protected/project/ | grep -qw "ldapuser${num} root" && grep -qE "^/protected.*sec=krb5p" /etc/exports && systemctl is-active nfs-secure-server &> /dev/null && systemctl is-active nfs-server &> /dev/null && ok || failed

echo -n "11. checking NFS client .. .. "
mkdir -p /tmp/mnt ; systemctl restart nfs-secure &> /dev/null && showmount -e ${system1} 2> /dev/null | grep -qw protected && mount -o v4,sec=krb5p ${system1}:/protected /tmp/mnt &> /dev/null && ok && umount //tmp/mnt || failed

echo -n "12. checking web-default .. .. "
yum -y install elinks &> /dev/null ; elinks -dump http://${system1}.${domain} 2> /dev/null| grep -qw "Default Site." && ok || failed

echo -n "13. checking web-HTTPS .. .. "
netstat -anpt | grep -qw :443 && wget https://${system1}.${domain} 2>&1 | grep -q "North Carolina" && ok || failed

echo -n "14. checking web-virtualhost .. .. "
elinks -dump http://www${num}.${domain} 2> /dev/null | grep -qw "Virtual Site." && ok || failed

echo -n "15. checking web-access controll .. .. "
ifconfig lo:0 172.${num}.${num}.1
elinks -dump http://${system1}.${domain}/private 2> /dev/null | grep -qw "Private Site." && elinks -dump http://172.${num}.${num}.1/private | grep -qw "Forbidden" && ok || failed

echo -n "16. checking web-dynamic WSGI .. .. "
netstat -antpu | grep -qw :8909 && elinks -dump http://webapp${num}.${domain}:8909 2> /dev/null | grep -qw "UNIX EPOCH time is now:" && ok || failed

echo -n "17. checking shell script .. .. "
[ -x /root/foo.sh ] && /root/foo.sh 2>&1 | grep -qEw  "/root/foo.sh ?redhat|fedora" && /root/foo.sh redhat | grep -qw fedora && /root/foo.sh fedora | grep -qw redhat && ok || failed

echo -n "18. checking batch users .. .. "
echo -e "chk01\nchk02" > /tmp/u001.txt ; [ -x /root/batchusers ] && /root/batchusers | grep -qEw "Usage: ?/root/batchusers <userfile>" && /root/batchusers /tmp/u002.txt | grep -qw "Input file not found" && /root/batchusers /tmp/u001.txt &> /dev/null && id chk01 &> /dev/null && grep -w chk01 /etc/passwd | grep -qw /bin/false && ok || failed ; userdel -r chk01 2> /dev/null && userdel -r chk02 2> /dev/null

echo -n "19. checking iSCSI server .. .. "
targetcli ls 2> /dev/null | grep -qEw "iqn.2016-02.com.example:${system1}.*TPGs:.*" && targetcli ls 2> /dev/null | grep -qEw "iqn.2016-02.com.example:${system2}.*LUNs:.*" && targetcli ls | grep -qwE "$ip1:3260|0.0.0.0:3260" && ok || failed

echo -n "20. checking iSCSI client .. .. "
echo "skiped"

echo -n "21. checking MariaDB deployment .. .. "
mysql -u root -patenorth -e 'show databases;' &> /dev/null && mysql -u Raikon -patenorth -e 'use Contacts; show tables;' 2> /dev/null | grep -qw location && mysql -u root -patenorth -h ${system1} -e 'show databases;' 2>&1 | grep -qw ERROR && ok || failed

echo -n "22. checking MariaDB select .. .. "
echo "skiped"
echo "######## ######## ########  ######## ######## #######"

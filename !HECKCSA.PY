#!/usr/bin/env python
#*-* coding: utf-8 *-*


import subprocess
import shutil
import os

sVersion = 2.4
scoreDict = {'score' : 300, }
hostName = 'server0.example.com'
hostIP = '172.25.0.11/24'
hostGW = '172.25.0.254'
hostDNS = '172.25.254.254'
uPasswd = 'flectrag'
userList = [{'sarah': uPasswd}, {'harry': uPasswd}, {'alex': uPasswd}, {'natasha': uPasswd}]
gName = 'adminuser'
num = 80

def parting_line(num=80):
    partingLine = '*' * num
    parting = """
%(partingline)s
"""
    print parting % dict(partingline=partingLine)

# def print_res(str, num=80, res = ''):
#     print str.ljust(num - 4),res

def print_res(str, num=80, res = ''):
    fColor = '\033[1;31;47m'
    lColor = '\033[0m'
    snum = num - 4 - len(str)
    print  '%s%s%s%s%s' % (fColor, str,  ' ' * snum,res,lColor)

def print_ok(str, ):
    fColor = '\033[1;32;48m'
    lColor = '\033[0m'
    print  '%s%s%s' % (fColor, str,lColor)


#检查hostname命令及 '/etc/hostname'文件 不检查root
def check_hName(hostName):
    parting_line()
    print '1、检查主机名'
    try:
        nList = subprocess.Popen('hostname', shell=True, stdout = subprocess.PIPE).stdout.readlines()
        fList = subprocess.Popen('cat /etc/hostname', shell=True, stdout = subprocess.PIPE).stdout.readlines()
        if nList[-1].strip() == hostName  and fList[-1].strip() == hostName:
            print_ok('Hostname check OK !')
        else:
            print_res('ERROR: Hostname check error !!!', num, -10)
            scoreDict['score'] -= 10
    except IndexError:
        print_res('ERROR: Hostname check error !!!', num, -10)
        scoreDict['score'] -= 10
    return scoreDict['score']

def check_IP(hostIP, hostGW, hostDNS):
    parting_line(num)
    print '2、检查IP、网关、DNS'
    #connection.autoconnect:                 yes
    coList = subprocess.Popen('nmcli connection show "System eth0" | grep connection.autoconnect', shell=True, \
                              stdout=subprocess.PIPE).stdout.readlines()[0].split()[-1].strip()
    if coList != 'yes':
        print_res('ERROR: connection.autoconnect is "no"  !!!!', num, -10)
        scoreDict['score'] -= 10

    try:
        ipList = subprocess.Popen('nmcli connection show "System eth0" | grep IP4', shell=True,\
                              stdout=subprocess.PIPE).stdout.readlines()

        if (ipList[0].split(' ')[-4].strip()[:-1] == hostIP) and (ipList[0].split(' ')[-1].strip() == hostGW) and (
            ipList[1].split(' ')[-1].strip() == hostDNS):
            print_ok('Network configuretion check OK !')
        else:
            print_res('ERROR: Network configuretion check error !!!', num, -10)
            scoreDict['score'] -= 10
    except  IndexError:
        print_res('ERROR: Network options is not config !!!!', num, -10)
        scoreDict['score'] -= 10
    return scoreDict['score']

#最多检查2个yum仓库
def check_yum():
    parting_line()
    print '3、检查YUM仓库'
    subprocess.call('yum clean all &> /dev/null', shell=True)
    yumList = subprocess.Popen('yum repolist ', shell=True, stdout = subprocess.PIPE).stdout.readlines()
    if yumList[-2].split(' ')[-1].strip() == '0' or yumList[-3].split(' ')[-1].strip() == '0' :
        print_res('ERROR: YUM check error!!!', num, -10)
        scoreDict['score'] -= 10
    else:
        print_ok('YUM check OK !')
    return scoreDict['score']

#将ssh密码验证的错误次数修改为1,可以不用.
def ssh_auth1():

    shutil.copy('/etc/ssh/sshd_config', '/etc/ssh/sshd_config.bak')
    subprocess.call("sed -i  '/#MaxAuthTries/s/#MaxAuthTries 6/MaxAuthTries 1/' /etc/ssh/sshd_config", shell=True)
    if not subprocess.call('systemctl restart sshd', shell=True):
        print
    else:
        shutil.copy('/etc/ssh/sshd_config.bak', '/etc/ssh/sshd_config')
        subprocess.call('systemctl restart sshd', shell=True)

def check_user_perm(gName, userName):
    gfile = '/etc/gshadow'
    if os.path.exists('/etc/gshadow'):
        print_ok('Find the file %s' % gfile)
    else:
        print_ok('Cat`t find %s,use %s-'% (gfile, gfile))
        gfile = '/etc/gshadow-'
    if not subprocess.call('grep %s %s | grep %s' % (gName, gfile, userName), shell=True):
        print_ok('The user "%s"  is belong to the group  "%s"' % ( userName, gName ))
    else:
        print_res('ERROR: The user "%s" is not belong to the group "%s"' % ( userName, gName) , num, -10)
        scoreDict['score'] -= 10

    return scoreDict['score']
#检查用户是否存在 密码是否正确
def check_user_login(userName, passwd):
    print '4、检查用户密码'
    os.system('yum -y install expect &> /dev/null')
    subprocess.call('rm -rf /home/%s/test.txt &> /dev/null' % userName, shell=True)
    eCMDS = """
user=%(username)s
passwd=%(password)s
/usr/bin/expect <<-EOF
set timeout 4
spawn ssh  ${user}@127.0.0.1
expect {
"*yes/no" { send "yes\r"; exp_continue }
"*password:" { send "${passwd}\r" }
}
expect "*$"
send "touch test.txt\r"
expect "*$"
send "exit\r"   
expect eof
EOF
    """
    subprocess.call(eCMDS % dict(username=userName, password=passwd), shell=True)
    if subprocess.call('ls /home/%s/test.txt &> /dev/null' % userName, shell=True):
        print_res('ERROR: The user "%s" is added, but authentication failure !!!' % (userName), num, -10)
        scoreDict['score'] -= 10
    else:
        print_ok('The user "%s" password authentication success !!!             ' % (userName))
    return scoreDict['score']


def check_user(userList,ifCheck):
    parting_line()
    print '5、检查用户权限'
    ssh_auth1()
    for userDict in userList:
        for key in userDict:
            userName = key
            passwd = userDict[key]
            # with open('/root/passwd')  as f:
            #     for  i in  f.readlines():
            #         uList = i.split(':')
            #         if uList[0] == userName:
            #             print 'The user "%s" is  found !!!  '  % (userName)
            #             break
            #     else:
            #         print 'The user "%s" is not found !!!  -20'  % (userName)
            #         scoreDict['score'] - 20
            if not os.system('id %s ' % userName) :
                print_ok('The user "%s" is  found !!!  '  % (userName))
            else:
                print_res('ERROR: The user "%s" is not found !!!' % (userName), num, -10)
                scoreDict['score'] -= 10
                break


            if userName == 'sarah':
                if subprocess.Popen('grep sarah /etc/passwd', shell=True,stdout=subprocess.PIPE).stdout.readlines()[0].split(':')[-1].strip() == '/sbin/nologin' :
                    print_ok('The user "%s" check OK !!!             ' % (userName))
                else:
                    print_res('ERROR: The user "%s" check failure !!!' % (userName), num, -10)
                    scoreDict['score'] -= 10
            elif userName == 'alex':
                uID = subprocess.Popen('grep alex /etc/passwd', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split(':')[2]
            	if  ifCheck:
                	scoreDict['score'] = check_user_login(userName, passwd)
                if uID != '3456':
                    print_res('ERROR: The user "alex" ID is %s' % uID, num, -10)
                    scoreDict['score'] -= 10
            else:
            	if  ifCheck:
                	scoreDict['score'] = check_user_login(userName, passwd)
                scoreDict['score'] = check_user_perm(gName, userName)
    return scoreDict['score']

def check_file():
    parting_line()
    print '6、检查fstab权限'
    if os.path.isfile('/var/tmp/fstab'):
        print_ok('The file "/var/tmp/fstab" check OK !')
        if not subprocess.Popen('getfacl /var/tmp/fstab | grep natasha ' , shell=True, stdout=subprocess.PIPE).stdout.readlines()[0] == 'natasha::rw-\n':
            print_res('ERROR: The file "/var/tmp/fstab" with "natasha" check error!!!' , num, -10)
            scoreDict['score'] -= 10
        if not subprocess.Popen('getfacl /var/tmp/fstab | grep harry ' , shell=True, stdout=subprocess.PIPE).stdout.readlines()[0] == 'harry::-\n':
            print_res('ERROR: The file "The file "/var/tmp/fstab" with "harry" check error!!!', num, -10)
            scoreDict['score'] -= 10
    else:
        print_res('The file is not exist !!!', num, -10)
        scoreDict['score'] -= 10
    return scoreDict['score']

def check_permission(gname):
    parting_line()
    print '7、检查组权限'
    gCMDS = 'grep %s /etc/group' % gname
    if  not subprocess.call(gCMDS, shell=True):
        print 'The group "%s" authentication success !!!             ' % (gname)
    else:
        print_res('ERROR: The group "%s" authentication failure' % (gname), num, -10)
        scoreDict['score'] -= 10
    return scoreDict['score']

def check_cron():
    parting_line()
    print '8、检查计划任务'
    cronList=["23 14 * * *  echo 'heya'\n", "23 14 * * *  echo heya\n",'23 14 * * *  echo "heya"\n']
    cronNatasha = subprocess.Popen('crontab -l -u natasha', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0]
    if cronNatasha not in cronList:
        print_res('ERROR: The crontab of natasha check error !!!', num, -10)
        scoreDict['score'] -=10
    return scoreDict['score']

def check_share_dir():
    parting_line()
    print '9、检查共享目录'
    if not os.path.isdir('/home/admins'):
        print_res('ERROR: The dir "/home/admins" check error !!!', num, -10)
        scoreDict['score'] -= 10
    else:
        if oct(os.stat('/home/admins').st_mode)[2:] == '2770' and os.stat('/home/admins').st_gid == 1001:
            print 'The dir permission "/home/admins" check ok !!!             '
        else:
            print_res('ERROR: The dir permission "/home/admins" check error !!!', num, -10)
            scoreDict['score'] -= 10
    return scoreDict['score']
def check_kernel():
    parting_line()
    print '10、检查内核版本'
    kernelVersion = subprocess.Popen('uname -r', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].strip()
    print kernelVersion
  #  if kernelVersion != '3.10.0-123.el7.x86_64':
    if kernelVersion != '3.10.0-123.1.2.el7.x86_64':
        print_res('ERROR: The KernelVersion  check error !!!', num, -10)
        scoreDict['score'] -=10
    else:
        print_ok('The KernelVersion  check OK!')
    return scoreDict['score']

def check_LVM():
    parting_line()
    print '11、检查逻辑卷、swap'
    if subprocess.call('vgs | grep systemvg', shell=True):
        print_res('ERROR: VG: "systemvg" check failure !!!', num, -10)
        scoreDict['score'] -= 10
    else:
        print_ok('VG: "systemvg" check OK !')
        try:
            lvSize = int(subprocess.Popen('lvs | grep vo', shell=True, stdout=subprocess.PIPE).stdout.readlines()[-1].strip().split(' ')[-1][:-1].split('.')[0])
            if (not subprocess.call('lvs | grep vo', shell=True)) and (270 < lvSize < 330):
                print_ok('LV: "vo" check OK !')
            else:
                print_res('ERROR: LV: "vo" check failure !!!', num, -10)
                scoreDict['score'] -= 10
        except IndexError:
            print_res('ERROR: LV: "vo" check failure !!!!', num, -10)
            scoreDict['score'] -= 10
    if subprocess.call('vgs | grep datastore', shell=True):
        print_res('ERROR: VG: "datastore" check failure !!!', num, -10)
        scoreDict['score'] -= 10
    else:
        print_ok('VG: "datastore" check OK !')
        try:
            peSize = subprocess.Popen('vgdisplay datastore | grep "PE Size"', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split(' ')[-2]
            peCount = subprocess.Popen('lvdisplay /dev/datastore/database  | grep "Current LE"', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split(' ')[-1].strip()

            if peSize == '16.00' and peCount == '50':
                print 'PE: "PE Size" check OK !!!              '
            else:
                print_res('ERROR: PE: "PE Size" check failure !!!', num, -10)
                scoreDict['score'] -= 10
        except IndexError:
            print_res('ERROR: LV: "database" check failure !!!!', num, -10)
            scoreDict['score'] -= 10
    return scoreDict['score']

def check_fstab():
    parting_line()
    print '12、检查开机挂载'
    voList = ['/dev/systemvg/vo', '/vo', 'ext3', 'defaults', '0', '0']
    dbList = ['/dev/datastore/database', '/mnt/database', 'ext3', 'defaults', '0', '0']
#    swList = ['swap', 'swap', 'swap', 'defaults', '0', '0']
    if not os.path.exists('/vo') :
        print_res('ERROR: Can`t find "/vo" OR "/mnt/database" !!!', num, -5)
        scoreDict['score'] -= 5
    if not os.path.exists('/mnt/database'):
        print_res('ERROR: Can`t find  "/mnt/database" !!!', num, -5)
        scoreDict['score'] -= 5
    try:
        vList = subprocess.Popen('grep "/dev/systemvg/vo" /etc/fstab', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split()
        if voList == vList:
            print_ok('Mount Point: "/vo" check OK !')
        else:
            print_res('ERROR: Mount Point: "/vo" check failure !!!', num, -10)
            scoreDict['score'] -= 10
    except IndexError:
        print_res('ERROR: Mount Point: "/vo"" check failure !!!!', num, -10)
        scoreDict['score'] -= 10
        pass
    try:
        dList = subprocess.Popen('grep "/dev/datastore/database" /etc/fstab', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split()
        if dbList == dList:

            print_ok('Mount Point: "/mnt/database" check OK !!!  ')

        else:
            print_res('ERROR: Mount Point: "/mnt/database"" check failure !!!', num, -10)
            scoreDict['score'] -= 10
    except IndexError:
        print_res('ERROR: Mount Point: "/mnt/database"" check failure !!!!', num, -10)
        scoreDict['score'] -= 10

    try:
        sList = subprocess.Popen('grep "swap" /etc/fstab', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split()

        diskDir = sList[0].split('/')[-1]
        cmds = "lsblk | grep %s | awk '{print $4}'" % diskDir

        swSize = subprocess.Popen(cmds, shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split()
#        print swSize
        if swSize[0] == '512M':
            print_ok('Mount Point: "swap" check OK !')
        else:
            print_res('ERROR: Mount Point: "swap" check failure !!!', num, -10)
            scoreDict['score'] -= 10
    except IndexError:
        print_res('ERROR: Mount Point: "swap"" check failure !!!!', num, -10)
        scoreDict['score'] -= 10

    return scoreDict['score']

def check_ntp():
    parting_line()
    print '13、检查NTP时间同步'
    try:
        serviceSt = subprocess.Popen('systemctl status chronyd | grep dead', shell=True, stdout = subprocess.PIPE).stdout.readlines()[0]
        serviceEn = subprocess.Popen('systemctl status chronyd | grep disabled', shell=True, stdout = subprocess.PIPE).stdout.readlines()[0]
    except IndexError:
        print_ok('Chronyd is active and enabled, check OK')

    else:
        print_res('ERROR: Chronyd is inactive and disabled, check failur !!!!', num, -10)
        scoreDict['score'] -= 10
    ntp_En_Syn = subprocess.Popen('timedatectl | grep NTP', shell=True, stdout=subprocess.PIPE).stdout.readlines()

    if ntp_En_Syn != ['     NTP enabled: yes\n', 'NTP synchronized: yes\n']:
        print_res('ERROR: "NTP enabled: NO"  OR  "NTP synchronized: NO"    ,check failure !!!', num, -10)
        scoreDict['score'] -= 10
    return scoreDict['score']

def check_stu_f():
    parting_line()
    print '14、检查student用户文件'
    try:
        stuID = subprocess.Popen('grep student /etc/passwd', shell=True, stdout=subprocess.PIPE).stdout.readlines()[0].split(':')[2]
        if os.path.isdir('/root/findfiles'):
            fileList = subprocess.Popen('ls -A /root/findfiles', shell=True, stdout=subprocess.PIPE).stdout.readlines()
            if fileList == []:
                print_res('ERROR: The  director "findfiles" is empty!!!', num, -10)
                scoreDict['score'] -= 10
            else:
                print_ok('The files of student is found at "/root/findfiles"')
                for i in fileList:
                    if os.stat('/root/findfiles/%s' % i.strip()).st_uid != int(stuID):
                        print_res('ERROR: Some files like "%s" is not belong to student,check failure !!!' % i.strip(),
                                  num, -10)
                        return scoreDict['score'] - 10
                else:
                    print_ok('The file of "student"  check OK')
        else:
            print_res('ERROR: Can`t find the user student OR the dir "findfiles"!!!', num, -20)
            return scoreDict['score'] - 20
    except IndexError:
        print_res('ERROR: Can`t find the user student OR the dir "findfiles"!!!!' , num, -20)
        return scoreDict['score'] - 20

    return scoreDict['score']

def check_tar():
    parting_line()
    print '15、检查Tar文件'
    fDir = '/usr/local'
    if os.path.isfile('/root/backup.tar.bz2'):
        print_ok('Found the file "/root/backup.tar.bz2"')
        if not os.system('tar jxf backup.tar.bz2 &> /dev/null'):
            fList =  subprocess.Popen('tar tf /root/backup.tar.bz2 | grep -v  ^/usr/local',shell=True, stdout=subprocess.PIPE).stdout.readlines()
            if fList:
                print_res('ERROR: Some files like "%s" is not in dir "%s" '  % (fList[0], fDir), num, -10)
                scoreDict['score'] -= 10
            else:
                print_ok('The file "/root/backup.tar.bz2" is ok')
        else:
            print_res('ERROR: Extract files failed!!! ' , num,  -20)
            scoreDict['score'] -= 20
            return scoreDict['score']
    else:
        print_res('ERROR: The file "/root/backup.tar.bz2" is not found OR is not a archive!!!' , num, -20)
        scoreDict['score'] -= 20
    return scoreDict['score']

def check_str():
    parting_line()
    print '16、检查字符串'
    if os.path.isfile('/root/wordlist'):
        print_ok('Found the file "/root/wordlist"')
        fList = subprocess.Popen(' grep seismic -v  /root/wordlist', shell=True,stdout=subprocess.PIPE).stdout.readlines()
        if fList:
            print_res('ERROR: "%s" is not include "seismic"!!! ' %(fList[0].strip()), num, -10)
            scoreDict['score'] -= 10
        else:
            wordlist = subprocess.Popen('cat /root/wordlist', shell=True, stdout=subprocess.PIPE).stdout.readlines()
            words = subprocess.Popen('cat /usr/share/dict/words', shell=True, stdout=subprocess.PIPE).stdout.readlines()
            for eachStr in wordlist:
                if eachStr not in words:
                    print_res('ERROR: Some Strings like "%s" is not in /usr/share/dict/words ' % eachStr, num, -10)
                    return (scoreDict['score'] - 10)
            else:
                print_ok('Strings check OK')
    else:
        print_res('ERROR: The file "/root/wordlist" is not found!!!', num, -20)
        scoreDict['score'] -= 20
    return scoreDict['score']


def check_auto():
    parting_line()
    print '17、检查ldap、autofs'
    if  (not os.system('rpm -q autofs')) and (not os.system('rpm -q sssd')):
        try:
            serviceSt = subprocess.Popen('systemctl status autofs | grep dead', shell=True, stdout = subprocess.PIPE).stdout.readlines()[0]
            serviceEn = subprocess.Popen('systemctl status autofs | grep disabled', shell=True, stdout = subprocess.PIPE).stdout.readlines()[0]
        except IndexError:
            print_ok('autofs is active and enabled, check OK')

        else:
            print_res('ERROR: autofs is inactive and disabled, check failure', num, -10)
            scoreDict['score'] -= 10

        try:
            serviceSt = subprocess.Popen('systemctl status sssd | grep dead', shell=True, stdout = subprocess.PIPE).stdout.readlines()[0]
            serviceEn = subprocess.Popen('systemctl status sssd | grep disabled', shell=True, stdout = subprocess.PIPE).stdout.readlines()[0]
        except IndexError:
            print_ok('sssd is active and enabled, check OK')

        else:
            print_res('ERROR: sssd is inactive and disabled, check failure', num, -10)
            scoreDict['score'] -= 10
        if not os.system('id ldapuser0') and os.path.exists('/home/guests/ldapuser0'):
            print 'ldapuser0 check Ok      '
        else:
            print_res('ERROR: ldapuser0 check  failure !!!', num, -10)
            scoreDict['score'] -= 10
    else:
        print_res('ERROR: autofs OR sssd is uninstalled', num, -10)
        scoreDict['score'] -= 40
    return scoreDict['score']
def check_all(ifCheck):
    print
    print 'CHECKING.....................................'
    scoreDict['score'] = check_hName(hostName)
    scoreDict['score'] = check_IP(hostIP, hostGW, hostDNS)
    scoreDict['score'] = check_yum()
    scoreDict['score'] = check_user(userList,ifCheck)
    scoreDict['score'] = check_LVM()
    scoreDict['score'] = check_fstab()
    scoreDict['score'] = check_kernel()
    scoreDict['score'] = check_share_dir()
    scoreDict['score'] = check_ntp()
    scoreDict['score'] = check_stu_f()
    scoreDict['score'] = check_tar()
    scoreDict['score'] = check_str()
    scoreDict['score'] = check_auto()
    print
    print 'The last score: \033[1;31;44m%s\033[0m' % scoreDict['score']


if __name__ == '__main__':
#     mess = """
# Input(1):         check_all        完整测试(测试所有项)
# Input(ENTER):     check_no_user    部分测试(不包含用户密码的验证)
# Please Input(1 or ENTER) : """
#     ifCheck = raw_input(mess)
    ifCheck = raw_input('')
    if ifCheck == '1':
        check_all(ifCheck)
    else:
        ifCheck = 0
        check_all(ifCheck)
    print
    print_ok('MORE Infomations at URL http://bj.ne.tedu.cn/ ')
    print_ok('                    URL http://bj.linux.tedu.cn/ ')
    print_ok('AUTHOR: YANGJF       ')
    print_ok('TIME  : 2017-11-25   ')
    print_ok( 'VERSION: %s' % sVersion)
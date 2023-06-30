#CPU_NUM=$(cat /proc/cpuinfo |grep "processor" | wc -l) #查看本机CPU核数
CPU_NUM=$1 #查看本机CPU核数
echo $CPU_NUM
#每有一核CPU，启动一个dd进程，共启动CPU_NUM个dd进程
for i in `seq 1 $CPU_NUM`
do
	dd if=/dev/zero of=/dev/null & 
done



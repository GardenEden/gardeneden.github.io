#!/bin/bash

# =================基本配置=================
# C: centos U: ubuntu
SYSTEM_VERSION='C'
# 需要检查的网卡
NETWORK_CARD='ens160'
# =================基本配置=================

# 将屏幕输出的文件，同时保存在文档中
# 用到知识点：文件描述符与重定向，管道
logfile=checkSystemConfig.log
fifofile=checkSystemConfig.fifo
mkfifo ${fifofile}
cat ${fifofile} | tee -a ${logfile} &
exec 1>${fifofile}
exec 2>$1
if [[ -e ${fifofile} ]]; then
    rm -rf ${fifofile}
fi

echo -e "\n----------------------------------"
DATE=`date`
echo -e "date:${DATE}"
echo -e "----------------------------------\n"

echo '=================安装所需软件================='
if [ ${SYSTEM_VERSION} == 'C' ]; then
    sudo yum install -y net-tools
elif [ ${SYSTEM_VERSION} == 'U' ]; then
    sudo apt-get install -y net-tools
fi
echo '=================安装所需软件================='
echo -e

echo '=================操作系统信息================='
echo '内核信息:'
sudo uname -a
echo -e

echo '当前用户名为:'
sudo hostname
echo -e

echo '操作系统版本:'
if [ ${SYSTEM_VERSION} == 'C' ]; then
    sudo cat /etc/redhat-release
elif [ ${SYSTEM_VERSION} == 'U' ]; then
    sudo lsb_release -d
fi
echo -e

echo '所有PCI设备:'
sudo lspci -tv
echo -e

echo '加载的内核模块:'
sudo lsmod
echo -e

echo '环境变量:'
sudo env
echo '=================操作系统信息================='
echo -e


echo '=================服务器信息================='
echo '服务器型号:'
sudo dmidecode -s system-product-name
echo -e

echo '内存插条数，已使用插槽数，及每条内存大小:'
sudo dmidecode|grep -P -A5 "Memory\s+Device" | grep Size |grep -v Range | cat -n
echo -e

echo '内存的频率:'
sudo dmidecode|grep -A16 "Memory Device"|grep 'Speed' | cat -n
echo '=================服务器信息================='
echo -e

echo '=================资源信息================='
echo '内存使用量和交换区使用量:'
sudo free -mh
echo -e

echo '各分区使用情况:'
sudo df -h
echo -e

echo '系统运行时间、用户数、负载:'
sudo uptime
echo -e

echo '系统负载:'
sudo cat /proc/loadavg
echo '=================资源信息================='
echo -e

echo '=================磁盘与分区================='
echo '挂接的分区状态:'
sudo mount | column -t
echo -e

echo '查看所有分区:'
sudo fdisk -l
echo -e

echo '所有交换分区:'
sudo swapon -s
echo -e

echo '启动时IDE设备检测状况:'
sudo dmesg | grep IDE
echo '=================磁盘与分区================='
echo -e

echo '=================CPU信息================='

echo 'CPU总核数 = 物理CPU个数 * 每颗物理CPU的核数' 
echo '总逻辑CPU数 = 物理CPU个数 * 每颗物理CPU的核数 * 超线程数'
echo 'CPU信息型号:'
sudo cat /proc/cpuinfo | grep name | cut -f2 -d:  | uniq
echo -e

echo '物理CPU个数为:'
sudo cat /proc/cpuinfo | grep physical  | sort -n | uniq | wc -l
echo -e

echo '每个物理CPU中core的个数(即核数):'
sudo cat /proc/cpuinfo  | grep physical | sort -n | uniq -c
echo -e

echo '查看逻辑CPU的个数'
sudo cat /proc/cpuinfo| grep "processor"| wc -l

echo 'CPU运行位数:'
sudo getconf LONG_BIT
echo -e

echo 'CPU的Long Mode数值。如果大于0，则支持64bit计算'
sudo cat /proc/cpuinfo | grep flags | grep 'lm' | wc -l
echo '=================CPU信息================='
echo -e

echo '=================网络信息================='
echo '所有网络接口的属性:'
sudo ifconfig
echo -e

echo '防火墙设置:'
sudo iptables -L
echo -e

echo '网卡速率信息:'
sudo ethtool ${NETWORK_CARD}
echo -e

echo '当前暴露出来的服务端口:'
sudo netstat -ntlp
echo -e

echo '路由信息:'
sudo route -n
echo '=================网络信息================='
echo -e

echo '=================用户信息================='
echo '活动用户:'
sudo w
echo -e

echo '用户登录日志:'
sudo last
echo -e

echo '系统所有用户:'
sudo cut -d: -f1 /etc/passwd
echo -e

echo '系统所有组:'
sudo cut -d: -f1 /etc/group
echo -e

echo '当前用户的计划任务:'
sudo crontab -l
echo -e

if [ ${SYSTEM_VERSION} == 'C' ]; then
    echo '所有系统服务:'
    sudo chkconfig --list
elif [ ${SYSTEM_VERSION} == 'U' ]; then
    sudo service --status-all
fi
echo '=================用户信息================='
echo -e
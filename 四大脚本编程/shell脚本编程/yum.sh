#!/bin/bash
#准备：确保光盘连接主机
#关闭防火墙
sudo systemctl stop firewalld
sudo setenforce 0
#挂载
if test ! -e /media/iso  ;then
	sudo mkdir -p /media/iso
	sudo mount /dev/sr0 /media/iso
else 

	sudo mount /dev/sr0 /media/iso
fi
#配置local文件
cd /etc/yum.repos.d/
mkdir bak
mv ./* bak

cat > local.repo <<GG
[local]
name=local
enabled=1
gpgcheck=0
baseurl=file:///media/iso
GG
cd
#清仓
yum clean all
#建仓
yum makecache
#下载软件
yum install -y gcc gcc-c++
yum install -y net-tools
yum install -y vim
yum install -y make
yum install -y psmisc
yum install -y wget


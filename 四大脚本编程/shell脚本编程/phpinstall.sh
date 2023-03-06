#!/bin/bash
# 注意事项：把源码包放在/usr/src/下，脚本文件建议放在/root/下
#源码包必须是以.tar.gz
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
#安装php
yum -y install gd libxml2-devel libjpeg-devel libpng-devel
cd  /usr/src
if test ! -e ` ls /usr/src|grep php- ` ;then 
	echo "请下载源码包到当前目录"
	exit
else 
	sudo ls /usr/src | grep php- | xargs tar xf 
	cd "`ls | grep php- |grep -v "\.tar."`"
	./configure --prefix=/usr/local/php5 --with-gd --with-zlib --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-config-file-path=/usr/local/php5 --enable-mbstring --enable-fpm --with-jpeg-dir=/usr/lib && make -j 3 && make install
fi

#安装后调整
cd "`ls | grep php- |grep -v "\.tar.gz"`"
cp php.ini-production /usr/local/php5/php.ini
ln -s /usr/local/php5/bin/* /usr/local/bin/
ln -s /usr/local/php5/sbin/* /usr/local/sbin/
cd

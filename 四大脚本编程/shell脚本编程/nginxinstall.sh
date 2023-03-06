#!/bin/bash
# 注意事项：把源码包放在/usr/src/下，脚本文件建议放在/root/下
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
# 安装nginx
sudo yum install -y gcc gcc-c++ make pcre-devel zlib-devel openssl-devel
useradd -M -s /sbin/nologin nginx
cd  /usr/src
if test ! -e ` ls /usr/src|grep nginx- ` ;then 
	echo "请下载源码包到当前目录"
	exit
else 
	sudo ls /usr/src | grep nginx- | xargs tar xf 
	cd "`ls | grep nginx- |grep -v "\.tar."`"
	./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module && make -j 2 && make install
	
fi
cd
#创建nginx快捷开启方式
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/
#检测是否配置成功
nginx -t
#开启nginx
nginx








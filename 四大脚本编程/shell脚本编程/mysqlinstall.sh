#!/bin/bash
#注意事项：首先把mysql-的源码包放在/usr/src目录下
#			创建/usr/local/boost,在此目录下放boost源码压缩包
#最后一步设置密码 ，自己弄
#关闭防火墙
sudo systemctl stop firewalld
sudo setenforce 0
# 安装mysql
sudo yum -y install ncurses-devel
sudo yum -y install cmake
sudo useradd -M -s /sbin/nologin mysql
cd  /usr/src
if test ! -e ` ls /usr/src|grep mysql- ` ;then 
	echo "请下载源码包到当前目录"
	exit
else 
	sudo ls /usr/src | grep mysql- | xargs tar xf 
	mkdir /usr/local/boost
    cd /usr/local/boost
    sudo ls | grep boot_ | xargs tar xf  
    cd /usr/src
	cd "`ls | grep mysql- |grep -v "\.tar."`"
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS=all -DSYSCONFDIR=/etc -DWITH_BOOST=/usr/local/boost && make -j 2 && make install
fi
cd
#设置权限
chown -R mysql:mysql /usr/local/mysql/
#建立配置文件
cd /etc
touch my.cnf
cat >> my.cnf <<GG
[mysqld]
datadir=/usr/local/mysql/data
socket=/tmp/mysql.sock
[mysqld_safe]
log-error=/usr/local/mysql/data/mysql.log
pid-file=/usr/local/mysql/data/mysql.pid
GG
#初始化数据库
cd /usr/local/mysql/
./bin/mysqld --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --initialize
#设置环境变量
echo "PATH=$PATH:/usr/local/mysql/bin" >> /etc/profile
source /etc/profile
#添加系统服务
cd /usr/src
cd "`ls | grep mysql- |grep -v "\.tar.gz"`"
cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
/etc/init.d/mysqld start
cd










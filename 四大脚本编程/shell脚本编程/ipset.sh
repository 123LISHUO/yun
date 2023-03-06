#!/bin/bash
#关闭防火墙
sudo systemctl stop firewalld
sudo setenforce 0
cat >  vim /etc/sysconfig/network-scripts/ifcfg-ens33 <<GG
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
UUID=61ab961f-3611-4f91-8358-cbaf727bc99b
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.100.126
NETMASK=255.255.255.0
GATEWAY=192.168.100.2
DNS1=114.114.114.114
GG
#重启网卡
nmcli connection reload ens33
nmcli connection up ens33


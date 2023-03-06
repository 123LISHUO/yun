#!/bin/bash
#配置nginx支持PHP环境
cd /usr/local/php5/etc/
cp php-fpm.conf.default php-fpm.conf
useradd -M -s /sbin/nologin php
vim php-fpm.conf
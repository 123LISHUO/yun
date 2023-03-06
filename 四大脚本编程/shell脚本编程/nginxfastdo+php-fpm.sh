#!/bin/bash
# chkconfig: 2345 99 20
# description: Nginx Server Control Script
PROG="/usr/local/nginx/sbin/nginx"
PIDF="/usr/local/nginx/logs/nginx.pid" 
PROG_FPM="/usr/local/sbin/php-fpm" 
PIDF_FPM="/usr/local/php5/var/run/php-fpm.pid"

case "$1" in
start)
    $PROG
    $PROG_FPM
;;
stop)
    kill -s QUIT $(cat $PIDF)
    kill -s QUIT $(cat $PIDF_FPM)
;;
restart)
    $0 stop
    $0 start
;;
reload)
    kill -s HUP $(cat $PIDF)
;;
*)
    echo "Usage: $0 (start|stop|restart|reload)" 
    exit 1
esac
exit 0
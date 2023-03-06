#!/bin/bash
# chkconfig: 2345 99 20
# description: Nginx Server Control Script
PROG="/usr/local/nginx/sbin/nginx" 
PIDF="/usr/local/nginx/logs/nginx.pid"


case "$1" in
start)
    $PROG
;;
stop)
    kill -s QUIT $(cat $PIDF)
;;
restart)
    $0 stop
    $0 start
;;
reload)
    kill -s HUP $(cat $PIDF)
;;
*)
    echo "Usage: $0 {start|stop|restart|reload}" 
    exit 1
esac
exit 0

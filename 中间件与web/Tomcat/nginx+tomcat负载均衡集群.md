## :cat2:
$$需要两个server和一个client$$

$server：nginx+Tomcat$
$client：nginx$

![](../实验/image/2022-11-20-23-15-47.png)
## server (查看自定义网站目录文档)
    vim /web/webapp/index.jsp
#### server1
![](../实验/image/2022-11-20-23-20-54.png)
#### server2
![](../实验/image/2022-11-20-23-21-14.png)
## client
1、部署nginx

    查看部署nginx文档
2、配置nginx.conf文件

    备份：
    cp /usr/local/nginx/conf/nginx.conf{,.bak}
>
    #vim /usr/local/nginx/conf/nginx.conf

    user  nginx nginx;
    worker_processes  2;

    error_log  logs/error.log;
    #error_log  logs/error.log  notice;
    #error_log  logs/error.log  info;

    pid        logs/nginx.pid;

    events {
        use  epoll;#使用
        worker_connections  1024;
    }

    http {
        include       mime.types;
        default_type  application/octet-stream;

        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log  logs/access.log  main;

        sendfile        on;
        #tcp_nopush     on;

        #keepalive_timeout  0;
        keepalive_timeout  65;

        
        upstream tomcat {#配置负载均衡（加权轮询）
        server 192.168.100.123:8000 weight=1;
        server 192.168.100.125:8000 weight=1;
        }

        server {
                listen       80;
                server_name  localhost;

                #charset koi8-r;

                #access_log  logs/host.access.log  main;

                location / {
                    root   html;
                    index  index.html index.htm;
                }
                # 定位
                location ~ \.jsp$ {
                proxy_pass http://tomcat;
        }

3、检查

    nginx -t
4、启动nginx

    nginx
5、确保server的Tomcat和nginx开启，防火墙关闭，selinux关闭
6、测试
访问index.jsp
![](../实验/image/2022-11-20-23-43-36.png)
刷新，nginx反向代理，分配服务器，server1和server2权重一样
![](../实验/image/2022-11-20-23-44-15.png)

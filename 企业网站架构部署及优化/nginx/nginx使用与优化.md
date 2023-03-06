# nginx使用与优化
## nginx.conf 文件结构
```nginx
...              #全局块

events {         #events块
   ...
}

http      #http块
{
    ...   #http全局块
    server        #server块
    { 
        ...       #server全局块
        location [PATTERN]   #location块
        {
            ...
        }
        location [PATTERN] 
        {
            ...
        }
    }
    server
    {
      ...
    }
    ...     #http全局块
}
```

- 1、全局块：配置影响nginx全局的指令。一般有运行nginx服务器的用户组，nginx进程pid存放路径，日志存放路径，配置文件引入，允许生成worker process数等。
  
- 2、events块：配置影响nginx服务器或与用户的网络连接。有每个进程的最大连接数，选取哪种事件驱动模型处理连接请求，是否允许同时接受多个网路连接，开启多个网络连接序列化等。

- 3、http块：可以嵌套多个server，配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置。如文件引入，mime-type定义，日志自定义，是否使用sendfile传输文件，连接超时时间，单连接请求数等。

- 4、server块：配置虚拟主机的相关参数，一个http中可以有多个server。
  
- 5、location块：配置请求的路由，以及各种页面的处理情况。 
---
在 Nginx 服务器的主配置文件 nginx.conf 中，包括==全局配置、I/O 事件配置、HTTP 配置==

这三大块内容，配置语句的格式为"==关键字 值==；"(末尾以分号表示结束)，以"#"开始的部分表示注释。

1）全局配置

    由各种配置语句组成，不使用特定的界定标记。全局配置部分包括运行用户、工作进程数、错误日志、PID 存放位置等基本设置。

    常用配置项：
        user nginx [nginx]; //运行用户，Nginx 的运行用户实际是编译时指定的 nginx，若编译时未指定则默认为 nobody。

        worker_processes 2; //指定 nginx 启动的工作进程数量，建议按照 cpu 数目来指定，一般和 CPU 核心数相等。

        worker_cpu_affinity 00000001 00000010; //为每个进程分配 cpu 核心，上例中将 2 个进程分配到两个 cpu，当然可以写多个，或者将一个进程分配到多个 cpu

        worker_rlimit_nofile 102400; //这个指令是指当一个 nginx 进程打开的最多文件数目，理论值应该是最多打开文件数（ulimit -n）与 nginx 进程数相除，但是 nginx 分配请求并不是那么均匀，所以最好与 ulimit -n 的值保持一致。(通过"ulimit –n 数值"可以修改打开的最多文件数目)

        error_log logs/error.log; //全局错误日志文件的位置

        pid logs/nginx.pid; //PID 文件的位置

2）I/O 事件配置：

    使用"events {}"界定标记，用来指定 Nginx 进程的 I/O 响应模型，每个进程的连接数等设置

    events {
        use epoll; //使用 epoll 模型，对于 2.6 以上的内核，建议使用 epoll 模型以提高性能

        worker_connections 4096; //每个进程允许的最多连接数(默认为 1024)，每个进程的连接数应根据实际需要来定，一般在 10000 以下，理论上每台 nginx 服务器的最大连接数为 worker_processes*worker_connections，具体还要看服务器的硬件、带宽等。
        }

3）HTTP 配置

    使用"http{}"界定标记，包括访问日志、HTTP 端口、网页目录、默认字符集、连接保持、以及虚拟主机、PHP 解析等一系列设置。其中大部分配置语句包含在子界定标记"server {}"内。

    http {
        include mime.types;

        default_type application/octet-stream;

        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

        access_log logs/access.log main; //访问日志位

        sendfile on; //支持文件发送（下载）

        keepalive_timeout 65; //连接保持超时

        server { //web 服务的监听配置

            listen 80; //监听地址及端口（IP：PORT）

            server_name www.crushlinux.com; //网站名称（FQDN）

            charset utf-8; //网页的默认字符集

            location / { //跟目录配置

                root html; //网站根目录的位置安装位置的 html 中
                index index.html index.htm; //默认首页（索引页）

                             }
            error_page 500 502 503 504 /50x.html; //内部错误的反馈页面
            location = /50x.html { //错误页面配置
            root html;
                            }
                        }
                    }

#### 举例1
```nginx
    ########### 每个指令必须有分号结束。#################
    #user administrator administrators;  #配置用户或者组，默认为nobody nobody。
    #worker_processes 2;  #允许生成的进程数，默认为1
    #pid /nginx/pid/nginx.pid;   #指定nginx进程运行文件存放地址
    error_log log/error.log debug;  #制定日志路径，级别。这个设置可以放入全局块，http块，server块，级别以此为：debug|info|notice|warn|error|crit|alert|emerg
    events {
        accept_mutex on;   #设置网路连接序列化，防止惊群现象发生，默认为on
        multi_accept on;  #设置一个进程是否同时接受多个网络连接，默认为off
        #use epoll;      #事件驱动模型，select|poll|kqueue|epoll|resig|/dev/poll|eventport
        worker_connections  1024;    #最大连接数，默认为512
    }
    http {
        include       mime.types;   #文件扩展名与文件类型映射表
        default_type  application/octet-stream; #默认文件类型，默认为text/plain
        #access_log off; #取消服务日志    
        log_format myFormat '$remote_addr–$remote_user [$time_local] $request $status $body_bytes_sent $http_referer $http_user_agent $http_x_forwarded_for'; #自定义格式
        access_log log/access.log myFormat;  #combined为日志格式的默认值
        sendfile on;   #允许sendfile方式传输文件，默认为off，可以在http块，server块，location块。
        sendfile_max_chunk 100k;  #每个进程每次调用传输数量不能大于设定的值，默认为0，即不设上限。
        keepalive_timeout 65;  #连接超时时间，默认为75s，可以在http，server，location块。

        upstream mysvr {   
        server 127.0.0.1:7878;
        server 192.168.10.121:3333 backup;  #热备
        }
        error_page 404 https://www.baidu.com; #错误页
        server {
            keepalive_requests 120; #单连接请求上限次数。
            listen       4545;   #监听端口
            server_name  127.0.0.1;   #监听地址       
            location  ~*^.+$ {       #请求的url过滤，正则匹配，~为区分大小写，~*为不区分大小写。
            #root path;  #根目录
            #index vv.txt;  #设置默认页
            proxy_pass  http://mysvr;  #请求转向mysvr 定义的服务器列表
            deny 127.0.0.1;  #拒绝的ip
            allow 172.18.5.54; #允许的ip           
            } 
        }
    }
```

#### 注意：
1、几个常见配置项：
```c
    1.$remote_addr 与 $http_x_forwarded_for 用以记录客户端的ip地址；
    2.$remote_user ：用来记录客户端用户名称；
    3.$time_local ： 用来记录访问时间与时区；
    4.$request ： 用来记录请求的url与http协议；
    5.$status ： 用来记录请求状态；成功是200；
    6.$body_bytes_s ent ：记录发送给客户端文件主体内容大小；
    7.$http_referer ：用来记录从那个页面链接访问过来的；
    8.$http_user_agent ：记录客户端浏览器的相关信息；
```
2、惊群现象：一个网路连接到来，多个睡眠的进程被同时叫醒，但只有一个进程能获得链接，这样会影响系统性能。

3、每个指令必须有分号结束。

#### 参考文献
[配置  参考文献](https://www.runoob.com/w3cnote/nginx-setup-intro.html)

## 虚拟主机应用
虚拟主机分类：

    基于域名：多个域名解析为一个 IP 地址，不同域名访问到不同网站内容。
    http://www.a.com http://www.b.com

    基于 IP 地址：服务器拥有多个 IP 地址，不同 IP 访问到不同网站内容。
    http://192.168.1.1 http://192.168.1.2

    基于端口：相同 IP 地址的不同端口访问到不同网站内容。
    http://192.168.1.1:80 http://192.168.1.1:81

使用 Nginx 搭建虚拟主机服务器时，每个虚拟 WEB 站点拥有独立的"server {}"配置段，各自监听的 IP 地址、端口号可以单独指定，当然网站名称也是不同的。

例如：要创建两个站点 www.crushlinux.com 和 www.cloud.com为两个虚拟 WEB 主机分别建立根目录，并准备测试首页

    [root@nginx ~]# mkdir /usr/local/nginx/html/crushlinux
    [root@nginx ~]# mkdir /usr/local/nginx/html/cloud
    [root@nginx ~]# echo "<h1>www.crushlinux.com</h1>" >
    /usr/local/nginx/html/crushlinux/index.html
    [root@nginx ~]# echo "<h1>www.cloud.com</h1>" > /usr/local/nginx/html/cloud/index.html

    [root@nginx ~]# vim /usr/local/nginx/conf/nginx.conf
    http {
        include mime.types;
        default_type application/octet-stream;
        log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';
        access_log logs/access.log main;
        sendfile on;
        keepalive_timeout 65;
        server {
                listen 80;
                server_name www.crushlinux.com;
                charset utf-8;
                access_log logs/crushlinux.access.log main;
             location / {
                root html/crushlinux;
                index index.html index.htm;
                    }
                }
        server {
            listen 80;
            server_name www.cloud.com;
            charset utf-8;
            access_log logs/cloud.access.log main;

            location / {
                root html/cloud;
                index index.html index.htm;
                            }
                        }
                    }

    [root@nginx ~]# systemctl restart nginx
    [root@nginx ~]# vim /etc/hosts
    192.168.200.111 www.crushlinux.com
    192.168.200.111 www.cloud.com

    虚拟主机访问测试
    [root@nginx ~]# elinks --dump http://www.crushlinux.com
    www.crushlinux.com
    [root@nginx ~]# elinks --dump http://www.cloud.com
    www.cloud.com


## 优化


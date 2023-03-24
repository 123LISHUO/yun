# 配置 Nginx 隐藏版本号
$在生产环境中，需要隐藏 Nginx 等服务的版本信息，以避免安全风险$
```[root@124 conf]# curl -I www.baidu.com //获取网站信息```

    HTTP/1.1 200 OK
    Accept-Ranges: bytes
    Cache-Control: private, no-cache, no-store, proxy-revalidate, no-transform
    Connection: keep-alive
    Content-Length: 277
    Content-Type: text/html
    Date: Wed, 16 Nov 2022 15:23:19 GMT
    Etag: "575e1f60-115"
    Last-Modified: Mon, 13 Jun 2016 02:50:08 GMT
    Pragma: no-cache
    Server: bfe/1.0.8.18   //名字、版本号

#### way1——修改源码包
$修改/nginx-1.14.2/src/core/nginx.h文件$

    tar操作

    [root@localhost ~]# cd /usr/src/nginx-1.14.2/
    [root@localhost nginx-1.14.2]# vim src/core/nginx.h
    行号
     13 #define NGINX_VERSION "7.0.0 " 
     14 #define NGINX_VER "IIS/" NGINX_VERSION
    （“#”号留着，这里“#”不是注释）
    ./configure操作

#### way2——修改配置文件
$配置nginx.conf 文件$

    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
        行号
         20 server_tokens off;

    #nginx -t
    #killall -HUP nginx
>
    如果 php 配置文件中配置了 fastcgi_param SERVER_SOFTWARE 选项，则编辑 php-fpm 配置文件，将 fastcgi_param SERVER_SOFTWARE 对应值修改为fastcgi_param SERVER_SOFTWARE nginx;

# 修改nginx用户与组
$Nginx 运行时进程需要有用户与组身份的支持，以实现对网站文件读取时进行访问控制。$
$Nginx 默认使用 nobody 用户账号与组账号，一般也要进行修改。$
#### way1 编译安装时指定（使用这种方式，尽可能在编译时进行配置，不然显得技术菜）

    useradd -M -s/sbin/nologin nginx
    ./configure --user=nginx

#### way2 修改配置文件
$vim \ nginx.conf$

    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    行号
     2 user nginx nginx;

# 配置 Nginx 网页缓存时间
$问题:$

    当 Nginx 将网页数据返回给客户端后，可设置资源在客户端缓存的时间，
    以方便客户端在日后进行相同内容的请求时直接返回，以避免重复请求，加快了访问速度，
    一般针对静态网页进行设置，对动态网页不用设置缓存时间。
    可在 Windows 客户端中使用 fiddler 查看网页缓存时间。
$绝大部分缓存的都是静态资源$
$设置方法：可修改配置文件，在 http 段、或 server 段、或者 location 段加入对特定内容的过期参数。$

    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    行号
    49      location ~ \.(gif|jpg|jpeg|png|bmp|ico)$ {
    50                  expires 1d; #缓存时间为one day
    51      }
    52      location ~ .*\.(js|css)$ {
    53                  expires 1h;#缓存时间为one hour
    54      }

    #killall -HUP nginx
    
    # vim /usr/local/nginx/html/index.html（把这里面的html文件直接.bak
    行号
    15 <hr />
    16 <img src="linux.png" />

$浏览器已经缓存时间，只要你在缓存时间里，没有再次访问，过了访问时间，浏览器就会删除照片$

# ==实现 Nginx 的日志切割==
$nginx日志$

    [root@localhost ~]# ls -l /usr/local/nginx/logs/
    总用量 12
    -rw-r--r-- 1 root root 3584 3 月 31 10:02 access.log #访问日志
    -rw-r--r-- 1 root root 1575 3 月 31 10:02 error.log #错误日志
    -rw-r--r-- 1 root root 5 3 月 31 09:27 nginx.pid
$编写日志切割脚本$

    [root@localhost ~]# vim /opt/cut_nginx_log.sh
    #!/bin/bash
    # cut_nginx_log.sh
    datetime=$(date -d "-1 day" "+%Y%m%d")
    log_path="/usr/local/nginx/logs" pid_path="/usr/local/nginx/logs/nginx.pid"
    [ -d $log_path/backup ] || mkdir -p $log_path/backup
    if [ -f $pid_path ]
    then
    mv $log_path/access.log $log_path/backup/access.log-$datetime
    kill -USR1 $(cat $pid_path) //通过 pid 重新生成一份日志
    find $log_path/backup -mtime +30 | xargs rm -f
    else
    echo "Error,Nginx is not working!" | tee -a /var/log/messages
    fi
    [root@localhost ~]# chmod +x /opt/cut_nginx_log.sh
    [root@localhost ~]# crontab -e
    0 0 * * * /opt/cut_nginx_log.sh
    [root@localhost ~]# /opt/cut_nginx_log.sh
    [root@localhost ~]# ls /usr/local/nginx/logs/backup/
    access.log-20161117
    [root@localhost ~]# killall -9 nginx
    [root@localhost ~]# rm -rf /usr/local/nginx/logs/nginx.pid
    [root@localhost ~]# /opt/cut_nginx_log.sh
    Error,Nginx is not working!
    [root@localhost ~]# tail -1 /var/log/messages
    Error,Nginx is not working!
$面试题讨论$

说明 Nginx 的访问日志记录在 access.log 文件中。
1、 如果将 access.log 重命名为 a.log 时，新产生的日志写到哪儿？为什么？

答案：日志将会写入到 a.log 文件中，因为重命名后文件的 Inode 没有变化，文件系统是根据 Inode 查找文件的。

2、 如果此时将 Nginx 服务重启后，新产生的日志写到哪儿？为什么？

答案：日志将会写入到新的 access.log 文件中，因为重启时会加载 Nginx 的配置文件，配置文件中是通过文件名指定日志的，所以会创建新的日志。
# 配置 Nginx 实现连接超时
$保持连接（长连接）是在tcp,http连接建立之后，在一定时间段内，是不会断开连接的\\
一般访问一个资源:在进行 HTTP 连接前要先建立 TCP 连接（TCP 3 次握手），再建立 HTTP 连接，\\当 HTTP 资源请求结束后，会断开 HTTP 连接，再断开 TCP 连接（TCP 4 次挥手）。$

    问题1
    很多情况下用户访问网站并不是只访问一个资源，可能会打开很多页面，访问很多资源，
    如果每个资源的访问都这么繁琐，将会造成用户访问慢，服务器压力过大的问题。

    解决如上问题的最好办法是开启网站的保持连接功能。

    问题2
    在企业网站中，为了避免同一个客户长时间占用连接，造成服务器资源浪费。

    可以设置相应的连接超时参数，实现控制连接访问时间。

- keepalived_timeout：设置连接保持超时时间，一般可只设置该参数，默认为 65 秒，可根据网站的情况设置，或者关闭，可在 http 段、server 段、或者 location 段设置。
- client_header_timeout：指定等待客户端发送请求头的超时时间。
- client_body_timeout：设置请求体读取超时时间。

$注意：若出现超时，会返回 408 报错$

    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    行数
    34 keepalive_timeout 65;
    35 client_header_timeout 60;
    36 client_body_timeout 60;
    [root@localhost ~]# killall -HUP nginx
# ==更改 Nginx 工作进程数==
$问题:$

    在高并发场景，需要启动更多的 nginx 工作进程以保证快速影响，以处理用户的请求，避免造成阻塞。

```修改配置文件的 worker_processes 参数，一般设置为 CPU 的核数```

    # grep 'core id' /proc/cpuinfo | uniq | wc -l(除了top查看cpu状态，一定要会)
    2
>
    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    行号
    3 worker_processes 2;
    （当你的进程数设置成与服务器的CPU数一样时，好比四个，
    那么一个内核对应一个进程，这样对于nginx服务的运行来说，
    还是本身服务器本身的CPU的运行来说都是一个很舒服的状态，
    因为指定性的工作最好干，这样服务器和nginx的服务效率和工作压力都会减轻很多。）
>
    [root@localhost ~]# /usr/local/nginx/sbin/nginx
    [root@localhost ~]# ps aux | grep nginx | grep -v grep
    root 4431 0.0 0.2 45040 1160 ? Ss 00:50 0:00 nginx: master
    process /usr/local/nginx/sbin/nginx
    nginx 4432 0.0 0.3 45492 1844 ? S 00:50 0:00 nginx: worker
    process
    nginx 4433 0.0 0.3 45492 1756 ? S 00:50 0:00 nginx: worker
    process

$配置 CPU 亲和性：$
默认 Nginx 的多个进程可能跑在一颗 CPU 核心上，可以分配不同的进程给不同的 CPU核心处理，充分利用硬件多核多 CPU。在一台 4 核物理服务器，可以进行下面的配置，将进程进行分配。
```worker_cpu_affinity 0001 0010 0100 1000;#1一直往前推```

如果不做亲和性指认的话，可能开得16个进程都会跑到一个CPU内核上去，负载会很高，有可能会导致服务器崩溃。
# 配置 Nginx 实现网页压缩功能
**Nginx的 ngx_http_gzip_module 压缩模块**
提供了对文件内容压缩的功能，允许 nginx 服务器将输出内容发送到客户端之前进行压缩，以==节约网站带宽==，提升用户的访问体验，模块默认已经安装。

    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    行号
    38 gzip on; //开启 gzip 压缩输出

    39 gzip_min_length 1k; //用于设置允许压缩的页面最小字节数

    40 gzip_buffers 4 16k; //表示申请 4个单位为16k的内存作为压缩结果流缓存，默认值是申请与原始数据大小相同的内存空间来储存 gzip 压缩结果

    41 gzip_http_version 1.1; //设置识别 http 协议版本，默认是 1.1

    42 gzip_comp_level 2; //gzip 压缩比，1-9 等级，级别越高，压缩倍率越大，时间消耗可能呈指数级增加。所以一般为2,3级

    43 gzip_types text/plain text/javascript application/x-javascript text/css text/xml
    application/xml application/xml+rss; //压缩类型，是就对哪些网页文档启用压缩功能

    44 #gzip_vary on; //选项可以让前端的缓存服务器经过 gzip 压缩的页面

    [root@localhost ~]# killall -HUP nginx


# 对 FPM 模块进行参数优化
```Nginx 的 PHP 解析功能实现如果是交由 FPM（fastcgi 进程管理器）处理的，为了提高PHP 的处理速度，可对 FPM 模块进行参数跳转。```
$FPM 优化参数$：
|代码|注释|
|:---|---|
pm |使用哪种方式启动 fpm 进程，可以说 static 和 dynamic，前者将产生固定数量的 fpm 进程，后者将以动态的方式产生 fpm 进程
pm.max_children static| 方式下开启的 fpm 进程数
pm.start_servers |动态方式下初始的 fpm 进程数量
pm.min_spare_servers| 动态方式下最小的 fpm 空闲进程数
pm.max_spare_servers |动态方式下最大的 fpm 空闲进程数

注：以上调整要根据服务器的内存与服务器负载进行调整

$示例$：
    服务器为云服务器，运行了个人论坛，内存为 1.5G，fpm 进程数为 20，内存消耗近 1G，处理比较慢

$优化参数调整$：

    # vim /usr/local/php5/etc/php-fpm.conf

    pm = dynamic
    pm.start_servers = 5
    pm.min_spare_servers = 2
    pm.max_spare_servers = 8

# Nginx 为目录添加访问控制
$用户访问控制：使用 apache 的 htpasswd 命令来创建密码文件$

    [root@localhost ~]# yum -y install httpd-tools
    [root@localhost ~]# htpasswd -c /usr/local/nginx/.htpasswd crushlinux
    New password:
    Re-type new password:
    Adding password for user crushlinux
    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    location ~ /status {
    stub_status on;
    access_log off;
    auth_basic "Nginx Status";
    auth_basic_user_file /usr/local/nginx/.htpasswd;
    }

$客户端地址访问控制:$

    [root@localhost ~]# vim /usr/local/nginx/conf/nginx.conf
    location ~ /status {
    stub_status on;
    access_log off;
    auth_basic "Nginx Status";
    auth_basic_user_file /usr/local/nginx/.htpasswd;
    allow 192.168.200.2;
    deny 192.168.200.0/24;
    }

# 自定义错误页面
    error_page 403 404 /404.html;
    location = /404.html {
    root html;
    }
    [root@localhost html]# echo "Sorry,Page Not Found" > /usr/local/nginx/html/404.html
    [root@localhost html]# service nginx reload
    浏览器访问 http://192.168.200.101/abc
    返回结果： Sorry,Page Not Found

# 自动索引
    location /download {
    autoindex on;
    }
    [root@localhost ~]# cd /usr/local/nginx/html/
    [root@localhost html]# mkdir download/dir{1,2} -p
    [root@localhost html]# touch download/1.txt
    [root@localhost html]# touch download/2.txt
    [root@localhost html]# service nginx reload
    浏览器访问 http://192.168.200.101/download

# 目录别名功能：
    location /abc {
    alias /html;
    index index.html;
    }
    [root@localhost ~]# mkdir /html
    [root@localhost ~]# echo “alias test” > /html/index.html

在浏览器中 http://192.168.200.101/abc 进行测试

# 通过 UA 实现手机端和电脑端的分离
```实现 nginx 区分 pc 和手机访问不同的网站，是物理上完全隔离的两套网站(一套移动端、一套 pc 端),这样带来的好处 pc 端和移动端的内容可以不一样，移动版网站不需要包含特别多的内容，只要包含必要的文字和较小的图片，这样会更节省流量。有好处当然也就会增加困难，难题就是你需要维护两套环境，并且需要自动识别出来用户的物理设备并跳转到相应的网站，当判断错误时用户可以自己手动切换回正确的网站。```

$有 两 套 网 站 代 码 ，\\ 一 套 PC 版 放 在 /usr/local/nginx/html/web ，\\ 一 套 移 动 版 放 在/usr/local/nginx/html/mobile。$
$只需要修改 nginx 的配置文件，\\ nginx 通过 UA 来判断是否来自移动端访问，\\ 实现不同的客户端访问不同内容。$

    location / {
    #默认 PC 端访问内容
    root /usr/local/nginx/html/web;

    #如果是手机移动端访问内容
    if ( $http_user_agent ~
    "(MIDP)|(WAP)|(UP.Browser)|(Smartphone)|(Obigo)|(Mobile)|(AU.Browser)|(wxd.Mms)|(Wx
    dB.Browser)|(CLDC)|(UP.Link)|(KM.Browser)|(UCWEB)|(SEMC-Browser)|(Mini)|(Symbian)|(P
    alm)|(Nokia)|(Panasonic)|(MOT-)|(SonyEricsson)|(NEC-)|(Alcatel)|(Ericsson)|(BENQ)|(BenQ)|
    (Amoisonic)|(Amoi-)|(Capitel)|(PHILIPS)|(SAMSUNG)|(Lenovo)|(Mitsu)|(Motorola)|(SHARP)|(
    WAPPER)|(LG-)|(LG/)|(EG900)|(CECT)|(Compal)|(kejian)|(Bird)|(BIRD)|(G900/V1.0)|(Arima)|(
    CTL)|(TDG)|(Daxian)|(DAXIAN)|(DBTEL)|(Eastcom)|(EASTCOM)|(PANTECH)|(Dopod)|(Haier)|(
    HAIER)|(KONKA)|(KEJIAN)|(LENOVO)|(Soutec)|(SOUTEC)|(SAGEM)|(SEC-)|(SED-)|(EMOL-)|(IN
    NO55)|(ZTE)|(iPhone)|(Android)|(Windows CE)|(Wget)|(Java)|(curl)|(Opera)" )
    {
        root /usr/local/nginx/html/mobile;
    }
    
        index index.html index.htm;
    }
$实验模拟：不同浏览器访问到不同的页面:$

    [root@localhost html]# mkdir firefox msie
    [root@localhost html]# echo "hello,firefox" > firefox/index.html
    [root@localhost html]# echo "hello,msie" > msie/index.html
    location / {
    if ($http_user_agent ~ Firefox) {
    root /usr/local/nginx/html/firefox;
    }
    if ($http_user_agent ~ MSIE) {
    root /usr/local/nginx/html/msie;
    }
    index index.html index.htm;
    }
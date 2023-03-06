# nginx 平滑升级版本
#### nginx 平滑升级概述
$说白了，就是让软件不停止服务的条件下，对软件进行升级版本$

    生产环境中软件版本升级必然的，但是线上业务不能停，
    此时 nginx 的升级就是运维的重要工作了。

#### nginx 平滑升级原理
$多进程模式下的请求分配方式$
```Nginx 默认工作在多进程模式下，即主进程（master process）启动后完成配置加载和端口绑定等动作，fork 出指定数量的工作进程（worker process），这些子进程会持有监听端口的文件描述符（fd），并通过在该描述符上添加监听事件来接受连接（accept）。```

$信号的接收和处理$
```Nginx 主进程在启动完成后会进入等待状态，负责响应各类系统消息，如 SIGCHLD、SIGHUP、SIGUSR2 等。```

$Nginx 信号简介$
主进程支持的信号:
|命令|解释|
|:---|:---:|
TERM, INT:| 立刻退出
QUIT: |等待工作进程结束后再退出
KILL: |强制终止进程
HUP: |重新加载配置文件，使用新的配置启动工作进程，并逐步关闭旧进程。
USR1: |重新打开日志文件
USR2: |启动新的主进程，实现热升级
WINCH: |逐步关闭工作进程

工作进程支持的信号:
|命令|解释|
|:---|:---:|
TERM, INT:| 立刻退出
QUIT:| 等待请求处理结束后再退出
USR1: |重新打开日志文件

#### nginx 平滑升级实战
1.查看旧版 nginx 的编译参数:
```/usr/local/nginx/sbin/nginx -V``` 

2.编译新版本 Nginx 源码包，安装路径需与旧版一致，==注意：不要执行 make install==

    #tar xf ...
    #cd
    #./configure...&&make

3.备份二进制文件，用新版本的替换

    [root@localhost nginx-1.15.9]# mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx.old

    [root@localhost nginx-1.15.9]# ls
    auto CHANGES.ru configure html Makefile objs src
    CHANGES conf contrib LICENSE man README

    [root@localhost nginx-1.15.9]# cp objs/nginx /usr/local/nginx/sbin/

4.确保配置文件无报错
```#nginx -t```

5.发送 USR2 信号
```向主进程（master）发送 USR2 信号，Nginx 会启动一个新版本的 master 进程和对应工作进程，和旧版一起处理请求.```

    [root@localhost ~]# ps aux | grep nginx | grep -v grep
    root 4108 0.0 0.2 45028 1152 ? Ss 16:58 0:00 nginx: master process /usr/local/nginx/sbin/nginx
    nginx 4109 0.0 0.4 45456 2012 ? S 16:58 0:00 nginx: worker process

    [root@localhost ~]# kill -USR2 4108

    [root@localhost ~]# ps aux | grep nginx | grep -v grep
    root 4108 0.0 0.2 45028 1316 ? Ss 16:58 0:00 nginx: master process /usr/local/nginx/sbin/nginx
    nginx 4109 0.0 0.4 45456 2012 ? S 16:58 0:00 nginx: worker process
    root 6605 0.5 0.6 45196 3364 ? S 17:02 0:00 nginx: master process /usr/local/nginx/sbin/nginx
    nginx 6607 0.0 0.3 45624 1756 ? S 17:02 0:00 nginx: worker process

6.发送 WINCH 信号
```向旧的 Nginx 主进程（master）发送 WINCH 信号，它会逐步关闭自己的工作进程（主进程不退出），这时所有请求都会由新版 Nginx 处理```

    [root@localhost ~]# kill -WINCH 4108

    [root@localhost ~]# ps aux | grep nginx | grep -v grep
    root 4108 0.0 0.2 45028 1320 ? Ss 16:58 0:00 nginx: master process /usr/local/nginx/sbin/nginx
    root 6605 0.0 0.6 45196 3364 ? S 17:02 0:00 nginx: master process /usr/local/nginx/sbin/nginx
    nginx 6607 0.0 0.3 45624 1756 ? S 17:02 0:00 nginx: worker process

$注意：回滚步骤，发送 HUP 信号如果这时需要回退继续使用旧版本，\\可向旧的 Nginx 主进程发送 HUP 信号，它会重新启动工作进程， 仍使用旧版配置文件。\\然后可以将新版 Nginx 进程杀死（使用 QUIT、TERM、或者 KILL）$

    # kill -HUP 4108
7.发送 QUIT 信号
```升级完毕，可向旧的 Nginx 主进程（master）发送（QUIT、TERM、或者 KILL）信号，使旧的主进程退出```

    [root@localhost ~]# kill -QUIT 4108

    [root@localhost ~]# ps aux | grep nginx | grep -v grep
    root 6605 0.0 0.6 45196 3364 ? S 17:02 0:00 nginx: master process /usr/local/nginx/sbin/nginx
    nginx 6607 0.0 0.4 45624 2056 ? S 17:02 0:00 nginx: worker process

8.验证 nginx 版本号，并访问测试
    
    [root@localhost nginx-1.15.9]# /usr/local/nginx/sbin/nginx -v
    nginx version: nginx/1.15.9
🐷**运行centos实例，进入centos后，无法yum安装。**

```md
    添加端口：-p...
```

---

🐱**在docker的centos实例中创建nginx，但是端口-p 为50001:22，nginx启动后无法打开这个页面。**

```md
把centos创建为一个新镜像，centos:nginx,然后再创建实例，然后指定-p 8081:80端口后，即可打开nginx访问页面。
CONTAINER ID   IMAGE             COMMAND       CREATED          STATUS          PORTS                                           NAMES
ee64636e5cdb   realserver1       "/bin/bash"   5 minutes ago    Up 5 minutes    22/tcp, 0.0.0.0:8081->80/tcp, :::8081->80/tcp   realserver3
```

- [参考文档](https://blog.csdn.net/weixin_53466908/article/details/123754732?)

🐱**关于docker容器的端口号修改**

```md
Tips:使用vim编辑是如果没有格式化的话，可读性会非常差，命令模式下使用 :%!python -m json.tool 格式化json文档会非常舒服

vim hostconfig.json
"PortBindings": {
        "80/tcp": [
            {
                "HostIp": "",
                "HostPort": "8081"
            }
        ]
    },
#按照格式进行修改，80/tcp是容器内端口，hostport是主机的端口。例子对应的端口为：-p 8081:80

vim config.v2.json
"ExposedPorts": {
            "22/tcp": {},
            "80/tcp": {}
        },
修改举例：
"ExposedPorts":{"80/tcp":{},"3306/tcp":{}，"XXXX/tcp":{}}  #注：这里写的都是容器内的端口
```

- [参考文档一](https://www.likecs.com/show-307526880.html#sc=374)
- [参考文档二](https://blog.csdn.net/weixin_43865008/article/details/122111611?)
- [参考文档三](https://blog.csdn.net/weixin_46152207/article/details/113684674?)

---

🦋**在进行docker run --privileged=TRUE的时候，会报错**

```md
改为：docker run --privileged  --name=...
```

- [参考文档](https://blog.csdn.net/halcyonbaby/article/details/43499409)

---

🐦**docker启动容器出现故障**

```md
Error response from daemon: driver failed programming external connectivity on endpoint realserver1 (1c192ad75c52464cb0d869786a1d5e1daa6d7bc741ecaa23bf44e6e9e519afc6):  (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 8081 -j DNAT --to-destination 172.17.0.2:80 ! -i docker0: iptables: No chain/target/match by that name.
 (exit status 1))
Error: failed to start containers: realserver1
```

- 解决办法：
  ```md
  [root@localhost ~]# pkill docker
  [root@localhost ~]# iptables -t nat -F
  [root@localhost ~]# ifconfig docker0 down
  [root@localhost ~]# brctl delbr docker0
  [root@localhost ~]# service docker restart
  Redirecting to /bin/systemctl restart docker.service
  ```
- [参考文章](https://www.zengjunpeng.com/?id=90)

---

🍉**在搭建数据库主从复制的配置完my.cnf重启数据库失败**

- 解决办法

```md
给文件配置权限：
chmod -R 777 /wsj/mysql...
```

🍎**mysql登录Warning问题**

```md
root@18db030d2c7a:~# mysql -uroot -p
mysql: [Warning] World-writable config file '/etc/mysql/conf.d/my.cnf' is ignored.
Enter password: 
```

- 解决办法
  ```md
  因为my.cnf的权限为777
  修改权限
  chmod 644 my.cnf
  ```
- [参考文档](https://blog.csdn.net/u010033674/article/details/104450663?)

🍌**mysql中创建数据库出现错误**：

```md
ERROR 13 (HY000): Can't get stat of './wsj' (OS errno 13 - Permission denied)
```

- 解决问题：

```md
因为无法获取./wsj,可以看出是权限不足，所以给/var/lib/mysql授予777权限。
```

🌹**mysql的error_log**:

```md
show variables like 'error_log';
+---------------+--------+
| Variable_name | Value  |
+---------------+--------+
| log_error     | stderr |
+---------------+--------+
1 row in set (0.70 sec)
## 当前的输出为stderr，表示我的这个MySQL日志会把日志输出到标准错误输出中。因为我的这个MySQL是使用docker容器启动的。所以这个error log默认是这么配置的。这样当我们启动这个容器的时候，如果启动失败，就可以使用docker logs 容器ID来查看具体启动MySQL服务的日志了。
```

- [参考文档](https://blog.csdn.net/javaanddonet/article/details/113276976?)

🌷**关于mysql主从复制中Slave_IO_Running: Connecting**

- [参考文章](https://blog.csdn.net/qq_36756682/article/details/109647266?)

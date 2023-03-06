## LVS使用🦋
[命令](http://t.zoukankan.com/klb561-p-9215704.html)
```md
sudo ipvsadm -A -t 10.2.10.10:80 -s rr         #定义集群服务
sudo ipvsadm -a -t 10.2.10.10:80 -r 172.17.0.6 -m #添加 RealServer1
sudo ipvsadm -a -t 10.2.10.10:80 -r 172.17.0.7 -m #添加 RealServer2
sudo ipvsadm -l                 #查看 ipvs 定义的规则

    # 添加集群服务
    -A：添加一个新的集群服务
    -t: 使用 TCP 协议
    -s: 指定负载均衡调度算法
    rr：轮询算法(LVS 实现了 8 种调度算法)
    192.168.100.5:8888  定义集群服务的 IP 地址（VIP） 和端口
     
    # 添加 Real Server 规则
    -a：添加一个新的 RealServer 规则
    -t：tcp 协议
    -r：指定 RealServer IP 地址
    -m：定义为 NAT 
    上面命令添加了两个服务器 RealServer1 和 RealServer2
```

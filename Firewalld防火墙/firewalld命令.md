
# firewall-cmd常用命令及存储位置

1、安装Firewall 命令：

    yum install firewalld firewalld-configFirewall

2、区域管理类命令

    firewall-cmd --set-default-zone=trusted  #设置默认区域为trusted,允许所有的通过，会改变防火墙配置文件：/etc/firewalld/firewalld.conf中的默认值
    firewall-cmd --get-default-zone         #查看默认区域
    firewall-cmd --get-active-zones         #查看（活动区域）默认接口和区域
    firewall-cmd --get-zones                #列出所有可用的区域
    firewall-cmd --list-all --zone=public   #查看public区域已配置的规则（只显示/etc/firewalld/zones/public.xml中防火墙策略）
    firewall-cmd --list-all-zones           #查看所有的防火墙策略（即显示/etc/firewalld/zones/下的所有策略）

3、端口管理：

    firewall-cmd --permanent --list-port --zone=public            #查看端口，不加zone就是查询默认zone
    firewall-cmd --zone=public --add-port=3306/tcp --permanent    #允许tcp的3306端口到public区域。
    #–zone：作用域；–add-port=80/tcp：添加端口，格式为：端口/通讯协议；–permanent：永久生效，没有此参数重启后失效
    firewall-cmd --reload                                         #重新加载防火墙配置，并不中断用户连接，即不丢失状态信息
    firewall-cmd --zone=public --remove-port=3306/tcp--permanent  #从public区将tcp的3306端口移除
    firewall-cmd --add-port=2048-2050/udp --zone=public           #允许某一范围的端口，如允许udp的2048-2050端口到public区域

4、服务管理：

    firewall-cmd --get-services                                #查看预定义服务 ：
    firewall-cmd --add-service=http --zone=public --permanent  #添加http服务到public区域
    systemctl restart firewalld                                #重启防火墙服务才生效（permanent状态）：
    firewall-cmd --remove-service=http --permanent --zone=public #移除public区域的http服务，不使用--zone指定区域时使用默认区域：
    firewall-cmd --add-service=http --add-service=https        #将多个服务添加到某一个区域，不添加--permanent选项表示是即时生效的临时设置

5、伪装ip：

    firewall-cmd --query-masquerade                # 检查是否允许伪装IP
    firewall-cmd --permanent --add-masquerade      # 允许防火墙伪装IP
    firewall-cmd --permanent --remove-masquerade   # 禁止防火墙伪装IP

6、端口转发：

    当我们想把某个端口隐藏起来的时候，就可以在防火墙上阻止那个端口访问，然后再开一个不规则的端
    口，之后配置防火墙的端口转发，将流量转发过去。
    例：

    1. firewall-cmd --permanent --add-masquerade                     #开启地址伪装。
    2. firewall-cmd --add-forward-port=port=8080:proto=tcp:toport80  #添加转发8080--》80
    3. firewall-cmd --add-port=8080/tcp
    4. firewall-cmd --remove-service=http                            #删除80端口的协议。

7、多区域的应用：

    1）可以根据不同的接口配置不同的区域
    2）可以对同一个接口，对不同网段的ip/流量，配置不同的访问
    例：

    1. 一个接口只能对应一个区域，将接口与指定区域关联：
    firewall-cmd --change-interface=ens75 --zone=drop
    2. 根据不同的访问来源网段，设定至不同的区域规则：
    firewall-cmd --add-source=192.168.75.0/24 --zone=public
    firewall-cmd --add-source=192.168.85.0/24 --zone=drop
    firewall-cmd --get-active-zones ：查看（活动区域）默认接口和区域。

[setenforce](https://blog.csdn.net/java_java_cl/article/details/104806331?ops_request_misc=&request_id=&biz_id=102&utm_term=setenforce%200&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-4-104806331.142^v62^js_top,201^v3^control_2,213^v1^control&spm=1018.2226.3001.4187)
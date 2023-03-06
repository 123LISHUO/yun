# 搭建LVS
**使用docker进行搭建**
## 搭建前准备：
- 安装并运行docker
- 制作realserver镜像：
    ```md
        使用docker拉取centos的镜像，然后运行centos并安装nginx，然后使用docker commit制作realserver镜像。    
    ```
- 安装ipvsadm
    ```md
        yum install -y ipvsadm
        modprobe ip_vs
    ```
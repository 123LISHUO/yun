# :zap:$目录文件$
---
# [linux 主目录](https://blog.csdn.net/qq_36501591/article/details/117413470?)
---
![](2022-09-19-16-21-16.png)

# Linux目录结构

    /root 系统管理员root的家目录
    /home 普通用户的家目录
    /boot：系统内核、启动文件 reboot
    /dev 设备文件
    /etc 配置文件
    /lib /lib64 库文件（so）
    /tmp 临时文件
    /media /mnt 默认挂载点
    /bin 所有用户可执行的命令
    /sbin 管理员可执行的管理命令
    /usr /opt 应用程序
    /var/log 日志文件等
![](2022-11-03-15-54-42.png)  

---
---
## /etc/fstab 设置文件系统的自动挂载

    /etc/fstab是用来存放文件系统的静态信息的文件。位于/etc/目录下，
    可以用命令less /etc/fstab 来查看，
    如果要修改的话，则用命令 vi /etc/fstab 来修改。

    当系统启动的时候，系统会自动地从这个文件读取信息，
    并且会自动将此文件中指定的文件系统挂载到指定的目录

    [root@localhost ~]# vim /etc/fstab 文件最后追加四行
        /dev/cdrom /media/cdrom/ iso9660 defaults 0 0
        /dev/sdb1 /dianying xfs defaults 0 0
        /dev/sdb2 /xuexi ext4 defaults 0 0
        /dev/sdb6 /youxi vfat defaults 0 0
        [root@localhost ~]# mount -a
        mount: /dev/sr0 写保护，将以只读方式挂载
        [root@localhost ~]# mount | grep sdb
        /dev/sdb1 on /dianying type xfs (rw,relatime,attr2,inode64,noquota)
        /dev/sdb2 on /xuexi type ext4 (rw,relatime,data=ordered)
        /dev/sdb6 on /youxi type vfat
        (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors =remount-ro)
        常见参数：
        /dev/sdb1 /dianying xfs defaults,ro 0 1
            defaults：默认
            auto：系统自动挂载，fstab 默认就是这个选项
            noauto：开机不自动挂载
            nouser：只有超级用户可以挂载
            ro：按制权读限挂载(read only)
            rw：按可读可写权限挂载
            user：任何用户都可以挂载
            dump 备份设置
        /dev/sdb1 /dianying ext4 defaults 1 2
        当其值为 1 时，将允许 dump 备份程序备份；设置为 0 时，忽略备份操作
        fsck 磁盘检查设置
        /dev/sdb1 /dianying ext4 defaults 1 2
        其值是一个顺序，当其值为 0 时，永远不检查；而/根目录分区永远都为 1 优先检查；
        其他分区一般为 2 次要检查。

---
---
# 用户信息
## /etc/passwd
    作用：
    保存用户名称、宿主目录、登录Shell等基本信息，每一行对应一个用户的账号记录。

    [root@localhost ~]# head -1 /etc/passwd
    root:x:0:0:root:/root:/bin/bash

    共7各字段，各字段代表含义：
    第一字段：用户账号名
    第二字段：密码占位符（密码保存到了影子文件）
    第三字段：uid编号
    第四字段：gid编号
    第五字段：用户备注信息（用户全名）
    第六字段：用户宿主目录（家目录）
    第七字段：登录时分配到的shell解释器（若shell类型为/sbin/nologin 则不能登录）

## /etc/shadow 
    影子文件
    作用：
    保存用户的密码、账号有效期等信息，每一行对应一个用户的密码记录。

    [root@localhost ~]# tail -1 /etc/shadow
    mysql:$6$Dk21okj.$Oqw93VXjsJLAgn3FYPFomdBI7ThzjV1U7Ydreg/NeACmsqlVGEYWZFegXBmoEtrIcikGsvbKEpDpkR07dEgXi.:17881:0:99999:7:::

    密码复杂度:
    3/4原则：大写字母 小写字母 数字 特殊符号
    长度：8位

    密码破解：字典 穷举（暴力破解）

    共9字段，目前只启用前8字段，各字段代表的含义：
    第一字段：用户账号名
    第二字段：加密的密码,!!表示密码被锁定
    第三字段：上次修改密码的时间，距1970-01-01过去多少天
    第四字段：密码最短有效期（距上次密码修改起多少天内不能再次修改密码）单位"天"。"0"表示随时可修改密码。
    第五字段：密码最长有效期（在修改密码后的多少天必须重新修改密码。99999表示永久可以使用。）
    第六字段：提前多少天警告用户口令将过期（7表示在密码过期前7天开始警告）
    第七字段：在密码过期之后多少天禁用此用户
    第八字段：密码过期日期，若设置则显示为过期日期距1970年1月1日多少天。
    第九字段：保留字段（未使用）
    
---
---
# 关于用户及密码相关控制文件 
## /etc/login.defs
    [root@localhost ~]# grep -v -E "^$|^#" /etc/login.defs
    MAIL_DIR /var/spool/mail 	#用户邮件存放目录
    PASS_MAX_DAYS 99999 	#密码默认最长有效期
    PASS_MIN_DAYS 0 		#密码默认最短有效期
    PASS_MIN_LEN 5 			#密码默认长度
    PASS_WARN_AGE 7 		#密码过期警告时间
    UID_MIN 1000 			#普通用户起始UID范围
    UID_MAX 60000 			#普通用户结束UID范围
    SYS_UID_MIN 201 		#系统用户起始UID范围
    SYS_UID_MAX 999 		#系统用户结束UID范围
    GID_MIN 1000 			#普通组起始GID范围
    GID_MAX 60000 			#普通组结束GID范围
    SYS_GID_MIN 201 		#系统组起始GID范围
    SYS_GID_MAX 999 		#系统组结束GID范围
    CREATE_HOME yes 		#是否创建用户宿主目录
    UMASK 077 				#用户宿主目录默认权限
    USERGROUPS_ENAB yes 	#表示userdel删除用户时，如果该用户用户组如果没有成员存在，则会删除该用户组
    ENCRYPT_METHOD SHA512	#表示用户密码加密方式，此处表示用MD5加密密码
## /etc/default/useradd
    [root@localhost ~]# grep -v -E "^$|^#" /etc/default/useradd 
    GROUP=100
    HOME=/home 	#把用户的主目录建在/home中
    INACTIVE=-1 		#是否启用帐号过期停权，-1表示不启用
    EXPIRE= 			#帐号终止日期，不设置表示不启用；
    SHELL=/bin/bash 	#所用SHELL的类型；
    SKEL=/etc/skel 	#默认添加用户的目录默认文件存放位置；也就是说，当我们用adduser添加用户时，用户家目录下的文件，都是从这个目录中复制过去的

    /lib64/security/pam_cracklib.so	#控制密码复杂度的关键文件，Redhat公司专门开发了cracklib这个安装包来判断密码的复杂度。

    [root@localhost ~]# man pam_cracklib
    retry=N 		#改变输入密码的次数，默认值是1。就是说，如果用户输入的密码强度不够就退出。可以使用这个选项设置输入的次数，以免一切都从头再来
    minlen=N 	#新密码最低可接受的长度
    difok=N 		#默认值为10。这个参数设置允许的新、旧密码相同字符的个数。不过，如果新密码中1/2的字符和旧密码不同，则新密码被接受
    dcredit=N 	#限制新密码中至少有多少个数字
    ucredit=N	#限制新密码中至少有多少个大写字符。
    lcredit=N 	#限制新密码中至少有多少个小写字符。

---
---

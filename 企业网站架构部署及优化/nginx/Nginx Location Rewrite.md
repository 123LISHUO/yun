# $Nginx 正则及 location 匹配$
#### $Nginx location 规则匹配:$
|标识符|作用|
|:---:|---|
^~ |标识符匹配后面跟一个字符串。匹配字符串后将停止对后续的正则表达式进行匹配，如 location ^~ /images/，在匹配了/images/这个字符串后就停止对后续的正则匹配
= |精准匹配，如 location = /，只会匹配 url 为/的请求-> http://www.a.com/ 
~ |区分大小写的匹配 -> location ~ \.jsp$
~* |不区分大小写的匹配-> location ~* \.jsp$
!~ |对区分大小写的匹配取非
!~* |对不区分大小写的匹配取非
/ |通用匹配, 如果没有其它匹配,任何请求都会被匹配到

#### $正则表达式:$
|标识符|作用|
|:---:|---|
* |重复前面的字符 0 次或多次
? |重复前面的字符 0 次或 1 次
+ |重复前面的字符 1 次或多次
. |匹配除换行符以外的任意 1 个字符
|(a\|b)| 匹配 a 或 b
^ |以…开头
$ |以…结尾
{n} |重复前面的字符 n 次
{n,} |重复前面的字符 n 次或更多次
{n,m} |重复前面的字符 n 到 m 次
*? |重复前面的字符 0 次或多次，但尽可能少重复
+? |重复前面的字符 1 次或更多次，但尽可能少重复
?? |重复前面的字符 0 次或 1 次，但尽可能少重复
{n,m}? |重复前面的字符 n 到 m 次，但尽可能少重复
{n,}? |重复前面的字符 n 次以上，但尽可能少重复

#### $正则表达式补充:$
|标识符|作用|
|:---:|---|
\W |匹配任意不是字母，数字，下划线，汉字的字符
\S |匹配任意不是空白符的字符
\D |匹配任意非数字的字符
\B |匹配不是单词开头或结束的位置
[a] |匹配单个字符 a
[a-z]| 匹配 a-z 小写字母的任意一个
[^a] |匹配除了 a 以外的任意字符
[^abc]| 匹配除了 abc 这几个字母以外的任意字符

#### $Nginx \ location 应用规则：$

    location [=|~|~*|^~|!~|!~*|/] /url/{...}
    默认值：no
    使用字段：server
    location 参数根据 URL 的不同需求来进行配置，可以使用字符串与正则表达式匹配，

    location ~* .*\.jsp$ {
        proxy_pass http://tomcat_server;
    }
>
    location = / {
    # 精确匹配 / ，主机名后面不能带任何字符串
    [ configuration A ]
    }

    location / {
    # 因为所有的地址都以 / 开头，所以这条规则将匹配到所有请求
    # 但是正则和最长字符串会优先匹配
    [ configuration B ]
    }

    location /documents/ {
    # 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
    # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
    [ configuration C ]
    }

    location ~ /documents/abc {
    # 匹配任何以 /documents/abc 开头的地址，匹配符合以后，还要继续往下搜索
    # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
    [ configuration CC ]
    }

    location ^~ /images/ {
    # 匹配任何以 /images/ 开头的地址，匹配符合以后，停止往下搜索正则，采用这一条。
    [ configuration D ]
    }

    location ~* \.(gif|jpg|jpeg)$ {
    # 匹配所有以 gif,jpg 或 jpeg 结尾的请求
    # 然而，所有请求 /images/ 下的图片会被 config D 处理，因为 ^~ 到达不了这一条正则
    [ configuration E ]
    }

    location /images/ {
    # 字符匹配到 /images/，继续往下，会发现 ^~ 存在
    [ configuration F ]
    }

    location /images/abc {
    # 最长字符匹配到 /images/abc，继续往下，会发现 ^~ 存在
    # F 与 G 的放置顺序是没有关系的
    [ configuration G ]
    }
    
    location ~ /images/abc/ {
    # 只有去掉 config D 才有效：先最长匹配 config G 开头的地址，继续往下搜索，匹配到这一条正则，采用
    [ configuration H ]
    }

#### ==$匹配顺序优先级：$==
(location =) > (location 完整路径) > (location ^~ 路径) > (location ~,~* 正则顺序) > (location 部分起始路径) > (/)

$按照上面的 location 匹配，分析以下案例：$

    / ->config A
    精确完全匹配，即使/index.html 也匹配不了

    /downloads/download.html ->config B
    匹配 B 以后，往下没有任何匹配，采用 B

    /images/1.gif -> config D
    匹配到 B，往下匹配到 D，停止往下

    /images/abc/def ->config D
    最长匹配到 G，往下匹配 D，停止往下你可以看到 任何以/images/开头的都会匹配到 D 并停止，FG 写在这里是没有任何意义的，H 是永远轮不到的，这里只是为了说明匹配顺序

    /documents/document.html ->config C
    匹配到 C，往下没有任何匹配，采用 C

    /documents/1.jpg -> configuration E
    匹配到 C，往下正则匹配到 E

    /documents/abc ->config CC
    最长匹配到 C，往下正则顺序匹配到 CC，往下到 E

#### 实际使用建议
所以实际使用中，个人觉得至少有三个匹配规则定义，如下：

直接匹配网站根，通过域名访问网站首页比较频繁，使用这个会加速处理。这里是直接转发给后端应用服务器了，也可以是一个静态首页。

- 第一个必选规则

        location = / {
            proxy_pass http://tomcat:8080;
        }

- 第二个必选规则是处理静态文件请求，这是 nginx 作为 http 服务器的强项

        有两种配置模式，目录匹配或后缀匹配,任选其一或搭配使用

        location ^~ /static/ {
                    root /usr/local/nginx/html/static/;
        }
        location ~* \.(gif|jpg|jpeg|png|css|js|ico)$ {
                    root /webroot/res/;
        }


- 第三个规则就是通用规则，用来转发动态请求到后端应用服务器，非静态文件请求就默认是动态请求，自己根据实际把握。
毕竟目前的一些框架的流行，带.php,.jsp 后缀的情况很少了

        location / {
            proxy_pass http://tomcat:8080;
        }

# $Nginx \ Rewrite 规则$
$Nginx\ Rewrite 功能是使用 nginx 提供的全局变量或自己设置的变量，\\结合正则表达式和标志位实现 URL 重写以及重定向功能$

    Nginx 的 Rewrite 规则采用 PCRE（Perl compatible Regular Expressions，Perl 兼容正则表达式）的语法进行规则匹配，如果需要 Nginx 的 Rewrite 功能，在编译安装 Nginx之前，必须安装 PCRE 库。
```Rewrite 指令只能放在 server{},location{},if{}中，并且只能对域名后边的除去传递的参数外的字符串起作用```

例如：http://www.crushlinux.com/a/we/index.php?id=1&u=admin 只对 URL 中的/a/we/index.php 等字符串起作用。
URL 是 Uniform Resource Location 的缩写，译为“统一资源定位符”
#### $语法：$
rewrite 正则表达式 更换目标 [标志位];

rewrite 和 location 功能有点像，都能实现跳转。主要区别在于 rewrite 是在同一域名内
更改获取资源的路径，而 location 是对路径做控制访问或反向代理，可以使用 proxy_pass 代
理到其他机器。很多情况下 rewrite 也会写在 location 里，它们的执行顺序是：
1. 执行 server 块的 rewrite 指令
2. 执行 location 匹配
3. 执行选定的 location 中的 rewrite 指令
==注意：如果其中某步 URI 被重写，则重新循环执行 1-3，直到找到真实存在的文件；循环超
过 10 次，则返回 500 Internal Server Error 错误。==

#### flag 标志位
- last : 相当于 Apache 的[L]标记，表示完成 rewrite
- break : 本条规则匹配完成后，终止匹配，不再匹配后面的规则
- redirect : 返回 302 临时重定向，浏览器地址栏会显示跳转后的 URL 地址
- permanent : 返回 301 永久重定向，浏览器地址栏会显示跳转后的 URL 地址

last 一般写在 server 和 if 中，而 break 一般使用在 location 中
last 不终止重写后的 url 匹配，即新的 url 会再从 server 走一遍匹配流程，而 break 终止重写后的匹配
break 和 last 都能组织继续执行后面的 rewrite 指令

last 和 break 用来实现 URI 重写，浏览器地址栏 URL 地址不变
redirect 和 permanent 用来实现 URL 跳转，浏览器地址栏会显示跳转后的 URL 地址

#### if 指令与全局变量
$if 判断指令$
语法为 if(condition){...}，对给定的条件 condition 进行判断。如果为真，大括号内的 rewrite
指令将被执行，if 条件(conditon)可以是如下任何内容：

当表达式只是一个变量时，如果其值为空或任何以 0 开头的字符串时都会当作条件为 false

直接比较变量和内容时，使用=或!=
-f 和!-f 用来判断是否存在文件
-d 和!-d 用来判断是否存在目录
-e 和!-e 用来判断是否存在文件或目录
-x 和!-x 用来判断文件是否可执行

$例如$： http://www.a.com/msie/a/b/test.html

    if ($http_user_agent ~ MSIE) {
    rewrite ^(.*)$ /msie/$1 break;
    }
    //如果 UA 包含"MSIE"，rewrite 请求到/msie/目录下
    if ($request_method = POST) {
    return 405;
    } //如果提交方法为 POST，则返回状态 405（Method not allowed）。return 不能返回 301,302
==注意：因为返回 301 和 302 不能只返回状态码，还必须有重定向的 URL，所以 return 指令无法返回 301,302。==

    if ($slow) {
    limit_rate 10k;
    } //限速，$slow 可以通过 set 指令设置

    if (!-f $request_filename){
    break;
    proxy_pass http://127.0.0.1;
    } //如果请求的文件名不存在，则反向代理到 localhost 。这里的 break 也是停止 rewrite 检查

    if ($args ~ post=140){
    rewrite ^ http://example.com/ permanent;
    } //如果 query string 中包含"post=140"，永久重定向到 example.com

# ==Nginx 变量==
下面是可以用作 if 判断的变量
|变量名|作用|
|:---:|---|
|$args：| 记录请求行中的参数，同$query_string
|$content_length：| 记录请求头中的 Content-length 字段。
|$content_type： |记录请求头中的 Content-Type 字段。
|$document_root：|记录当前请求在 root 指令中指定的值。
|$host ： |记录请求主机头字段，否则为服务器名称。
|$http_user_agent： |记录用于记录客户端浏览器的相关信息
|$http_cookie： |记录客户端 cookie 信息
|$limit_rate： |记录可以限制连接速率。
|$request_method： |记录客户端请求的动作，通常为 GET 或 POST。
|$request_filename：| 记录当前请求的文件路径，由 root 或 alias 指令与 URI 请求生成。
|$scheme ： |记录 HTTP 方法（如 http，https）。
|$server_protocol：|记录请求使用的协议，通常是 HTTP/1.0 或 HTTP/1.1。
|$server_addr： |记录服务器地址，在完成一次系统调用后可以确定这个值。
|$server_name： |记录服务器名称。
|$server_port： |记录请求到达服务器的端口号。
|$request_uri： |记录包含请求参数的原始 URI，不包含主机名，如：”/foo/bar.php?arg=baz”。
|$uri： |记录不带请求参数的当前 URI，$uri 不包含主机名，如”http://www.a.com/foo/bar.php”。
|$document_uri：| 与$uri 相同。
|$http_x_forwarded_for |记录远程客户端的 ip 地址
|$remote_addr： |记录远程客户端的 IP 地址。
|$remote_port： |记录远程客户端的端口。
|$remote_user |记录远程客户端用户名称
|$time_local |记录访问时间及时区
|$request |记录请求的 URL 与 HTTP 协议
|$status |记录请求的状态，例如成功时为 200，页面找不到时为 404
|$body_byte_sent |记录发送给客户端的文件主体内容大小
|$http_referer |记录是从哪个页面链接访问过来的

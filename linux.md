# Linux

## centos7

网络配置  
配置文件路径：/etc/sysconfig/network-script/ifcfg-eth0  



## 防火墙

内核态 netfilter 内核中实现的  
用户态 iptables、firewalld，用户配置的工具  

过滤数据包  
默认策略：拒绝所有数据包从入口方向进入  
安全性和性能永远成反比

可以用来统计某个服务的流量  

## shell

### bash的功能

shell的功能只是提供用户操作系统内核的一个接口  
man、chmod、chown、vi、fdisk、mkfs这些都是独立的应用程序，但可以通过shell来操作这些应用程序，让这些应用程序呼叫内核来运行所需的工作  
/bin/bash Linux默认shell

/etc/shells 系统中可用的shell  
/etc/passwd 每个用户默认使用的shell  

history  
上下键可以找到之前输入的命令，默认可记忆1000个  
.bash_history记录了前一次登陆以前所运行过的命令，本次登陆所运行的命令缓存在内存中，注销之后才会记录到.bash_history中  

tab命令和文件补全  
连续两次tab可以显示当前环境下可运行的所有命令  
想知道系统中所有c开头的命令了，c加两次tab即可  

alias命令别名  
直接使用alias可以查看当前命令别名  
`alias lm='ls -al'` 设置命令别名  

job control、foreground、background  
工作控制、前景背景控制  

shell script  
程序化脚本  

wildcard  
通配符  
`ls -l /usr/bin/x*` 查询/usr/bin路径下有多少x开头的文件  

### 变量

让某一个特定字符串代表不固定的内容  
用一个变量名来代表一个复杂或容易变动的数据  

环境变量  
影响bash环境操作的变量  
通常大写  
如PATH

写shell scripts时，把路径写成变量，之后路径需要改变的时候，就不用大量改动  

username=kim 此处设置username变量  

$username即可调用  

echo $username 或 echo {username} 打印变量的内容

username=kimalan 即可修改变量内容  

变量名只能是英文字母和数字，且不能以数字开头  

变量内容如果有空格，要用单引号或双引号包裹起来

单引号包裹的只能是一般字符  
双引号包裹的可以有特殊含义的字符  
name='$name is me' 此处$name就是普通字符
name="$name is me" 此处$name就是变量

PATH=$PATH:/usr/local/ 增加变量内容  

系统默认变量大写，自有变量小写，方便区分  

unset myname 取消变量  

export PATH=$PATH:/usr/local/bin 将变量转为环境变量  

子程序，在当前shell激活一个新的shell，新的shell就是子程序，一般父程序的自定义变量是无法在子程序内使用的，但通过export把变量变成环境变量之后就可以在子程序内使用了  

进入目前核心的模块目录  

```shell
cd /lib/modules/`uname -r`/kernel
cd /lib/modules/$(uname -r)/kernel
```

通过反单引号包裹，或$()两种方式可以先获得uname -r的结果再带入到cd命令中  
命令执行的过程中，反单引号包裹的内容会优先执行，其输出的结果将被作为外部的输入信息  
反单引号容易认错，最好使用$()格式

```shell
ls -l `locate crontab`
```

此例中先把locate将文件名数据列出来，在以ls命令处理

centos默认没有安装locate
安装 yum install mlocate  
更新后台数据库 updatedb  

### 环境变量

env 列出当前shell
 
### tips

#### type

查看命令是否内建在bash中，还是外部命令  
`type [-tpa] name`  
不加任何选项和参数时，type显示出name是外部命令，还是内建命令  
-t 命令属于下列三个类型中的哪一个
file：外部命令  
alias 该命令为命令别名所配置的名称  
buildin bash内建命令  
-p 只有name是外部命令时才会显示完整路径  
-a 在PATH变量定义的路径中，将所有含name的命令都列出来，包括alias

与which命令相似，which默认在PATH内找命令的路径  

#### 多行输入命令

命令串太长时，可以用反斜杠加回车`\+Enter`来分成两行输入  
反斜杠和回车直接不要空格  
输入命令后按回车执行，此处反斜杠相当于把回车转义为换行符，而不再是执行命令的含义  

## linux隐藏进程

ps不显示0号进程，把pid改成0就可以隐藏  

替换系统中常见的进程查看工具 ps top lsof  
从干净的系统中拷贝这些工具到当前系统，对比输出是否一致  

hook掉readdir和readdir64两个函数  

通过 find 命令查找入侵时间范围内变更的文件，对变更文件的排查，同时对相关文件进行分析,在变更文件里可以看到一些挖矿程序，同时`/etc/ld.so.preload`文件的变更需要引起注意，这里涉及到Linux动态链接库预加载机制，是一种常用的进程隐藏方法，而top等命令都是受这个机制影响的

在Linux操作系统的动态链接库加载过程中，动态链接器会读取 LD_PRELOAD环境变量的值和默认配置文件`/etc/ld.so.preload`的文件内容，并将读取到的动态链接库进行预加载，即使程序不依赖这些动态链接库，LD_PRELOAD环境变量和`/etc/ld.so.preload`配置文件中指定的动态链接库依然会被装载，它们的优先级LD_LIBRARY_PATH环境变量所定义的链接库查找路径的文件优先级要高，所以能够提前于用户调用的动态库载入。

`cat /etc/ld.so.preload` 可以看到加载一个.so 文件：`/usr/local/lib/libjdk.so`  
libjdk.so中hook掉readdir和readdir64两个函数  
使函数改为在读取目录为/proc时，在遍历的过程中如果进程名为挖矿进程名，则过滤  
类似于top、ps等命令在显示进程列表的时候就是调用的readdir方法遍历/proc目录，于是挖矿进程就被过滤而没有出现在进程列表里  

## linux挖矿病毒

### sample1: 进程未隐藏  

现象：服务器操作迟缓  

* top命令查看CPU利用率，挖矿病毒会进程占用大量CPU资源  
* `ps -aux | grep  sysupdate`获取进程号PID  
* `ls -l /proc/{pid}/exe`获取绝对路径  
* 下载文件，上传到virustotal等网站查是否病毒
* 确认病毒后，清除进程`kill -9 {pid}`
* 删除病毒文件，`rm -f sysupdate`
* 提示`rm: cannot remove 'sysupdate': Operation not permitted`
  * 基于经验，应该是病毒使用了chattr +i的命令。我们只要先执行`chattr -i sysupdate`，然后就可以正常删除了。
  * chattr配置文件隐藏属性，需要root权限
  * `chattr +i sysupdate`，可以让文件无法被改动
  * `chattr +a sysupdate`，文件只能添加数据，不能删除也不能修改
* 复发，删除后又被创建出来，分析sysupdate发现他不是病毒，只是一个xmr挖矿程序，要找到真正的病毒
* `crontab -l`或者`cat /var/spool/cron/root`
* 可以去查看定时任务的日志。`more /var/log/cron log`，太多的话，可以在后面加上| grep -v {要排除的关键字}来排除无用信息
* 找到定时执行的源头文件`update.sh`

修复

1. `rm /var/spool/cron/root`或者`crontab -r`删除定时任务。

2. kill命令将相关进程干掉，用chattr -i和rm命令，将上述/etc下的文件全部删除

3. /root/.ssh/authorized_keys也删掉或者修复。

4. 至于IPTABLES、SELinux的恢复，就看大家自己的需求了。

### sample2:进程被隐藏

* 如果进程被隐藏了，有可能CPU使用率较低，但ni值100，通过`/proc/stat`计算CPU使用率又基本是100%  
* `netstat -ant`查看网络连接，发现异常外网连接，在virustotal查ip，发现指向矿池
* 通过find命令查找入侵时间范围内变更的文件，对变更文件的排查，同时对相关文件进行分析，基本可以确认黑客使用的进程隐藏手法。
* 在变更文件里可以看到一些挖矿程序，同时 `/etc/ld.so.preload` 文件的变更需要引起注意，这里涉及到 Linux 动态链接库预加载机制，是一种常用的进程隐藏方法，而 top 等命令都是受这个机制影响的
* 通过查看文件内容，可以看到加载一个`.so` 文件：`/usr/local/lib/libjdk.so`;这个文件也在文件变更列表里
* 通过查看启动的相关进程的 maps 信息，也可以看到相关预加载的内容`cat /proc/9107/maps | grep 'libjdk.so'`
* 通过对`libjdk.so`的逆向分析，我们可以确认其主要功能就是过滤了挖矿进程
* 知道了黑客使用的隐藏手法后，直接编辑`/etc/ld.so.preload`文件去掉相关内容，然后再通过 top 命令即可看到挖矿进程
* 通过查看 /proc/ 下进程信息可以找到位置，看到相关文件，直接进行清理即可`ls -lh /proc/11317`
* 继续分析变更的文件，还能看到相关文件也被变更 ，比如黑客通过修改`/etc/rc.d/init.d/network`文件来进行启动
* 同时修改`/etc/resolv.conf`;还修改了 HOSTS 文件，猜测是屏蔽其他挖矿程序和黑客入侵;同时增加了防火墙规则,查询 IP 可以看到是一个国外IP
* 通过对样本逆向分析，发现样本`libjdk.so`主要是Hook了`readdir`和`readdir64`两个函数
* 整个函数功能结合来看就是判断如果读取目录为/proc，那么遍历的过程中如果进程名为x7，则过滤，而x7就是挖矿进程名。而类似于 top、ps 等命令在显示进程列表的时候就是调用的readdir方法遍历/proc目录，于是挖矿进程x 就被过滤而没有出现在进程列表里

# pxe

Preboot eXecution Environment  
预启动执行环境

网络启动  
通过网络自动部署系统  
路由器要支持

## pxe部署centos

[使用kickstart与tftp并通过网络启动centos7安装程序实现自动部署](https://ngx.hk/2018/11/18/%e4%bd%bf%e7%94%a8kickstart%e4%b8%8etftp%e5%b9%b6%e9%80%9a%e8%bf%87%e7%bd%91%e7%bb%9c%e5%90%af%e5%8a%a8centos7%e5%ae%89%e8%a3%85%e7%a8%8b%e5%ba%8f%e5%ae%9e%e7%8e%b0%e8%87%aa%e5%8a%a8%e9%83%a8%e7%bd%b2.html)  
[BiliBili直播](https://www.bilibili.com/video/av85635968)

* 首先需要一个DHCP服务器，并配置网络启动的相关信息  
可以使用pfsense软路由，开启network booting功能，设置next server为tftp服务器的地址（消费级路由器都没有，网管型交换机有）  
pfsense找到Service/DHCP/ServerLAN页面进行设置  
当客户机请求DHCP服务内容时返回网络启动的相关信息，在这里时tftp的服务器地址和BIOS文件

* 然后需要一个pxe配置文件放置的地方，找一个linux系统的虚拟机或物理机安装tftp服务器。  
`yum install -y tftp-server syslinux`  
tftp将BIOS文件发送给客户机用于引导，其中的配置文件会包含启动方式等内容  
安装完tftp后，修改配置文件，启动服务  
`vim /etc/xinetd.d/tftp`  
将disable的值设为no

```
service tftp
{
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -s /var/lib/tftpboot
        disable                 = no
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
```

* 可以用清华大学的镜像站，也可以自己在内网部署一个镜像库

*  

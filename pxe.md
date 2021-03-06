# pxe

Preboot eXecution Environment  
预启动执行环境

网络启动  
通过网络自动部署系统  
路由器要支持  
[PXE笔记](https://blog.51cto.com/13588693/2355691)

## pxe部署centos

[使用kickstart与tftp并通过网络启动centos7安装程序实现自动部署](https://ngx.hk/2018/11/18/%e4%bd%bf%e7%94%a8kickstart%e4%b8%8etftp%e5%b9%b6%e9%80%9a%e8%bf%87%e7%bd%91%e7%bb%9c%e5%90%af%e5%8a%a8centos7%e5%ae%89%e8%a3%85%e7%a8%8b%e5%ba%8f%e5%ae%9e%e7%8e%b0%e8%87%aa%e5%8a%a8%e9%83%a8%e7%bd%b2.html)  
[BiliBili直播](https://www.bilibili.com/video/av85635968)

首先需要一个DHCP服务器，并配置网络启动的相关信息  
可以使用pfsense软路由，开启network booting功能，设置next server为tftp服务器的地址（消费级路由器都没有，网管型交换机有）  
pfsense找到Service/DHCP/ServerLAN页面进行设置  
当客户机请求DHCP服务内容时返回网络启动的相关信息，在这里时tftp的服务器地址和BIOS文件

然后需要一个pxe配置文件放置的地方，找一个linux系统的虚拟机或物理机安装tftp服务器。  
`yum install -y tftp-server syslinux`  
tftp将BIOS文件发送给客户机用于引导，其中的配置文件会包含启动方式等内容  
安装完tftp后，修改配置文件，启动服务  
`vim /etc/xinetd.d/tftp`  

```
# 将disable的值设为no
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

进入如下目录，并新建文件夹，在里面新建一个配置文件  
`cd /var/lib/tftpboot/`  
`mkdir pxelinux.cfg`  
`vim pxelinux.cfg/default`  

```
# 填入内容
default menu.c32
prompt 0
timeout 30

menu title ##### NGX Proj PXE Boot Menu #####

label 1
menu label ^1) Install CentOS 7 x64 - NGX Proj
kernel vmlinuz
append initrd=initrd.img inst.ks=http://mirror.xx.com/centos/base/anaconda-ks.cfg

label 2
menu label ^2) Install CentOS 7 x86 - NGX Proj x86
kernel vmlinuz
append initrd=initrd.img inst.ks=http://mirror.xx.com/centos/base/anaconda-ks_x86.cfg
```

此处设置的是启动项，label 1和lable 2是两个启动选项，第一个作为默认启动项，timeout是停留在启动项菜单的时间，可以自己调整  
通过网络进行自动安装，在**inst.ks**中指定kickstart生成的自动安装配置文件，此处时作者自建镜像站地址  

最后将启动需要的文件复制到tftpboot目录下  
这些文件由syslinux提供

```
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
cp /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
cp /usr/share/syslinux/memdisk /var/lib/tftpboot/
cp /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
cp /usr/share/syslinux/chain.c32 /var/lib/tftpboot/
```

还需要在清华大学镜像站下载两个文件，也放在tftpboot目录下  
[清华大学镜像站](https://mirrors.tuna.tsinghua.edu.cn/centos/7.7.1908/os/x86_64/isolinux/)  

**vmlinuz**  
**initrd.img**  

上述文件的含义如下：  
chain.c32：引导系统  
mboot.c32：通过内存引导  
memdisk：将内存模拟为磁盘  
menu.c32：菜单文件  
pxelinux.0：引导程序，用于加载kernel和initrd  
vmlinuz：内核
initrd.img：虚拟根文件

完成后启动tftp服务  
设为开机启动`systemctl enable tftp.socket`  
启动服务`systemctl start tftp.socket`  

kickstart配置文件编写前需准备centos的基础源：**base**  
这个安装源中包含一个重要文件：**comps.xml**  
这个文件中包含group list，有了它才可以获得最小化安装、桌面化安装所需要的软件包  
该xml文件同级别的目录下还有一个Packages文件夹，存放基础的软件包；一个repodata文件夹，存放Packages文件夹下软件包信息的数据库  

在centos7系统上安装kickstart并运行创建配置文件

```
#platform=x86, AMD64, or Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard 'us'
# Root password
rootpw --iscrypted $1$i5xGQgfg$Ar6fz7Xcv..KAPK3ISu/a.
# Use network installation
url --url="http://mirror.t.com/centos/base/"
# System language
lang en_US
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use text mode install
text
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
 
# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=eth0
# Reboot after installation
reboot
# System timezone
timezone Asia/Hong_Kong
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part pv.253 --fstype="lvmpv" --ondisk=sda --size=1 --grow
part /boot --fstype="xfs" --ondisk=sda --size=1024
volgroup centos --pesize=4096 pv.253
logvol none  --fstype="None" --size=1 --grow --thinpool --metadatasize=16 --chunksize=65536 --name=pool00 --vgname=centos
logvol swap  --fstype="swap" --size=1024 --name=swap --vgname=centos
logvol /  --fstype="xfs" --size=1 --grow --thin --poolname=pool00 --name=root --vgname=centos
 
%packages
 
@core
perl
wget
bind-utils
net-tools
telnet
 
%end
 
 
%addon com_redhat_kdump --disable
 
 
%end
 
 
#%post --nochroot
#hostnamectl set-hostname $(cat /sys/class/net/ens192/address | sed 's/://g' | cut -c 7-12)
#
#%end
 
%post
 
#echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
#echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "curl -fsSL "http://mirror.t.com/ngx-shell/ngx-pxe-setting-script.sh " | /bin/sh" >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
rm -f /etc/yum.repos.d/*
curl mirror.t.com/home.repo > /etc/yum.repos.d/home.repo
yum clean all && yum install epel-release -y && rm -f /etc/yum.repos.d/epel* &&  yum update -y
rm -f /etc/yum.repos.d/CentOS-* && rm -f /etc/yum.repos.d/epel*
mkdir /tmp/vmtools \
  && wget http://mirror.t.com/vmtools/latest.tar.gz -O /tmp/vmtools/latest.tar.gz \
  && tar zxvf /tmp/vmtools/latest.tar.gz -C /tmp/vmtools \
  && /tmp/vmtools/vmware-tools-distrib/vmware-install.pl -d \
  && rm -rf /tmp/vmtools
 
%end
```



url为镜像地址
可以用清华大学的镜像站，也可以自己在内网部署一个镜像站  

text：使用text模式安装而不加载GUI  

分区：分为3个区  

- swap：1GB
- boot：1GB
- /：剩下的空间

- packages：最小化安装（core）并安装wget与curl
- addon：关闭kdump
- post：
  - 用私有的repo替换官方的repo文件
  - 升级系统
  - 安装vmtools

因为系统更新需要很长的时间，所以部署起来需要3到4分钟，所有流程完成后会自动重启  

编写完kickstart的配置文件后将其放置在pxelinux.cfg目录下default文件中“inst.ks”值所对应的目录中即可，该步骤不需要重启tftp，但需要确认能通过http服务访问  




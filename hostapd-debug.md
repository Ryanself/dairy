## hostapd
星期四, 18. 七月 2019 02:14下午 @ryan

-----------------------------

hostapd 是一个用户态用于AP和认证服务器的守护进程。
### 1. debug in hostapd
#### 1.1 定义
hostapd中打印log的方法基于：

	wpa_printf(MSG_DEBUG, "Reconfigured interface %s", hapd->conf->iface);

其实现为

	86 #define wpa_printf(level, ...)¦ ¦       ¦       ¦       ¦       ¦       \
 	87 ¦       do {¦   ¦       ¦       ¦       ¦       ¦       ¦       ¦       \
 	88 ¦       ¦       if (level >= CONFIG_MSG_MIN_PRIORITY)¦  ¦       ¦       \
 	89 ¦       ¦       ¦       _wpa_printf(level, __VA_ARGS__);¦       ¦       \
 	90 ¦       } while(0)
 	91 
 
 当debug level 大于CONFIG_MSG_MIN_PRIORITY时log会输出到终端。
 CONFIG_MSG_MIN_PRIORITY 默认为0，当前设置值为3。
 下面是debug level的定义：
 
 	21 enum {
	22 ¦       MSG_EXCESSIVE, MSG_MSGDUMP, MSG_DEBUG, MSG_INFO, MSG_WARNING, MSG_ERROR
	23 };
因此在当前情况下只会输出INFO、WARNING、ERROR的log。

#### 1.2 修改
为了满足我们的debug需要，可以修改CONFIG_MSG_MIN_PRIORITY的值。
修改方法：

	make menuconfig	/* 进入OpenWrt Configuration */
	/ /* 搜索 */
	CONFIG_MSG_MIN_PRIORITY
	ok
选择进入修改即可，修改为2时可以打印出MSG_DEBUG级别的log。

#### 1.3 编译
执行

	make package/network/services/hostapd/compile V=s

根据选择的配置不同，hostapd中编译生成的文件不同，编译后生成wpad/hostapd/wpa_supplicant，其路径为：
	
	path: build_dir/target-mipsel_mips-interAptiv_uClibc-0.9.33.2/hostapd-wpad-mini/
	hostapd-2015-03-25/ipkg-mips_siflower/wpad-mini/usr/sbin/
	
#### 1.4 拷贝

在板子上使用scp 进行拷贝操作，将上述路径内容拷贝到板子上的/usr/sbin/ 目录下即可。
如拷贝不成功，可执行

	wifi down
后先在板子上rm掉上述文件，再执行scp操作。

拷贝成功后，通常执行 ` wifi`即可生效。如未生效，也可执行
	
	sfwifi reset

#### 1.5 日志查看

在板子上使用 logread 命令进行查看
或使其一直运行在后台

	logread -f&


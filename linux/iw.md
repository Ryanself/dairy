## IW
**iw命令小结** 
星期三, 24. 十月 2018 03:02下午 

------------------------------------
### 1. GET
iw是基于nl80211的无线设备CLI配置实用程序。
直接下载： [ http://kernel.org/pub/software/network/iw/.]( http://kernel.org/pub/software/network/iw/.)  从git下载： [http://git.kernel.org/?p=linux/kernel/git/jberg/iw.git.](http://git.kernel.org/?p=linux/kernel/git/jberg/iw.git.)  

### 2. EXAMPLE查看连接状况iw dev <网卡名称> link #iw dev wlp2s0 link #not connected连接AP iw <网卡名> connect <SSID> #iw wlp2s0 connect a21在连接的同时，我们可以另开一个终端进行事件监听，命令如下： #iw event -t...
### 3. COMPILE
iw编译依赖于 libnl，需要先下载编译libnl库。	

	./configure  --prefix=$PWD/tmp	make	make install	cd iw-4.14		export PKG_CONFIG_PATH=/home/ryan/libnl-3.3.25/tmp/lib/pkgconfig:	$PKG_CONFIG_PATH		make通过以上操作即可完成编译。
### 4. CODE
流程：

	#eg.
	#iw dev wlan0 set txpower fixed 20.00

	path: iw.c
	main(){
		...
		err = __handle_cmd(&nlstate, II_NETDEV, argc, argv, &cmd);
		...
		}
		
	----------
	path: phy.c
	handle_txpower()
	->
	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY_TX_POWER_SETTING, type);
	NLA_PUT_U32(msg, NL80211_ATTR_WIPHY_TX_POWER_LEVEL, mbm);
	->
	nl80211
	->
	lmac

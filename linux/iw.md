## IW
**iw命令小结** 
星期三, 24. 十月 2018 03:02下午 

------------------------------------
### 1. GET
iw是基于nl80211的无线设备CLI配置实用程序。


### 2. EXAMPLE
### 3. COMPILE
iw编译依赖于 libnl，需要先下载编译libnl库。	

	./configure  --prefix=$PWD/tmp
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
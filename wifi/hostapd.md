### hostapd source code

hostapd的功能是作为AP的认证服务器，负责控制管理STA的接入和认证。

由于hostapd提供的max_num_sta接口仅对单个ssid有效，因而我们需要对源码略作修改以满足需要。

hostapd比较重要的结构体

	struct hostapd_data{
	...
	int num_sta;
	...
	}
对任一ssid，均有num_sta。
ssid有两类，interface和bss。其数量分别为interfaces.count 与 num_bss.configs。
我们可以声明一个变量int all_sta_num
其值为所有num_sta之和。

在beacon.c中 

	void handle_probe_req(){
	...
	if (!sta && hapd->num_sta >= hapd->conf->max_num_sta)
		wpa_printf(MSG_MSGDUMP, "Probe Request from " MACSTR " ignored,"
		" too many connected stations.", MAC2STR(mgmt->sa));		
		
	...
	}
我们可以增加判断 &&all_sta_num>=hapd->conf->max_all_num_sta

需要在hostapd-phy.conf中定义max_all_num_sta
### hostapd source code

hostapd的功能是作为AP的认证服务器，负责控制管理STA的接入和认证。

在实现中hostapd提供了num_sta 和max_num_sta来对单个无线网络连接的sta数量进行限制。

由于hostapd提供的max_num_sta接口仅对单个iface/bss有效，因而我们需要对源码略作修改来增加全部ap的sta连接数量限制。

hostapd比较重要的结构体

	struct hostapd_data{
	...
	struct hostapd_iface *iface;
	
	int num_sta;
	...
	}
	
以及
	
	struct hostapd_iface{
	}
对任一iface/bss，均有num_sta。

我们可以声明一个globe变量int all_sta_num
或者在hostapd_iface中增加 int all_sta_num

在beacon.c中 

	void handle_probe_req(){
	...
		if (!sta && hapd->num_sta >= hapd->conf->max_num_sta)
			wpa_printf(MSG_MSGDUMP, "Probe Request from " MACSTR " ignored,"
			" too many connected stations.", MAC2STR(mgmt->sa));		
	
	...
	}
	
在sta_info.c中
	
	struct sta_info * ap_sta_add(struct hostapd_data *hapd, const u8 *addr){
	...
		if (hapd->num_sta >= hapd->conf->max_num_sta) {
			wpa_printf(MSG_DEBUG, "no more room for new STAs (%d/%d)",
				hapd->num_sta, hapd->conf->max_num_sta);
			return NULL;
			}
			//following is the zallocing memory of sta.
	...
		hapd->num_sta++;
		//hapd->iface_all_num_sta++；
	}
	
	void ap_free_sta(struct hostapd_data *hapd, struct sta_info *sta){
	...
		hapd->num_sta--;
		//hapd->iface->all_num_sta--;
	...
	}

我们可以增加判断
	
	 || hapd->iface->all_sta_num>=hapd->conf->max_all_num_sta

需要在hostapd-phy.conf中定义max_all_num_sta,并在hostapd_iface中定义params: all_sta_num。

 all_sta_num对sta数量进行count。
 
 编译运行失败，更换patch方式后运行成功。
 
 	备份code
 	make package/network/services/hostapd/{clean,prepare} QUILT=1
 	make package/network/services/hostapd/update
 	cd build_dir/target-mipsel_mips-interAptiv_uClibc-0.9.33.2/hostapd-mini/hostapd-2015-03-25
 	quilt series
 	quilt new 731-support-device-max-num-sta.patch
 	quilt add ./src/ap/ap_config.c
 	quilt add ./src/ap/ap_config.h
 	quilt add ./src/ap/beacon.c
 	...
 	cp code（备份的）to its path
 	quilt refresh
 	cd -
 	make package/network/services/hostapd/update
 	//if success （package/network/services/hostapd/patches/731-support-device-max-num-sta.patch）is exists
 	make
 	
 	
 之后验证即可
 	
 	
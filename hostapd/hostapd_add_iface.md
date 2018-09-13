## INIT
**啊，我脑壳痛。**
总的流程一时半会儿有点头痛，为了缓解于是随便找个地方慢慢看下。
下面是对add_iface的分析。
	
	static void hostapd_global_ctrl_iface_receive(int sock, void *eloop_ctx,
					void *sock_ctx)
	{
		......
	
		} else if (os_strncmp(buf, "ADD ", 4) == 0) {
			if (hostapd_ctrl_iface_add(interfaces, buf + 4) < 0)
				reply_len = -1;
		......
	}
	
	static int hostapd_ctrl_iface_add(struct hapd_interfaces *interfaces,
					char *buf)
	
	int hostapd_add_iface(struct hapd_interfaces *interfaces, char *buf) {
		......     
	if (os_strncmp(buf, "bss_config=", 11) == 0) { 
		//bss_config ???
		hapd_iface = hostapd_interface_init_bss(interfaces, phy_name, 
						conf_file, 0);
		//此处新增了一个bss，num_bss++
		for (j = 0; j < interfaces->count; j++) {
			if (interfaces->iface[j] == hapd_iface)
				break;//取得j的值以便下面进行判断
		}
		if (j == interfaces->count) {
			//判断是否新增了iface，如果新增了则进行处理
			interfaces->iface[interfaces->count++] = hapd_iface;
			new_iface = hapd_iface;
			//对new_iface赋值下面用作flag
		}
		if (new_iface) {
			//是否新增了iface，如果新增了，对新增的iface
			if (hostapd_setup_interface(hapd_iface)) {
				//对新增的iface进行setup
			}
		} else {
			//没有新增iface的情况下
			hapd = hapd_iface->bss[hapd_iface->num_bss - 1];
			//hapd赋值为新增的bss，后面进行setup
			
			if (start_ctrl_iface_bss(hapd) < 0 ||  
				(hapd_iface->state == HAPD_IFACE_ENABLED && 
					 hostapd_setup_bss(hapd, -1))) {
					 	// setup
					 ......
					 }
				}
				hostapd_owe_update_trans(hapd_iface);
				return 0;
			}
			......
	}
	
	
	
-------------------------------------
		 /**
  	2383  * hostapd_interface_init_bss - Read configuration file and init BSS data 
  	2384  * 
  	2385  * This function is used to parse configuration file for a BSS. This BSS is 
  	2386  * added to an existing interface sharing the same radio (if any) or a new 
  	2387  * interface is created if this is the first interface on a radio. This
 	2388  * allocate memory for the BSS. No actual driver operations are started.
  	2389  *
  	2390  * This is similar to hostapd_interface_init(), but for a case where the
  	2391  * configuration is used to add a single BSS instead of all BSSes for a radio.
  	2392  */ 
  	//如果新增的是iface，则为这个新的interface初始化一个bss(bss[0])否则对已有radio(interface)
  	//添加一个新的bss。 可以看到函数体中有num_bss++出现

	struct hostapd_iface *
	hostapd_interface_init_bss(struct hapd_interfaces *interfaces, const char *phy,
					const char *config_fname, int debug)
	{
		struct hostapd_iface *new_iface = NULL, *iface = NULL;
		struct hostapd_data *hapd;
		int k;
		size_t i, bss_idx;
		
		for (i = 0; i < interfaces->count; i++) {         
			if (os_strcmp(interfaces->iface[i]->phy, phy) == 0) { 
				iface = interfaces->iface[i];
				break; //通过phy去找到interface
			}
		}
		
		if (iface) { 
			......
			/* Add new BSS to existing iface */ 
			bss = iface->conf->bss[iface->conf->num_bss] = conf->bss[0];
			iface->conf->num_bss++; 
			
			hapd = hostapd_alloc_bss_data(iface, iface->conf, bss);
			iface->conf->last_bss = bss;
			iface->bss[iface->num_bss] = hapd;
			hapd->msg_ctx = hapd;
			
			bss_idx = iface->num_bss++; //bss++
			conf->num_bss--;
			conf->bss[0] = NULL;
			hostapd_config_free(conf);
		} else {
			/* Add a new iface with the first BSS */
			new_iface = iface = hostapd_init(interfaces, config_fname);
			if (!iface)
				return NULL;
			os_strlcpy(iface->phy, phy, sizeof(iface->phy));
			iface->interfaces = interfaces;
			bss_idx = 0;
		}
		......
		return iface;
	}

		
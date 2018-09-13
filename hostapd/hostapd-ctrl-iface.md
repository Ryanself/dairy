## hostapd-ctrl-iface

由于迟迟未能解决bss配置独立的问题，决定从hostapd的iface-remove入手，详细了解iface-remove的整个流程。

#question 1
**hostapd_ctrl_iface_init
hostapd_global_ctrl_iface_init**
-------------------------
	int hostapd_global_ctrl_iface_init(struct hapd_interfaces *interface)
	int hostapd_ctrl_iface_init(struct hostapd_data *hapd)
	#define HOSTAPD_CTRL_IFACE_PORT¦¦       8877
	#define HOSTAPD_GLOBAL_CTRL_IFACE_PORT¦ ¦       8878



	hostapd_global_ctrl_iface_receive
	
	  4046 ¦       } else if (os_strncmp(buf, "REMOVE ", 7) == 0) {
  	  4047 ¦       ¦       if (hostapd_ctrl_iface_remove(interfaces, buf + 7) < 0)

	
	  3655 static int hostapd_ctrl_iface_remove(struct hapd_interfaces *interfaces,
 	  3656 ¦       ¦       ¦       ¦            char *buf)

		hostapd_remove_iface(interfaces, buf)

------------------------------------------

	  2982 int hostapd_remove_iface(struct hapd_interfaces *interfaces, char *buf)
	  2983 {
	  2984 ¦       struct hostapd_iface *hapd_iface;
	  2985 ¦       size_t i, j, k = 0;
	  2986 
	  2987 ¦       for (i = 0; i < interfaces->count; i++) {
	  2988 ¦       ¦       hapd_iface = interfaces->iface[i];
   	  2989 ¦       ¦       if (hapd_iface == NULL)
	  2990 ¦       ¦       ¦       return -1;
	  2991 ¦       ¦       if (!os_strcmp(hapd_iface->conf->bss[0]->iface, buf)) {
	  2992 ¦       ¦       ¦       wpa_printf(MSG_INFO, "Remove interface '%s'", buf);
	  2993 ¦       ¦       ¦       hapd_iface->driver_ap_teardown =
	  2994 ¦       ¦       ¦       ¦       !!(hapd_iface->drv_flags &
 	  2995 ¦       ¦       ¦       ¦          WPA_DRIVER_FLAGS_AP_TEARDOWN_SUPPORT);
	  2996 					//删除bss[0]则执行删除interface
	  2997 ¦       ¦       ¦       hostapd_interface_deinit_free(hapd_iface);
	  2998 ¦       ¦       ¦       k = i;
	  2999 ¦       ¦       ¦       while (k < (interfaces->count - 1)) {
	  3000 ¦       ¦       ¦       ¦       interfaces->iface[k] =
	  3001 ¦       ¦       ¦       ¦       ¦       interfaces->iface[k + 1];
	  3002 ¦       ¦       ¦       ¦       k++;
	  3003 ¦       ¦       ¦       }
	  3004 ¦       ¦       ¦       interfaces->count--; //remove后校正次序
	  3005 ¦       ¦       ¦       return 0;
	  3006 ¦       ¦       }
	  3007 				   // 否则删除的为bss
	  3008 ¦       ¦       for (j = 0; j < hapd_iface->conf->num_bss; j++) {
	  3009 ¦       ¦       ¦       if (!os_strcmp(hapd_iface->conf->bss[j]->iface, buf)) {
	  3010 ¦       ¦       ¦       ¦       hapd_iface->driver_ap_teardown =
	  3011 ¦       ¦       ¦       ¦       ¦       !(hapd_iface->drv_flags &
	  3012 ¦       ¦       ¦       ¦       ¦         WPA_DRIVER_FLAGS_AP_TEARDOWN_SUPPORT);
	  3013 ¦       ¦       ¦       ¦       return hostapd_remove_bss(hapd_iface, j);
	  3014 ¦       ¦       ¦       } //remove bss
	  3015 ¦       ¦       }
	  3016 ¦       }
	  3017 ¦       return -1;
	  3018 }

--------------------------------
	//不知道写个reload_bss行不行的通
	  int hostapd_reload_iface(struct hostapd_iface *hapd_iface)
 	{
	  ¦       size_t j;
  
	  ¦       wpa_printf(MSG_DEBUG, "Reload interface %s",
 	  ¦       ¦          hapd_iface->conf->bss[0]->iface);
	  ¦       for (j = 0; j < hapd_iface->num_bss; j++) 
	  ¦       ¦       hostapd_set_security_params(hapd_iface->conf->bss[j], 1);
	  ¦       if (hostapd_config_check(hapd_iface->conf, 1) < 0) { 
	  ¦       ¦       wpa_printf(MSG_ERROR, "Updated configuration is invalid");
	  ¦       ¦       return -1;
	  ¦       }
	  ¦       hostapd_clear_old(hapd_iface);
 	  ¦       for (j = 0; j < hapd_iface->num_bss; j++) 
	  ¦       ¦       hostapd_reload_bss(hapd_iface->bss[j]);
 	
	  ¦       return 0;
	  }
----------------------------------------------
	
	int hostapd_config_check(struct hostapd_config *conf, int full_config)
	{
		......
		for (i = 0; i < conf->num_bss; i++) {
			if (hostapd_config_check_bss(conf->bss[i], conf, full_config))
				return -1;
			}
		}
		......
	}
-------------------------------------
	
	void hostapd_set_security_params(struct hostapd_bss_config *bss,
					int full_config)
					
----------------------------------
	
	  static void hostapd_clear_old(struct hostapd_iface *iface)
	  {
	  ¦       size_t j;
  
	  ¦       /*
	  ¦        * Deauthenticate all stations since the new configuration may not
	  ¦        * allow them to use the BSS anymore.
	  ¦        */ 
	  ¦       for (j = 0; j < iface->num_bss; j++) {
	  ¦       ¦       hostapd_flush_old_stations(iface->bss[j],
	  ¦       ¦       ¦       ¦       ¦          WLAN_REASON_PREV_AUTH_NOT_VALID);
	  ¦       ¦       hostapd_broadcast_wep_clear(iface->bss[j]);
  
	  #ifndef CONFIG_NO_RADIUS
	  ¦       ¦       /* TODO: update dynamic data based on changed configuration
	  ¦       ¦        * items (e.g., open/close sockets, etc.) */
	  ¦       ¦       radius_client_flush(iface->bss[j]->radius, 0);
	  #endif /* CONFIG_NO_RADIUS */
	  ¦       }
	  }
	
------------------------------------------------


	

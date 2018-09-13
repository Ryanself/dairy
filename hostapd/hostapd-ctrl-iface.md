## hostapd-ctrl-iface

由于迟迟未能解决bss配置独立的问题，决定从hostapd的bss-remove入手，详细了解bss-remove的整个流程。

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
		
		
		   157 static void hostapd_clear_old(struct hostapd_iface *iface)
   158 {
   159 ¦       size_t j;
   160 
   161 ¦       /*
   162 ¦        * Deauthenticate all stations since the new configuration may not
   163 ¦        * allow them to use the BSS anymore.
   164 ¦        */
   165 ¦       for (j = 0; j < iface->num_bss; j++) {
   166 ¦       ¦       hostapd_flush_old_stations(iface->bss[j],
   167 ¦       ¦       ¦       ¦       ¦          WLAN_REASON_PREV_AUTH_NOT_VALID);
   168 ¦       ¦       hostapd_broadcast_wep_clear(iface->bss[j]);
   169 
   170 #ifndef CONFIG_NO_RADIUS
   171 ¦       ¦       /* TODO: update dynamic data based on changed configuration
   172 ¦       ¦        * items (e.g., open/close sockets, etc.) */
   173 ¦       ¦       radius_client_flush(iface->bss[j]->radius, 0);
   174 #endif /* CONFIG_NO_RADIUS */
   175 ¦       }
   176 }

## reload_bss
对单个bss重载配置，但不影响其他bss 
	 
	  1426 static int hostapd_ctrl_bss_reload(struct hostapd_data *hapd)
	  1427 {
	  1428 ¦       size_t j;
	  1429 ¦       for(j = 0;j < hapd->iface->num_bss; j++)
	  1430 ¦             if(!os_strcmp(hapd->iface->bss[j]->conf->iface, hapd->conf->iface)){
	  1431 ¦       ¦             if(hostapd_reload_bss_config(hapd, j) < 0) {
	  1432 ¦       ¦       ¦             wpa_printf(MSG_ERROR, "Reloading of bss failed");
	  1433 ¦       ¦       ¦             return -1;
	  1434 ¦       ¦             }
	  1435 ¦       ¦             return 0;
 	  1436 ¦             }
 	  1437 ¦       return -1;
	  1438 }


----------------------------

	 172 int hostapd_reload_bss_config(struct hostapd_data *hapd, size_t j)
	 173 {
	 174 ¦       struct hostapd_iface *iface = hapd->iface;
	 175 ¦       struct hostapd_config *newconf, *oldconf;
	 176 ¦       size_t i;
	 177 ¦       if (iface->config_fname == NULL) {
	 178 ¦       ¦       hostapd_clear_old_bss(hapd);
	 179 ¦       ¦       hostapd_reload_bss(hapd);
	 180 ¦       ¦       return 0;
	 181 ¦       }
	 182 
	 183 ¦       if (iface->interfaces == NULL ||iface->interfaces->config_read_cb == NULL)
	 184 ¦             return -1;
	 185 ¦       newconf = iface->interfaces->config_read_cb(iface->config_fname);
	 186 ¦       if (newconf == NULL)
	 187 ¦             return -1;
	 188 
	 189 ¦       hostapd_clear_old_bss(hapd);
	 190 
	 191 ¦       oldconf = hapd->iconf;
	 192 ¦       iface->conf = newconf;
	 193 
	 194 ¦       for (i = 0; i < iface->num_bss; i++) {
	 195 ¦       ¦       hapd = iface->bss[i];
	 196 ¦       ¦       hapd->iconf = newconf;
	 197 ¦       ¦       hapd->iconf->channel = oldconf->channel;
	 198 ¦       ¦       hapd->iconf->acs = oldconf->acs;
	 199 ¦       ¦       hapd->iconf->secondary_channel = oldconf->secondary_channel;
	 200 ¦       ¦       hapd->iconf->ieee80211n = oldconf->ieee80211n;
	 201 ¦       ¦       hapd->iconf->ieee80211ac = oldconf->ieee80211ac;
	 202 ¦       ¦       hapd->iconf->ht_capab = oldconf->ht_capab;
	 203 ¦       ¦       hapd->iconf->vht_capab = oldconf->vht_capab;
	 204 ¦       ¦       hapd->iconf->vht_oper_chwidth = oldconf->vht_oper_chwidth;
	 205 ¦       ¦       hapd->iconf->vht_oper_centr_freq_seg0_idx =
	 206 ¦       ¦       ¦       oldconf->vht_oper_centr_freq_seg0_idx;
	 207 ¦       ¦       hapd->iconf->vht_oper_centr_freq_seg1_idx =
	 208 ¦       ¦       ¦       oldconf->vht_oper_centr_freq_seg1_idx;
	 209 		         hapd->conf = newconf->bss[i]; 
	 210 ¦       ¦       hostapd_reload_bss(hapd);
	 211 ¦       }
	 212 ¦ 
	 213 
	 214 ¦       hostapd_config_free(oldconf);
	 215 
	 216 ¦       return 0;
	 217 }



在上面的改动下，修改了hostapd-conf文件后，对bss调用reload即可实现bss配置
更新，且不影响到其他bss，因为在clear时，我们仅对单个bss进行了clear。（此
刻我有点想尝试一下不clear的情况，不知道这种情况会发生什么结果。）

测试发现这种情况下同时存在了两个bss，即reload前和reload后的bss。（改动
ssid更容易分辨。当断开之前的bss连接后，reload前的bss消失。）
但二者其实是一个bss，只是由于无线beacon帧存在延迟。（推测）

接下来为了对接下层改动需要去修改netifd上层接口。
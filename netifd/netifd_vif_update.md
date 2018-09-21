wireless_device_run_handler	

  210 static struct uci_package *
  211 config_init_package(const char *config)
  212 {
  213 ¦       struct uci_context *ctx = uci_ctx;
  214 ¦       struct uci_package *p = NULL;
  215 
  216 ¦       if (!ctx) {
  217 ¦       ¦       ctx = uci_alloc_context();
  218 ¦       ¦       uci_ctx = ctx;
  219 
  220 ¦       ¦       ctx->flags &= ~UCI_FLAG_STRICT;
  221 ¦       ¦       if (config_path)
  222 ¦       ¦       ¦       uci_set_confdir(ctx, config_path);
  223 
  224 #ifdef DUMMY_MODE
  225 ¦       ¦       uci_set_savedir(ctx, "./tmp");
  226 #endif
  227 ¦       } else {
  228 ¦       ¦       p = uci_lookup_package(ctx, config);
  229 ¦       ¦       if (p)
  230 ¦       ¦       ¦       uci_unload(ctx, p);
  231 ¦       }
  232 
  233 ¦       if (uci_load(ctx, config, &p))
  234 ¦       ¦       return NULL;
  235 
  236 ¦       return p;
  237 }
  238 


 351 static void
  352 config_init_wireless(void)
  353 {
  354 ¦       struct wireless_device *wdev;
  355 ¦       struct uci_element *e;
  356 ¦       const char *dev_name;
  357 
  358 ¦       if (!uci_wireless) {
  359 ¦       ¦       DPRINTF("No wireless configuration found\n");
  360 ¦       ¦       return;
  361 ¦       }
  362 
  363 ¦       vlist_update(&wireless_devices);
  364 
  365 ¦       uci_foreach_element(&uci_wireless->sections, e) {
  366 ¦       ¦       struct uci_section *s = uci_to_section(e);
  367 ¦       ¦       if (strcmp(s->type, "wifi-device") != 0)
  368 ¦       ¦       ¦       continue;
  369 
  370 ¦       ¦       config_parse_wireless_device(s);
  371 ¦       }
  372 
  373 ¦       vlist_flush(&wireless_devices);
  374 
  375 ¦       vlist_for_each_element(&wireless_devices, wdev, node) {
  376 ¦       ¦       wdev->vif_idx = 0;
  377 ¦       ¦       vlist_update(&wdev->interfaces);
  378 ¦       }
  379 
  380 ¦       uci_foreach_element(&uci_wireless->sections, e) {
  381 ¦       ¦       struct uci_section *s = uci_to_section(e);
  382 
  383 ¦       ¦       if (strcmp(s->type, "wifi-iface") != 0)
  384 ¦       ¦       ¦       continue;
  385 
  386 ¦       ¦       dev_name = uci_lookup_option_string(uci_ctx, s, "device");
  387 ¦       ¦       if (!dev_name)
  388 ¦       ¦       ¦       continue;
  389 
  390 ¦       ¦       wdev = vlist_find(&wireless_devices, dev_name, wdev, node);
  391 ¦       ¦       if (!wdev) {
  392 ¦       ¦       ¦       DPRINTF("device %s not found!\n", dev_name);
  393 ¦       ¦       ¦       continue;
  394 ¦       ¦       }
  395 
  396 ¦       ¦       config_parse_wireless_interface(wdev, s);


--------------------
	path: scripts/netifd-wireless.sh 
	
	init_wireless_driver()
	->
	init_wireless_driver "$@"
	->
	drv_mac80211_reload interface
	
	
	
目前想法是通过vif_update调用wireless_iface_update_handler(需要实现)
然后转入mac80211.sh。
wdev数据不更新，是否有影响。

free(config)的问题。
fork 一个子进程去执行execvp
然后父进程free config？

wireless_iface_run_handler

遇到一个比较有意思的东西
execvp，之后再详细写。

	lua
	->
	sleep 1; env -i; 
	ubus call network reload ;
	wifi reload_legacy;
	sleep 3; 
	gwifi start

	wifi_updown() {
        cmd=down
        [ enable = "$1" ] && {
                _wifi_updown disable "$2"
                ubus_wifi_cmd "$cmd" "$2"
                scan_wifi
                cmd=up
        }
        ubus_wifi_cmd "$cmd" "$2"
        _wifi_updown "$@"
	}


	wifi_reload_legacy() {
        _wifi_updown "disable" "$1"
        scan_wifi
        _wifi_updown "enable" "$1"
	}




	gwifi_start(){
        local section=$1
        local index=$2
        local time=$(uci -q get wireless.@wifi-iface[$section].limittime)
        local iface_dis=1

        if [ "x$time" = "xtrue" ];then
                local timetype=$(uci -q  get wireless.@wifi-iface[$section].limittimetype)
                if [ "x$timetype" = "x1" ];then
                        local time=$(uci -q get wireless.@wifi-iface[$section].periodicaltime)
                        local now_week=$(date +%u)
                        local now=$(date +%s)
                        for ptime in $time
                        do
                                eval $(echo $ptime | awk -F ',' '{print "starttime=\"" $1 "\";stoptime=\"" $2 "\"" ";week=" $3}')
                                echo "0 $starttime * * $week gwifi restart $index" >> $CRONFILE
                                if [ "x$stoptime" = "x0" ];then
                                        echo "59 23 * * $week gwifi stop $index" >> $CRONFILE
                                else
                                        echo "0 $stoptime * * $week gwifi stop $index" >> $CRONFILE
                                fi

                                if [ "x$now_week" = "x$week" ]; then
                                        sec1=$(date -d $starttime:00:00 +%s)
                                        if [ "x$stoptime" = "x0" ];then
                                                sec2=$(date -d 23:59:59 +%s)
                                        else
                                                sec2=$(date -d $stoptime:00:00 +%s)
                                        fi
                                        if [ $now -ge $((sec1-$WTIME)) -a $now -lt $((sec2-$WTIME)) ];then
                                                iface_dis=0
                                        fi
                                fi
                        done
                        uci set wireless.@wifi-iface[$section].disabled=$iface_dis
                        uci commit
                elif [ "x$timetype" = "x0" ];then
                        local rtime=$(uci -q get wireless.@wifi-iface[$section].remainingtime)
                        local sec=$(($(date +%s) + ${rtime}*60*60))
                        local oncetime=$(date -d "@$sec" +"%M %H %d %m")
                        echo "$oncetime * gwifi stop_once $index" >> $CRONFILE
                fi
        fi
}


通过加log得知
在wireless_interface_create
->vlist_add(&wdev->interfaces, &vif->node, vif->name);
会转到vlist_update
从而完成调用mac80211.sh

需要先修改lua文件	

然后修改对应vif_update、mac80211.sh/netifd-wirelsss.sh即可

	path: package/siflower/luci-siflower/modules/luci-mod-admin-full/luasrc/controller/admin/wirelessnew.lua
	
mac80211.sh 以及vif_update的netifd处理好烦zzzz
## wireless_device_run_handler	

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
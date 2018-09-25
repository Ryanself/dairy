## wireless_device_run_handler	

--------------------
	path: scripts/netifd-wireless.sh 
	
	init_wireless_driver()
	->
	init_wireless_driver "$@"
	->
	drv_mac80211_reload $interface
	
	
	
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



vif_update 有3种处理，分别是add/remove/update(iface)
最终调用的都是wdev_set_config_state(wdev, IFC_RELOAD);从而转到drv_mac80211_xx()
由于此种方法会把hostapd进程teardown掉，造成一个bss更新config会影响到同一个phy下的其他bss。
因此我们修改了其中update的调用。

wdev_set_config_state最后调用到wireless_device_run_handler()
在该handler中首先填充了一个字符数组argv[6]，然后fork了一个子进程，并将argv通过管道传入子进程。
子进程中通过execvp来对argv进行解析并转入shell脚本进行执行。
我们修改了argv在填充时action的值，同时在shell脚本中增加了对应的处理。
由于execvp调用时argv最后一位必须为null，我们重新定义了新的argv[7],多出的一位用来存储bss的ifname。
在shell脚本中通过ifname来调用hostapd_cli 进行reload 操作，这种情况下可以实现bss之间配置的独立。



对netifd-wireless.sh的修改

	init_wireless_driver() {
	¦       name="$1"; shift
	¦       cmd="$1"; shift
	
	¦       case "$cmd" in
	¦       ¦       dump)
	......
	¦       ¦       ;;
	¦       ¦       setup|teardown|reload)
	¦       ¦       ¦       interface="$1"; shift
	¦       ¦       ¦       data="$1"; shift
	¦       ¦       ¦       [[ "$cmd" == "reload" ]] && wiface="$1"; shift
	¦       ¦       ¦       export __netifd_device="$interface"

	¦       ¦       ¦       add_driver() {
	¦       ¦       ¦       ¦       [[ "$name" == "$1" ]] || return 0
	¦       ¦       ¦       ¦       _wdev_handler "$1" "$cmd"
	¦       ¦       ¦       }
	¦       ¦       ;;
	¦       esac
	}

增加了reload，其中wiface赋值为iface->ifname
_wdev_handler "$1" "cmd"会调用到drv_$1_cmd参数为$interface。因此我们需要在mac80211.sh中增加
drv_mac80211_reload()来进行处理。drv_mac80211_reload()与drv_mac80211_setup()大体类似，最主
要的改变是
	
	  732 ¦       [ -n "$hostapd_ctrl" ] && {
	  733 ¦       ¦       /etc/hostapd_cli -i $wiface reload
	  734 ¦       }
我们又见到了熟悉的$wiface。之前我们已经修改了hostapd_cli中reload的具体实现，现在该命令调用
hostapd_cli来进行reload操作，从而避免了hostapd进程的重启。

目前主要问题：
	netifd中同时涉及了iface和wireless_interface的处理，稍显复杂。在简单的实现功能后，使用logread
	命令进行查看发现虽然可以正常上网但是一直报ioctrl错误
	
	 daemon.warn dnsmasq[3217]: ioctl error.
	 daemon.warn dnsmasq[3217]: ioctl error.
	 
想来是在修改vif_update中的处理时出现了遗漏，目前正在定位修改中。


	
	
	
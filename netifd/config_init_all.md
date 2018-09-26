	config_init_all(void)    
		......
		config_init = true; 
		device_lock();
		
		device_reset_config()
		
		config_init_devices();
		
		config_init_interfaces();
		
	¦       config_init_routes();
  	¦       config_init_rules();
  	¦       config_init_globals();
  	¦       config_init_wireless();
  	¦       config_init = false;
  	¦       device_unlock();

 	¦       device_reset_old();
   	¦       device_init_pending();
   	¦       vlist_flush(&interfaces);
  	¦       device_free_unused(NULL);
 	¦       interface_refresh_assignments(false);
 	        interface_start_pending();
  	¦       wireless_start_pending();

		
	}
	
	
	
	
	void
	device_reset_config(void)
  	{
 	 ¦       struct device *dev;

	 ¦       avl_for_each_element(&devices, dev, avl)
  	 ¦       ¦       dev->current_config = false;
 	 }
	
	
	static void
  	config_init_interfaces(void)
 	 {
 	  ¦       struct uci_element *e; 

	  ¦       uci_foreach_element(&uci_network->sections, e) {
	  ¦       ¦       struct uci_section *s = uci_to_section(e);
  
	  ¦       ¦       if (!strcmp(s->type, "interface"))
	  ¦       ¦       ¦       config_parse_interface(s, false);
	  ¦       }
  
	  ¦       uci_foreach_element(&uci_network->sections, e) {
	  ¦       ¦       struct uci_section *s = uci_to_section(e);
	  
	  ¦       ¦       if (!strcmp(s->type, "alias"))
	  ¦       ¦       ¦       config_parse_interface(s, true);
	  ¦       }
	  }
  

	wifi_reload_legacy() {
        _wifi_updown "disable" "$1"
        scan_wifi
        _wifi_updown "enable" "$1"
	}

	_wifi_updown() {
        for device in ${2:-$DEVICES}; do (
                config_get disabled "$device" disabled
                [ "$disabled" = "1" ] && {
                        echo "'$device' is disabled"
                        set disable
                }
                config_get iftype "$device" type
                if eval "type ${1}_$iftype" 2>/dev/null >/dev/null; then
                        eval "scan_$iftype '$device'"
                        eval "${1}_$iftype '$device'" || echo "$device($iftype): ${1} failed"
                elif [ ! -f /lib/netifd/wireless/$iftype.sh ]; then
                        echo "$device($iftype): Interface type not supported"
                fi
        ); done
	}


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
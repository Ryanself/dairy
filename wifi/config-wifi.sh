#!/bin/sh
echo "setup wifi "

set_master(){
	if [ $3 == 111 ];then
		apiso=1
		encr="psk2+ccmp"
		enc0="          Encryption: WPA2 PSK (CCMP)"
		apmode="ap"
		mod0="	type AP"
	else
		apiso=0
		encr="Open"
		enc0="          Encryption: none"
		apmode="sta"
		mod0="	type managed"
	fi

	if [ $1 == 1    ];then
	       a=0
	else
	       a=1
	fi

	case "$2" in
		1)
			uci set wireless.@wifi-iface[$1].ap_isolate="$apiso"
			apis0="ap_isolate=$apiso"
			;;
		2)
			#uci set wireless.@wifi-iface[$1].network='lan'
			;;
		3)
			uci set wireless.@wifi-iface[$1].encryption="psk2+ccmp"
			uci set wireless.@wifi-iface[$1].key="12345678$3"
			psd0="wpa_passphrase=12345678$3"
			;;
		4)
			uci set wireless.@wifi-iface[$1].ssid="wlan${a}-guest-$3"
			ssid0="wlan${a}-guest ESSID: \"wlan${a}-guest-$3\""
			;;
		5)
			uci set wireless.@wifi-iface[$1].encryption="$encr"
			;;
		6)
			uci set wireless.@wifi-iface[$1].mode="$apmode"
			;;
	esac
	uci commit wireless
	/sbin/wifi reload
	sleep 3


	case "$2" in
		1)
			apis=`cat /var/run/hostapd-phy${a}.conf | grep wlan${a}-guest -A 9 | grep ap_is`
			if [ "$apis" != "$apis0" ];then
				echo "ap_isolate set failed: error "
			fi
			;;
		2)

			;;
		3)
			psd=`cat /var/run/hostapd-phy${a}.conf | grep wlan${a}-guest -A 9 | grep wpa_pas`
			if [ "$psd" != "$psd0" ];then
				echo "psd set failed: error"
			fi
			;;
		4)
			ssid=`iwinfo | grep wlan${a}-guest`
			if [ "$ssid" != "$ssid0" ];then
				echo "ssid set failed: error"
			fi
			;;
		5)
			enc=`iwinfo | grep wlan${a}-guest -A 9 | grep Enc`
			if [ "$enc" != "$enc0" ];then
				echo "Encrption set failed: error"
				echo "$enc"
				echo "$enc0"
			fi
			;;
		6)
			sleep 2
			mod=`iw wlan${a}-guest info | grep type`
			if [ "$mod" != "$mod0" ];then
				echo "mode set failed: error"
				echo "$mod"
				echo "$mod0"
			fi
			;;
	esac

}
num=1
i=1
test_time=0
while [ "$num" -gt 0 ]
do	let "test_time++"
	echo "$test_time"
	if [ $i -gt 6 ];then
		i=1
		echo "$i"
	fi
	set_master 1 $i 111
	set_master 4 $i 111
	let "i++"
	echo "$i"
	set_master 1 $i 222
	set_master 4 $i 222
done

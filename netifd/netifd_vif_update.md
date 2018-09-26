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
	#wifi reload_legacy; //此句不需再调用
	sleep 3; 
	gwifi start


通过加log得知
在wireless_interface_create
->vlist_add(&wdev->interfaces, &vif->node, vif->name);
会转到vlist_update
从而完成调用mac80211.sh

需要先修改lua文件	

然后修改对应vif_update、mac80211.sh/netifd-wirelsss.sh即可

	path: package/siflower/luci-siflower/modules/luci-mod-admin-full/luasrc/controller/admin/wirelessnew.lua
	
mac80211.sh 以及vif_update的netifd处理好烦zzzz

**修改路线：**

	path: wireless.c
	vif_update()
	->iface_set_config_state(vif_old, IFC_RELOAD);
	->wireless_iface_run_handler(iface, true);
	
	path: script/netifd-wireless.sh
	init_wireless_driver()
	
	path: package/kernel/mac80211/files/lib/netifd/wireless/mac80211.sh
	drv_mac80211_reload()
	

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

## 目前主要问题：
	1. netifd中同时涉及了iface和wireless_interface的处理，稍显复杂。在简单的实现功能后，发现
	
	在信道设置为静态时，测试成功
	在信道设置为auto时，测试成功
	在信道设置为静态时切换到auto，测试失败
	
由于仅测试了一次目前还不具可信度。后续继续测试修改中。

-------------------------------
	2. 在2.4g 和5g下单独测试修改ssid均成功。
	当guest 2.4g开启而5g关闭时，打开5g，此时测试失败。./sbin/wifi 后测试成功。
	
综上，当进行network级别的操作而不进行重置时会造成失败。查看log并未触发vif_update函数。

------------------------------------
	3. 测试只能设置一次，第二次设置无法触发vif_update。
原因应该与问题1相同。

推测为某状态未传递、同步。
wdev->state
wdev->config_state 
wdev->autostart

## QUESTION

目前主要问题在vif_update最开始的处理

	1. 设置开启或禁用5g时，仅对phy1做了重置，应该有某参数状态未及时传递，造成测试无法成功。
2. 设置信道时，未调用任何update，仅做了apply update处理。

        --nixio.syslog("crit", myprint(ifaces))
        local changes = network:changes()
        if((changes ~= nil) and (type(changes) == "table") and (next(changes) ~= nil)) then
                nixio.syslog("crit","apply changes")
                network:save("wireless")
                network:commit("wireless")
                sysutil.fork_exec("sleep 1; env -i; ubus call network reload ; wifi reload_legacy")
        end

	
	
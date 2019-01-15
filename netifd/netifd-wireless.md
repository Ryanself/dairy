netifd：
=======

之前写过netifd相关的知识，只是当时对netifd中的wireless以及其对脚本以及ubus的调用没有现在熟悉。所以再次梳理一下。
当然这种梳理并不会对以后的学习有太大的帮助，但是总结还是必要的。

wireless.c 中的方法调用主要来源于3个方面，其实也可简单分为两个方面。
1. config.c 中的config_init_wireless()。
好吧，现在我不想给它们分类了。
config_wireless_init()将ap节点进行遍历，并判断是否有更新vlist_update，从而进入wireless.c开始调用。
wireless.c主要路线为两条，一条setup，另一条为teardown。

##　setup
setup主要做的事情是将config传入脚本mac80211.sh，调用drv_mac80211_setup，然后启动hostapd进程并add_process（ubus调用）回到wireless中的add_process，并将所加的进程加入一个loop循环中进行不断检测，防止其自己挂掉。

## teardown
teardown做的事情很类似，不过完全相反而已。teardown设置好wdev的state，然后传入config，来kill掉所有process。如果不设置state的话，在kill之后，由于setup加入的loop机制，会再次把该process重新setup。

而一切vif_update和wdev_update都会调用到wdev_config_state_handler,结果就是teardown setup。
为了实现在setup一个sta(wpa_supplicant support)时不使hostapd重启，需要修改vif_update。

sta从disable到enable状态（通过wireless修改配置，然后调用wifi reload），会首先进入vif_update的if(new)判断，然后处理。
通过修改此处调用，并设置wdev->state = IFS_REP（正常状态为IFS_UP），直到wireless_device_run_handler()传入repeater作为action的值。此后会调用我们在mac8011.sh中写好的drv_mac80211_repeater方法。
该方法主要做了两件事，一，解析wireless配置并启动wpa_supplicant。二，在通过ubus在netifd中add_process 和 mark_up(设置wdev->state=IFS_UP，并调用interface_handle_link(vif, true)。

至于teardown，还是一样。






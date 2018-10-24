src/ap/hsotapd.c
src/ap/ap_config.h
ipkg-mips_siflower/hostapd-common/lib/netifd/hostapd.sh
hostapd/config_file.c
1. enable_iface
2. disable_iface
state_change->
bss_set_state
->set drv_priv
->1 /2 
->setup_iface /deinit_iface
------------------------
### 1.
在学习`hostapd`与`netifd`机制时，我们通过web端的lua-uci传递参数到`netifd/wireless.c`中的iface中，然后
通过传递`argv`到`mac80211.sh`来调用`hostapd_cli`。
在向`mac80211.sh`传递时，大体操作只有3个

	reload/setup/teardown
很多操作被集成在`reload`中，最后调用`hohostapd_setup_bssstapd`的`hostapd_reload_bss_config`
来进行统一操作。
`reload_bss_config`更多的是读取`config`文件重载bss来达到更新配置实现所需操作的目的。在随后的修改
中，我们又不断在reload中增加if判断，来让reload_bss_config能够处理尽可能多的操作。
比如我们增加的`state`判断，试图通过判断`state`状态来完成wifi的开关配置分离。

回到最初，`hostapd`本身是`host-ap`的守护进程，更多的是守护ap和sta之间的连接关系。通过`main`函数
的运行来启动`hostapd`，然后通过传达cmd和配置来创建bss。
`hostapd_cli`同样为类似结构，不过其守护的为`hostapd`，实现了很多控制`hostapd`的
函数方法。通过传入的不同命令来进行操作。

在学习`hostapd`的时，考虑到在更新配置对bss进行操作时，应尽可能的将命令分开，其实这在某种程度
上是在对`hostapd_cli`打`patch`或者说建立一个新的控制途径，来完成对`bss`的操作。如果将不同的操作更
加细分，这样在传入命令时有着更精细的要求，这种某种程度上又涉及到了增加配置文件的增量更新处
理。

由于对`hostapd`的`setup_inteface`、`bss`中一些细节始终模糊，并未做太多其他实现。

---------------------------
### 2.
hostapd调用了nl80211的接口，比如对ap的设置set_ap：

在hostapd的hostapd_data结构体中，有driver属性。

	hostapd_data->driver.set_ap = wpa_driver_nl80211_set_ap
同上，hostapd的各种ops在
	
	path: src/drivers/driver_nl80211.c
中获得填充。然后通过nla_put将对应的cmd-msg发送到nl80211对应方法的实现上，从而实现对ap的各种操作。

**星期三, 17. 十月 2018 02:06下午 **


## netifd

看了一阵hostapd试图去解决问题，但是没有头绪。后来发现其实在更上层的netifd就存在着问题。所有的config change最终都导致 interface radio 0 teardown，因此造成所有interface、bss重启。
决定先熟悉一下netifd。脑壳痛。

	  enum interface_state {
	  ¦       IFS_SETUP,
	  ¦       IFS_UP,
	  ¦       IFS_TEARDOWN,
	  ¦       IFS_DOWN,
 	 };

	  enum interface_config_state {
	  ¦       IFC_NORMAL,
	  ¦       IFC_RELOAD,
	  ¦       IFC_REMOVE
	  };
------------------------------------------
**函数调用流程分析：**

	do: change ssid of bss.
	
	int main() /netifd_reload(void)
	config_init_all()
	config_init_wireless();
	config_parse_wireless_device()
	wireless_device_create(){
	...
	wdev->state = IFS_DOWN;
	wdev->config_state = IFC_NORMAL;
	...
	}
	->vlist_init(&wdev->interfaces, avl_strcmp, vif_update);
		->wdev_set_config_state(wdev, IFC_RELOAD);
		wdev->config_state = IFC_RELOAD;
		wdev->state == IFS_DOWN;
		->wdev_handle_config_change(wdev,true);
		
		
		wdev->state !== IFS_DOWN;
				->__wireless_device_set_down(wdev);
		
				
				interface_update()
				interface_change_config(if_old, if_new);
				
				
------------------------------------			
				
				wireless_interface_handle_link(vif_old, false)
				interface_handle_link(iface, vif->ifname, false, true);
				
				interface_remove_link	
				->device_remove_user()
				->device_release()
	 dev->type->name,  Network device
	 dev->ifname,  wlan2
	 dev->active 0
	 
	 			
	 			
				->device_set_present(wdev, false)
				
----------------------------------------

log

			Update interface 'lan'	
			Update wireless interface 1 on device radio0
			Release Network device wlan2, new active count: 0
			Remove user for device 'wlan2', refcount=0
			Network device 'wlan2' is no longer present
			Network device 'wlan2' is now present
			Wireless device 'radio0' run teardown handler
--------------------------------------------
		
			
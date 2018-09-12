

  enum interface_state {
  ¦       IFS_SETUP,
  ¦       IFS_UP,
  ¦       IFS_TEARDOWN,
  ¦       IFS_DOWN,
  };
}>
  enum interface_config_state {
  ¦       IFC_NORMAL,
  ¦       IFC_RELOAD,
  ¦       IFC_REMOVE
  };
8>


change ssid of bss.
	wireless_device_create
	->vlist_init(&wdev->interfaces, avl_strcmp, vif_update);
		->wdev_set_config_state(wdev, IFC_RELOAD);
		wdev->state !== IFS_DOWN;
				->__wireless_device_set_down(wdev);
				
				
				
				interface_update()
				interface_change_config(if_old, if_new);
				
				
				
				->device_release()
				
				
				->device_set_present(wdev, false)
				
				
				
				int main() /netifd_reload(void)
			config_init_all
			config_init_wireless();
			
			config_parse_wireless_device
			wireless_device_create
			vif_update
			
星期二, 11. 九月 2018 02:50下午 
	
	path: hostapd/main.c main()

	  734 ¦       interfaces.terminate_on_error = interfaces.count;
	  735 ¦       for (i = 0; i < interfaces.count; i++) {
	  736 ¦       ¦       if (hostapd_driver_init(interfaces.iface[i]) ||
	  737 ¦       ¦           hostapd_setup_interface(interfaces.iface[i]))
	  738 ¦       ¦       ¦       goto out;
	  739 ¦       }
	  740 
	  741 ¦       hostapd_global_ctrl_iface_init(&interfaces);
	  742 
   	  743 ¦       if (hostapd_global_run(&interfaces, daemonize, pid_file)) {
	  744 ¦       ¦       wpa_printf(MSG_ERROR, "Failed to start eloop");
	  745 ¦       ¦       goto out;
	  746 ¦       }
------------------------------

	path: netifd/wireless.c
	
	wdev_handle_config_change()
	
	
	wdev_update->
	wdev_change_config(struct wireless_device *wdev, struct wireless_device *wd_new)
	
	->wdev_set_config_state(wdev, IFC_RELOAD)
		
		->wdev->state == IFS_DOWN
		->wdev_handle_config_change(wdev,true)
			-> __wireless_device_set_up(wdev);drv_mac80211_setup
				->wireless_device_run_handler(wdev, true);
					->*action = "setup";
					 netifd_start_process(argv, NULL, &wdev->script_task);
		
	------------------------------------------------------------
		
		->!wdev->state == IFS_DOWN
		-> __wireless_device_set_down(wdev);
			->wireless_device_run_handler(wdev, false);
				->*action = "teardown"
				netifd_start_process(argv, NULL, &wdev->script_task);
				
--------------------------------------------
	shell流程
	path: mac80211.sh 
	
	path: scripts/netifd-wireless.sh
	init_wireless_driver "$@"
	->add_driver mac80211
		->_wdev_handler "$1" "$cmd"
			->eval "drv_$1_$2 \"$interface\""
				->drv_mac80211_setup/teardown
				
-------------------------
## modify


	
	 
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
  

	
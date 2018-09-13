## netifd_datastructure
	path: wireless.c
	
	struct wireless_device {
		struct vlist_node node;
	
		struct wireless_driver *drv;
		struct vlist_tree interfaces;
		char *name;
	
		struct netifd_process script_task;
		struct uloop_timeout timeout;
		struct uloop_timeout poll;
	
		struct list_head script_proc;
		struct uloop_fd script_proc_fd;
		struct uloop_timeout script_check;
	
		struct ubus_request_data *kill_request;
	
		struct blob_attr *prev_config;
		struct blob_attr *config;
		struct blob_attr *data;
	
		bool config_autostart;
		bool autostart;
		bool disabled;
	
		enum interface_state state;
		enum interface_config_state config_state;
		bool cancel;
		int retry;
	
		int vif_idx;
	};
	
--------------------------

	struct wireless_interface {
		struct vlist_node node;
		const char *section;
		char *name;
	
		struct wireless_device *wdev;
	
		struct blob_attr *config;
		struct blob_attr *data;
	
		const char *ifname;
		struct blob_attr *network;
		bool isolate;
		bool ap_mode;
	};
------------------------------------

	struct wireless_process {
		struct list_head list;

		const char *exe;
		int pid;

		bool required;
	};
	
------------------------------
	
	path: 
	
	
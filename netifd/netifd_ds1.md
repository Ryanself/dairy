## netifd_datastructure

由于netifd不仅兼容了实际的interface/dev和虚拟的interface，因此在结构体中包括
 device/wireless device interface/wireless interface。



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

	
------------------------------
	
	path: interface.h
	
	enum interface_state {
		IFS_SETUP,
		IFS_UP,
		IFS_TEARDOWN,
		IFS_DOWN,
	};

	enum interface_config_state {
		IFC_NORMAL,
		IFC_RELOAD,
		IFC_REMOVE
	};
	
-------------------------------
	
	83 active:
 	84   The interface can be brought up (its main device is available)
  	85 
  	86 autostart:
  	87   If the interface switches from inactive to active, netifd will attempt
  	88   to bring it up immediately. Manually setting an interface to up (regardless
  	89   of whether that was successful or not) will set this flag.
  	90 
  	91 state:
  	92   IFS_SETUP:
  	93     The interface is currently being configured by the protocol handler
  	94   IFS_UP:
  	95     The interface is fully configured
  	96   IFS_TEARDOWN:
  	97     The interface is being deconfigured
  	98   IFS_DOWN:
  	99     The interface is down
  
	/*
	 * interface configuration
	 */
	struct interface {
	
	struct vlist_node node;
	struct list_head hotplug_list;
	enum interface_event hotplug_ev;

	const char *name;
	const char *ifname;

	bool available;
	bool autostart;
	bool config_autostart;
	bool device_config;
	bool enabled;
	bool link_state;
	bool force_link;
	bool dynamic;
	bool policy_rules_set;

	time_t start_time;
	enum interface_state state;
	enum interface_config_state config_state;
	enum interface_update_flags updated;

	struct list_head users;

	/* for alias interface */
	const char *parent_ifname;
	struct interface_user parent_iface;

	/* main interface that the interface is bound to */
	struct device_user main_dev;
	struct device_user ext_dev;

	/* interface that layer 3 communication will go through */
	struct device_user l3_dev;

	struct blob_attr *config;

	/* primary protocol state */
	const struct proto_handler *proto_handler;
	struct interface_proto_state *proto;

	struct interface_ip_settings proto_ip;
	struct interface_ip_settings config_ip;
	struct vlist_tree host_routes;

	int metric;
	unsigned int ip4table;
	unsigned int ip6table;

	/* IPv6 assignment parameters */
	enum interface_id_selection_type assignment_iface_id_selection;
	struct in6_addr assignment_fixed_iface_id;
	uint8_t assignment_length;
	int32_t assignment_hint;
	struct list_head assignment_classes;

	/* errors/warnings while trying to bring up the interface */
	struct list_head errors;

	/* extra data provided by protocol handlers or modules */
	struct avl_tree data;

	struct uloop_timeout remove_timer;
	struct ubus_object ubus;
	};
	
----------------------------

	path: device.h
	
	struct device {
	const struct device_type *type;

	struct avl_node avl;
	struct safe_list users;
	struct safe_list aliases;

	char ifname[IFNAMSIZ + 1];
	int ifindex;

	struct blob_attr *config;
	bool config_pending;
	bool sys_present;
	/* DEV_EVENT_ADD */
	bool present;
	/* DEV_EVENT_UP */
	int active;
	/* DEV_EVENT_LINK_UP */
	bool link_active;

	bool external;
	bool disabled;
	bool deferred;
	bool hidden;

	bool current_config;
	bool iface_config;
	bool default_config;
	bool wireless;
	bool wireless_ap;
	bool wireless_isolate;

	struct interface *config_iface;
	/* set interface up or down */
	device_state_cb set_state;

	const struct device_hotplug_ops *hotplug_ops;

	struct device_user parent;

	struct device_settings orig_settings;
	struct device_settings settings;
	};

----------------------------------
	
	

	
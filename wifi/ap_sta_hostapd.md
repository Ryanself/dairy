### WIFI LINK WAY

#### bss是怎么被添加的呢

首先我们在web端路由界面进行新建无线网络，设置好对应参数后，确认添加，数据被传到后端.lua进行处理。wireless.lua文件对传入的数据进行处理生成wireless配置文件，经过mac80211.sh以及hostapd.sh脚本的解析，生成hostapd-phy.conf配置文件。

#### hostapd源码分部分

本来想自己写的，看了别人的于是作罢zzz

[hostapd-userspace](https://blog.csdn.net/xpbob/article/details/52414367) 

[hostapd源代码分析（一）：网络接口和BSS的初始化](https://blog.csdn.net/xpbob/article/details/52414367) 
[hostapd源代码分析（二）：hostapd的工作机制](https://blog.csdn.net/tmwiajd/article/details/41621571) 
[hostapd源代码分析（三）：管理帧的收发和处理](https://blog.csdn.net/tmwiajd/article/details/41621571) 
#### sta是怎么连接的呢
[hostapd-kernel](https://blog.csdn.net/xpbob/article/details/52414367) 

over.

**星期五, 07. 九月 2018 02:48下午 **

-----------------
so sad, i'm back.
原本以为不用再做些什么，但原生的hostapd对bss加载的机制有点问题，于是要重新修改。
--------------------------------------
hostapd 在conf文件被改动后会重新

先看main.c的main函数
	
	545 int main(int argc, char *argv[])
	 	{
	 		struct hapd_interfaces interfaces;
	 		......
			if (os_program_init())
				return -1;
			......
			wpa_supplicant_event = hostapd_wpa_event;
	574		for (;;) {
				......
				}
	
	
		}
hostapd 经过一系列的初始化，
	
	900	hostapd_global_ctrl_iface_init(&interfaces);
进入控制模式的循环
	
	if (hostapd_global_run(&interfaces, daemonize, pid_file)) {
		wpa_printf(MSG_ERROR, "Failed to start eloop");
		goto out;
	}
如果ctrl_iface_init失败则跳转到out退出。

让我们留意一下ctrl_iface_init的实现。毕竟，这hostapd正常运行时的状态。
代码在ctrl_iface.c 
	
	4128 int hostapd_global_ctrl_iface_init(struct hapd_interfaces *interface)
	{
	......
	4198 if (eloop_register_read_sock(interface->global_ctrl_sock,
					hostapd_global_ctrl_iface_receive, 
					interface, NULL) < 0) { 
			hostapd_global_ctrl_iface_deinit(interface); 
			return -1;
	}
又是一个长长的初始化，之后就进入了eloop_register_read_sock()。
该handler是一个方法，后续socket如果有变化，就会调用相应的socket所在的结构体中的handler来处理。

  	int eloop_register_read_sock(int sock, eloop_sock_handler handler,
	 ¦       ¦       ¦            void *eloop_data, void *user_data);
  
	/**
  	 * eloop_unregister_read_sock - Unregister handler for read events
   	 * @sock: File descriptor number for the socket
   	 *
   	 * Unregister a read socket notifier that was previously registered with
   	 * eloop_register_read_sock().
   	 */
   	 
   ---------------------------
   星期五, 07. 九月 2018 05:32下午 
   ---------------------------
 	path:   src/utils/eloop.c
 	
   	函数处理向下递进：
   	eloop_register_read_sock()
   		return  eloop_register_sock();
   			return eloop_sock_table_add_sock();
   			
   	eloop run();
   		eloop_sock_table_dispatch();
-----------------------------
	   584 static void eloop_sock_table_dispatch(struct eloop_sock_table *table,
	   585 ¦       ¦       ¦       ¦             fd_set *fds)
	   586 {
	   587 ¦       int i;
	   588 
	   589 ¦       if (table == NULL || table->table == NULL)
 	   590 ¦       ¦       return;
 	   591 
	   592 ¦       table->changed = 0;
	   593 ¦       for (i = 0; i < table->count; i++) {
	   594 ¦       ¦       if (FD_ISSET(table->table[i].sock, fds)) {
	   595 ¦       ¦       ¦       table->table[i].handler(table->table[i].sock,
	   596 ¦       ¦       ¦       ¦       ¦       ¦       table->table[i].eloop_data,
	   597 ¦       ¦       ¦       ¦       ¦       ¦       table->table[i].user_data);
	   598 ¦       ¦       ¦       if (table->changed)
	   599 ¦       ¦       ¦       ¦       break;
	   600 ¦       ¦       }
	   601 ¦       }
	   602 }
---------------------------------------------

			hostapd_reload_iface
			hostapd_reload_bss
			interfaces.reload_config = hostapd_reload_config;
			
			
			handle_reload_iface()
			return hostapd_reload_config(iface)
			
			
			handle_reload()
				hostapd_for_each_interface(interfaces, handle_reload_iface, NULL)
			
-----------------------------

	int hostapd_ctrl_iface_init(struct hostapd_data *hapd)
	{
	
	  3421 ¦       if (eloop_register_read_sock(hapd->ctrl_sock, 
	  3422 ¦       ¦       ¦       ¦            hostapd_ctrl_iface_receive, hapd, NULL) <
	  3423 ¦           0) {
	  3424 ¦       ¦       hostapd_ctrl_iface_deinit(hapd); 
	  3425 ¦       ¦       return -1; 
	  3426 ¦       } 
	}//在初始化时将hostapd_ctrl_iface_receive加入eloop_sock_table
----------------------------------------------
	path: hostapd/main.c
	
		int main()
	...
	906 	 if (hostapd_setup_interface(interfaces.iface[i]))
				goto out;
				
				->setup_interface()
				
					->if (start_ctrl_iface(iface))
						return -1;
						
						->if (!iface->interfaces || !iface->interfaces->ctrl_iface_init)
							return 0;
							
							->interfaces.ctrl_iface_init = hostapd_ctrl_iface_init;
							
							->if (eloop_register_read_sock(hapd->ctrl_sock,
											hostapd_ctrl_iface_receive, hapd, NULL) <
								0) {
									hostapd_ctrl_iface_deinit(hapd);
									return -1;
								}
	
	path: hostapd/ctrl_iface.c
	
	hostapd_ctrl_iface_receive()
	
	->reply_len = hostapd_ctrl_iface_receive_process(hapd, pos,
			reply, reply_size, &from, fromlen);
			
			->} else if (os_strncmp(buf, "RELOAD", 6) == 0) {
				if (hostapd_ctrl_iface_reload(hapd->iface))
				reply_len = -1;
				}
				
				->hostapd_reload_iface(iface)
				{
					...
					for (j = 0; j < hapd_iface->num_bss; j++)
						hostapd_reload_bss(hapd_iface->bss[j]);
					return 0;
				}
				
	/*  在hostapd_ctrl_iface_receive()中，在建立好套接字传送buffer后，调用
	* hostapd_ctrl_iface_receive_process()对传送的bufer进行分析，当传入的
	* buffer是RELOAD时，调用hostapd_ctrl_iface_reload(hapd->iface)进行
	* reload。
	*/
-----------------------------
	path: hostapd/main.c
	
	eloop_register_signal(SIGHUP, handle_reload, interfaces);
	
		->static void handle_reload(int sig, void *signal_ctx)
		
			-> hostapd_for_each_interface(interfaces, handle_reload_iface, NULL);
				
				->hostapd_reload_config(iface)
					->hostapd_reload_bss()
	


   	 
   	 
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
   

   	 
   	 
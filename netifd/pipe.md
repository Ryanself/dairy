### PIPE管道

在netifd的代码阅读中，遇到了pipe问题。
我们实现的代码在运行时发现pipe数量会不断的增加，先去了解一下pipe。

> 
管道是一种每个进程各自有不同的用户地址空间，任 何一个进程的全局变量在另一个进程中都看不到，所以进程之间要交换数据必须通过内核，在内核中开辟一块缓冲区，进程1把数据从用户空间拷到内核缓冲区，进程2再从内核缓冲区把数据读走，内核提供的这种机制称为进程间通信（IPC，InterProcess Communication）。 最基本的IPC机制。

  273 ¦       int fds[2] = { -1, -1 };
   274 ¦       D(WIRELESS, "Wireless device '%s' run %s handler\n", wdev->name, action);
   275 ¦       if (!up && wdev->prev_config) {
   276 ¦       ¦       config = blobmsg_format_json(wdev->prev_config, true);
   277 ¦       ¦       free(wdev->prev_config);
   278 ¦       ¦       wdev->prev_config = NULL;
   279 ¦       } else {
   280 ¦       ¦       prepare_config(wdev, &b, up);
   281 ¦       ¦       config = blobmsg_format_json(b.head, true);
   282 ¦       }
   283 
   284 ¦       argv[i++] = wdev->drv->script;
   285 ¦       argv[i++] = wdev->drv->name;
   286 ¦       argv[i++] = action;
   287 ¦       argv[i++] = wdev->name;
   288 ¦       argv[i++] = config;
   289 ¦       if(iface)
   290 ¦       ¦       argv[i++] = iface->ifname;
   291 ¦       else
   292 ¦             argv[i++] = NULL;
   293 ¦       argv[i] = NULL;
   294 
   295 ¦       if (up && pipe(fds) == 0) {
   296 ¦       ¦       wdev->script_proc_fd.fd = fds[0];
   297 ¦       ¦       uloop_fd_add(&wdev->script_proc_fd,
   298 ¦       ¦       ¦            ULOOP_READ | ULOOP_EDGE_TRIGGER);
   300 ¦       }
   301 
   302 ¦       netifd_start_process(argv, NULL, &wdev->script_task);
   303 
   304 ¦       if (fds[1] >= 0) {
   305 ¦       ¦       close(fds[1]);
   307 ¦       }
   308 
   309 ¦       free(config);
   310 }


其中建立了一个pipe来对proc进行监听。当fds[0]变化时，最终调用wdev->script_proc_fd.cb进行处理
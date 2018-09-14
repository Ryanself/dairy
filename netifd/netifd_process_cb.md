## wireless_device_run_handler

	path: wireless.c

	wireless_device_run_handler(struct wireless_device *wdev, bool up)
	{
		const char *action = up ? "setup" : "teardown";
		const char *argv[6];
		char *config;
		int i = 0;
		int fds[2] = { -1, -1 };
		
		if (!up && wdev->prev_config) {// 获取config
			config = blobmsg_format_json(wdev->prev_config, true);
			free(wdev->prev_config);
			wdev->prev_config = NULL;
		} else {
				prepare_config(wdev, &b, up);
				config = blobmsg_format_json(b.head, true);
		}
		
		argv[i++] = wdev->drv->script;
		argv[i++] = wdev->drv->name;
		argv[i++] = action;
		argv[i++] = wdev->name;
		argv[i++] = config;
		argv[i] = NULL;
		
		if (up && pipe(fds) == 0) {// 创建管道1
			wdev->script_proc_fd.fd = fds[0]; // 管道读端
			uloop_fd_add(&wdev->script_proc_fd,
							ULOOP_READ | ULOOP_EDGE_TRIGGER); //注册监听fd
		}
		
		netifd_start_process(argv, NULL, &wdev->script_task);
		
		if (fds[1] >= 0)
			close(fds[1]);
		
		free(config);
	}
	
---------------------------------------
	
	path: main.c

	int
	netifd_start_process(const char **argv, char **env, struct netifd_process *proc)
	{
	//argv = argv, env = NULL, proc = &wdev->script_task
		int pfds[2];
		int pid;
		
		netifd_kill_process(proc);
		
		if(pipe(pfds) < 0)// 创建管道2
			return -1;
		
		if ((pid = fork()) < 0)// fork 子进程
			goto error;
			
		if (!pid) {//pid = 0 子进程
			int i;
			
			if (env) {//env = NULL
				while (*env) {
					putenv(*env);
					env++;
				}
			}
			if (proc->dir_fd >= 0) 
				if (fchdir(proc->dir_fd)) {}
				
			close(pfds[0]);
			
			for (i = 0; i <= 2; i++) {
				if (pfds[1] == i)
					continue;
					
				dup2(pfds[1], i);// 复制文件描述符
			}
			
			if (pfds[1] > 2)
				close(pfds[1]);
				
			execvp(argv[0], (char **) argv);// execvp 执行成功后转入另一程序并退出
			exit(127);
		}
		......
	}
	
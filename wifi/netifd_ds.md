## netifd_ds.md
loopback: 本地环回接口


struct interface
struct device

> interface对象avl tree链表设置了keep_old和no_delete标志，每次执行config_init_all时首先vlist_update把avl tree链表头结点的version标志加1,当根据UCI更新interface链表中对象时每个node的version保持与头结点version一致，后继做vlist_flush时如果存在node的version与头结点version不一致的将被删除，而netifd在删除某个interface时其实并没有把相应的对象从avl tree链表中删除，而是等下一次restart或reload时再




	
wdev_set_config_state(wdev, IFC_RELOAD);

(> 463 static void
   464 wdev_set_config_state(struct wireless_device *wdev, enum interface_config_state s)
   465 {
   466 ¦       if (wdev->config_state != IFC_NORMAL)
   467 ¦       ¦       return;
}> 468 
   469 ¦       wdev->config_state = s;
   470 ¦       D(WIRELESS, "wdev_set_config_state: wdev->state %d\n>>>>>>>>>>>>>>>>>>>>>>>>>>>", wdev->state);
   471 ¦       if (wdev->state == IFS_DOWN)
   472 ¦       ¦       wdev_handle_config_change(wdev,true);
   473 ¦       else
   474 ¦       ¦       __wireless_device_set_down(wdev);
   475 }

   392 ¦       wdev->state = IFS_TEARDOWN;
   393 ¦       wireless_device_run_handler(wdev, false);
   394 }

   265 ¦       D(WIRELESS, "Wireless device '%s' run %s handler\n", wdev->name, action);
   266 ¦       if (!up && wdev->prev_config) {
   267 ¦       ¦       config = blobmsg_format_json(wdev->prev_config, true);
   268 ¦       ¦       free(wdev->prev_config);
   269 ¦       ¦       wdev->prev_config = NULL;
   270 ¦       } else {
   271 ¦       ¦       prepare_config(wdev, &b, up);
   272 ¦       ¦       config = blobmsg_format_json(b.head, true);
   273 ¦       }
   274 

IPC（Inter-Process Comminication），进程间通信。
进程间通信技术包括消息传递、同步、共享内存和远程过程调用。 IPC是一种标准的Unix通信机制。
RPC（远程过程调用）
> * 简单的说，RPC就是从一台机器（客户端）上通过参数传递的方式调用另一台机器（服务器）上的一个函数或方法（可以统称为服务）并得到返回的结果。
* RPC 会隐藏底层的通讯细节（不需要直接处理Socket通讯或Http通讯）
* RPC 是一个请求响应模型。客户端发起请求，服务器返回响应（类似于Http的工作方式）
* RPC 在使用形式上像调用本地函数（或方法）一样去调用远程的函数（或方法）。
[作者：iseeyou](http://www.zhihu.com/question/25536695/answer/113449098) 

OpenWrt平台可使用一个通用框架ubus来构建进程间通信。
ubus基于unix socket。
实现一个unix socket需要：

* 建立一个socket server端，绑定到一个本地socket文件，并监听clients连接
* 建立client 连接 server
* client server 相互发送消息
* client或server收到对方消息后针对消息进行处理


> ubus提供了一个socket server： ubusd
ubus提供了创建client的接口支持 shell/lua/c
ubus 通信消息格式为json
ubus对client端消息处理抽象出对象和方法的概念。
[link：ubus](https://blog.csdn.net/jasonchen_gbd/article/details/45627967) 

client 1 regitst and loop
client 2 call ubus
ubus call client 1
client1 do return
ubus return to client 2
client1 rm
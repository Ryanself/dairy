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
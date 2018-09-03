### WIFI LINK WAY

#### bss是怎么被添加的呢。

首先我们在web端路由界面进行新建无线网络，设置好对应参数后，确认添加，数据被传到后端.lua进行处理。.lua文件对传入的数据进行处理生成wireless配置文件，经过mac80211.sh以及hostapd.sh脚本的解析，生成hostapd-phy.conf配置文件。

#### hostapd源码分为3部分。




#### sta是怎么连接的呢。

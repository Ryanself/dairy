### SiWiFi接口总览

#### LAN(br-lan):

MAC-地址: 10:16:88:15:03:52
IPv4: 192.168.4.1/24
IPv6: fdc2:4d4e:fa27:2::1/63
IPv6: fdbd:a9b8:5db1::1/60

#### WAN(eth0.2):

MAC-地址: 10:16:88:15:03:52
IPv4: 192.168.1.203/24
IPv6: fdc2:4d4e:fa27:4:1216:88ff:fe15:352/64
IPv6: fdc2:4d4e:fa27::895/128
...

### 无线

Generic MAC80211 802.11bgn (radio0)
信道: 11 (2.462 GHz) | 传输速率: 13.5 Mbit/s
SSID: SiWiFi-0354 | 模式: Master
BSSID: 10:16:88:15:03:54 | 加密: WPA2 PSK (CCMP)

Generic MAC80211 802.11nac (radio1)
信道: 161 (5.805 GHz) | 传输速率: ? Mbit/s
SSID: SiWiFi-5G-0355 | 模式: Master
BSSID: 10:16:88:15:03:55 | 加密: WPA2 PSK (CCMP)

### 无线终端（手机）

       主机名             IPv4-地址           MAC-地址
RedmiNote4X-hongmish	192.168.4.215	 f4:f5:db:06:19:4b

### WiFi连接过程
STA开启WiFi-> STA Scan(probe request)

STA -> AP
STA <- AP
STA -> AP
STA <- AP

### 802.11 帧知识

#### 帧分类：

控制帧：RTS CTS ACK PS-POLL
管理帧：Beacon
数据帧：DATA NULL DHCP
> 管理帧包括： `Association request
Association response
Reassociation request
Reassociation response
Probe request
Probe response
Beacon
Announcement traffic indication message (ATIM)
Disassociation
Authentication
Deauthentication
Action`

#### 帧结构

分为3个部分（帧头Mac header，帧实体body，FCS域）
1.Mac header分为4个字段（Frame Control，Duration ID， Address<包括目标源，BSSID>，Seq ctl）
> Frame control field（MAC版本 2，类型『0，管理；1，控制；2，数据』 2，子类型 4，To DS 1，From DS 1，More Fragements 1，Retry 1，
Power Management『0，active；1，power save』1，More Data 1，Protected Frame 1，Order 1） 
Duration: 持续时间，表明该帧和它的确认帧将会占用信道多长时间。
seq ctl: 顺序控制字段。
2.body: Frame body。

3.FCS: 帧校验序列，用来检查所收到帧的完整性。
IEEE 802.11: IEEE定义的无线网络通信标准。
SSID: Service Set Identifier服务集标识。
AP: Access Point无线接入点,提供无线接入服务。
STA: Station每一个连接到无线网络中的终端(可以联网的用户设备)都可称为一个站点。

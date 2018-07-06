### SiWiFi接口总览

#### LAN(br-lan):

MAC-地址: 10:16:88:15:03:52

#### WAN(eth0.2):

MAC-地址: 10:16:88:15:03:52

### 无线

Generic MAC80211 802.11bgn (radio0)
信道: 11 (2.462 GHz) | 传输速率: 13.5 Mbit/s
SSID: SiWiFi-0354 | 模式: Master
BSSID: 10:16:88:15:03:54 | 加密: WPA2 PSK (CCMP)

### 无线终端（手机）

       主机名             IPv4-地址           MAC-地址
RedmiNote4X-hongmish	192.168.4.215	 f4:f5:db:06:19:4b

### WiFi连接过程
STA开启WiFi-> STA Scan(probe request)

> 1、STA（本例为小米手机）启用wifi后发送广播Probe Request帧进行主动扫描无线网络。SSID=Broadcast。
2、AP收到probe req后回应probe res通告可提供的无线网络信息。
3、STA发送authentication帧进行认证。STA发送association request帧进行请求关联。AP发出association response帧。
4、AP与STA进行密钥协商（4 way handshake）。EAPOL属于数据帧，通过内核网络接口发送或接收。

#### 4 way handshake:

AP与STA进行密钥协商（4次握手）。

> 第一次握手AP-->STA，PMK已经预设好，这个AP时候发送一个随机产生的Nonce数。
第二次握手STA-->AP，STA根据接收到的随机数，自己也生成一个随机数，以及PMK，产生了PTK，然后把随机数发给AP。
第三次握手，AP接收到随机数后，使用相同的方法生成PTK，并取出其中的MIC密钥对第二次握手包进行较验，如果相同，那么AP知道这个时候STA拥一个跟它一样的PMK。这个时候AP有了PTK后就可以对它第一次握手生成的EAP包进行检验生成一个MIC序列号，并发送给STA。
第四次握手，STA接收到这个包后，同样执行跟AP的检验操作以确认AP拥有跟自己一样的PMK。然后发送确认ACK。




### 802.11 帧知识

#### 帧分类：

控制帧：RTS CTS ACK PS-POLL
管理帧：Beacon
数据帧：DATA NULL DHCP
> 管理帧包括： `Association request`
`Association response`
`Reassociation request`
`Reassociation response`
`Probe request`
`Probe response`
`Beacon`
`Announcement traffic indication message (ATIM)`
`Disassociation`
`Authentication`
`Deauthentication`
`Action`

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


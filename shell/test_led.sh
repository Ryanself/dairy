#!/bin/sh

WARN_GPIO=/sys/devices/pinctrl/gpio/gpio8/value
RADDR=/sys/devices/10000000.palmbus
RX=leds/siwifi-phy0::rx/brightness
TX=leds/siwifi-phy0::tx/brightness
LED_LB_SWITCH=/sys/module/sf16a18_lb_smac/parameters/led_status
LED_HB_SWITCH=/sys/module/sf16a18_hb_smac/parameters/led_status
led1=$RADDR/11000000.wifi-lb/$TX
led2=$RADDR/11000000.wifi-lb/$RX
led3=$RADDR/11400000.wifi-hb/$TX
led4=$RADDR/11400000.wifi-hb/$RX
run_led_switch(){
while true
do
echo 1 > $WARN_GPIO
echo 0 > $LED_LB_SWITCH
echo 0 > $LED_HB_SWITCH
sleep 1
echo 0 > $WARN_GPIO
echo "led is off<<<<<<"
sleep 5
echo 1 > $LED_LB_SWITCH
echo 1 > $LED_HB_SWITCH
echo "led is on>>>>>>"
echo 1 > $WARN_GPIO
echo 255 > led1
sleep 1
echo 0 > $WARN_GPIO
echo 255 > led2
sleep 1
echo 255 > led3
sleep 1
echo 255 > led4
sleep 1
echo 255 > led1
sleep 1
echo 255 > led2
sleep 1
echo 255 > led3
sleep 1
echo 255 > led4
sleep 1
done
}


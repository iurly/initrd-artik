#!/bin/sh

LED_RED=28
LED_BLUE=38
GPIO_PATH=/sys/class/gpio
SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
ZIGBEE_SCRIPT=802.15.4_setup.sh
ZIGBEE_FW_NAME=ncp-uart-xon-xoff-use-with-serial-uart-btl-5.7.4.ebl
ZIGBEE_FW_TYPE=1
ZIGBEE_FW_VERSION=5.7.4

led_ctl()
{
	local led=$1
	local ctl=$2

	if ! [ -d $GPIO_PATH/gpio$led ]; then
		echo $led > $GPIO_PATH/export
	fi

	echo "out" > $GPIO_PATH/gpio$led/direction
	echo $ctl > $GPIO_PATH/gpio$led/value
}

led_ctl $LED_RED 1

CUR_DIR=$(pwd)
cd $SCRIPT_DIR
sh $ZIGBEE_SCRIPT $ZIGBEE_FW_NAME $ZIGBEE_FW_VERSION $ZIGBEE_FW_TYPE 0&
cd $CUR_DIR

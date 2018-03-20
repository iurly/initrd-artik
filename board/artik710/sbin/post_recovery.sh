#!/bin/sh

LED_RED=28
LED_BLUE=38
GPIO_PATH=/sys/class/gpio
SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
ZIGBEE_SCRIPT=802.15.4_setup.sh
ZIGBEE_FW_NAME=NONE
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

wait_zb_process()
{
	while [ "`ps | grep -v grep | grep $ZIGBEE_SCRIPT`" != "" ]; do
		sleep 1
	done
}

led_ctl $LED_RED 0
led_ctl $LED_BLUE 1

# Zigbee firmware check

CUR_DIR=$(pwd)
cd $SCRIPT_DIR
wait_zb_process
sh $ZIGBEE_SCRIPT $ZIGBEE_FW_NAME $ZIGBEE_FW_VERSION $ZIGBEE_FW_TYPE 1 > /dev/null 2>&1
RET=$?
cd $CUR_DIR

if [ "$ZIGBEE_FW_TYPE" == "1" ]; then
	ZIGBEE_FW_STR=zigbee
else
	ZIGBEE_FW_STR=thread
fi

if [ $RET == 0 ]; then
	echo "The current $ZIGBEE_FW_STR fw is the latest version"
	exit 0
else
	echo "Invalid $ZIGBEE_FW_STR fw version"
	exit 1
fi

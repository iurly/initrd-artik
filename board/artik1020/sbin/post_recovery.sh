#!/bin/sh

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
ZIGBEE_SCRIPT=802.15.4_setup.sh
ZIGBEE_FW_NAME=NONE
ZIGBEE_FW_TYPE=1
ZIGBEE_FW_VERSION=5.7.4

wait_zb_process()
{
	while [ "`ps | grep -v grep | grep $ZIGBEE_SCRIPT`" != "" ]; do
		sleep 1
	done
}

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

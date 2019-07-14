#!/bin/sh

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`
ZIGBEE_SCRIPT=802.15.4_setup.sh
ZIGBEE_FW_NAME=ncp-uart-xon-xoff-use-with-serial-uart-btl-5.7.4.ebl
ZIGBEE_FW_TYPE=1
ZIGBEE_FW_VERSION=5.7.4

# Make a red blinking during recovery
echo timer > /sys/class/leds/red/trigger

CUR_DIR=$(pwd)
cd $SCRIPT_DIR
sh $ZIGBEE_SCRIPT $ZIGBEE_FW_NAME $ZIGBEE_FW_VERSION $ZIGBEE_FW_TYPE 0&
cd $CUR_DIR

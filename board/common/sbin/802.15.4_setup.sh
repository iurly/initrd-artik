#!/bin/sh

if [ $# -ne 4 ]
then
echo '802.15.4_setup.sh [f/w file] [f/w version] [1:ZigBee, 2:Thread] [1:ver_check]'
exit 0
fi

FIRMWARE_FILE=$1
VERSION=$2
ZIGBEE_THREAD=$3
MAJOR_VERSION=${VERSION:0:5}
VER_CHECK=$4
ZIGBEE_VERSION_TOOL='./zigbee_version'
THREAD_VERSION_TOOL='./thread_version'
FIRMWARE_FLASHING_TOOL='./flash_firmware'

echo "Firmware file $FIRMWARE_FILE"
echo "Required version $VERSION"
echo "ZigBee version checking tool $ZIGBEE_VERSION_TOOL"
echo "Thread version checking tool $THREAD_VERSION_TOOL"
echo "Firmware flahsing tool $FIRMWARE_FLASHING_TOOL"
if [ "$ZIGBEE_THREAD" == "1" ]; then
	echo "Target is ZigBee firmware"
elif [ "$ZIGBEE_THREAD" == "2" ]; then
	echo "Target is Thread firmware"
else
	echo "Wrong parameter use [1:ZigBee, 2:Thread]"
	exit 0
fi

if [ ! -e "$FIRMWARE_FILE" ]; then
echo 'No firmware file'
exit 0
fi

if [ ! -e "$ZIGBEE_VERSION_TOOL" ]; then
echo 'No zigbee_version file'
exit 0
fi

if [ ! -e "$THREAD_VERSION_TOOL" ]; then
echo 'No thread_version file'
exit 0
fi

if [ ! -e "$FIRMWARE_FLASHING_TOOL" ]; then
echo 'No flash_firmware file'
exit 0
fi

ARTIK5=`cat /proc/cpuinfo | grep -i EXYNOS3`
ARTIK530=`cat /proc/cpuinfo | grep -i s5p4418`
ARTIK10=`cat /proc/cpuinfo | grep -i EXYNOS5`

if [ "$ARTIK5" != "" ]; then
        ZIGBEE_TTY="-p /dev/ttySAC1"
	THREAD_TTY="-u /dev/ttySAC1"
	VERSION=$MAJOR_VERSION
elif [ "$ARTIK530" != "" ]; then
        ZIGBEE_TTY="-p /dev/ttyAMA1"
	THREAD_TTY="-f x -u /dev/ttyAMA1"
elif [ "$ARTIK10" != "" ]; then
        ZIGBEE_TTY="-p /dev/ttySAC0"
        THREAD_TTY="-u /dev/ttySAC0"
	VERSION=$MAJOR_VERSION
else # ARTIK 710
        ZIGBEE_TTY="-n 1 -p /dev/ttySAC0"
        THREAD_TTY="-f x -u /dev/ttySAC0"
	VERSION=$MAJOR_VERSION
fi

zigbee_version_check() {
	version=$1
	result=1
	firmware_version=$($ZIGBEE_VERSION_TOOL $ZIGBEE_TTY)
	case "$firmware_version" in
	*"ezsp ver"*)
		echo "Found ZigBee firmware"
		result=2
		;;
	esac
	if [ "$result" == "2" ]; then
		case "$firmware_version" in
		*"$version"*)
			return 0
			;;
		esac
	fi
	return $result
}

thread_version_check() {
	version=$1
	result=1
	firmware_version=$($THREAD_VERSION_TOOL $THREAD_TTY)
	case "$firmware_version" in
	*"Thread"*)
		echo "Found Thread firmware"
		result=2
		;;
	*)
		# Test again due to issue in Thread 1.0.6
		firmware_version=$($THREAD_VERSION_TOOL $THREAD_TTY)
		case "$firmware_version" in
		*"Thread"*)
			echo "Found Thread firmware"
			result=2
			;;
		esac
		;;
	esac
	if [ "$result" == "2" ]; then
		case "$firmware_version" in
		*"$version"*)
			return 0
			;;
		esac
	fi
	return $result
}

version_check() {
	zigbee=$1
	version=$2
	result=2
	if [ "$zigbee" == "1" ]; then
		zigbee_version_check $version
		result=$?
	elif [ "$zigbee" == "2" ]; then
		thread_version_check $version
		result=$?
	fi
	return $result
}

version_check $ZIGBEE_THREAD $VERSION
RESULT=$?
if [ "$VER_CHECK" == "1" ]; then
	exit $RESULT
fi

if [ "$RESULT" == "0" ]; then
	echo "Version matched, skip flashing"
	exit 0
fi

if [ "$ZIGBEE_THREAD" == "1" ]; then
	if [ "$RESULT" == "1" ]; then
		# check Thread firmware
		echo "Try to check Thread firmware"
		thread_version_check $VERSION
		version_check_result=$?
		if [ "$version_check_result" == "2" ]; then
			echo "skip flashing"
			exit 0
		fi
	fi
	echo "ZigBee firmware v$VERSION flashing"
	exec $FIRMWARE_FLASHING_TOOL $ZIGBEE_TTY -f $FIRMWARE_FILE -n > /dev/null 2>&1
elif [ "$ZIGBEE_THREAD" == "2" ]; then
	echo "Thread firmware v$VERSION flashing"
	exec $FIRMWARE_FLASHING_TOOL $ZIGBEE_TTY -f $FIRMWARE_FILE -n > /dev/null 2>&1
fi

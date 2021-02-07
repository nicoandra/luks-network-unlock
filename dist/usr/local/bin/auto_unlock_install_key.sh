#!/bin/bash

mkdir -p /run/keytemp
LOCK_FILE="/run/keytemp/lock_key"

function finish {
	rm -f $LOCK_FILE
}
trap finish EXIT


echo "Generates key based on your the MAC address of the device plugged in a network interface"

. /usr/local/etc/auto_unlock.conf

if [ "$KEYSLOT" = "0" ]; then
	echo "Cannot use key slot 0"
	exit 10
fi

echo "Looking up AP MAC for Wifi network $WIFI_NETWORK Host: $UNLOCK_HOST_IP"

SERVER_MAC=`arp -n -i $WIFI_INTERFACE $UNLOCK_HOST_IP | grep $UNLOCK_HOST_IP | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'`

echo "Found MAC ==  |$SERVER_MAC| "

echo "Please verify that Wifi MAC of Access Point and display information are valid"
echo "Especially verify that your external display is recognized, not build-in one"

echo "Type in YES to set-up LUKS key based on information above"
read ANSWER

if [ "$ANSWER" != "YES" ]; then
	echo "Exiting without setup"
	exit 5
fi

echo -e "$SERVER_MAC\n" > $LOCK_FILE
echo "Checksum of lockfile $(md5sum $LOCK_FILE)"
echo "Stored lock file in $LOCK_FILE, please delete it manually if you cancel script execution"

echo "Parsing /etc/crypttab"

for TEXT in $(awk '/^..*$/ {print $1 ":" $2}' /etc/crypttab); do
	
	NAME=`echo "$TEXT" | cut -d: -f1`
	DEVICE=`echo "$TEXT" | cut -d: -f2`

	case $DEVICE in
		/dev/*) ;;
		UUID=*) UUID=${DEVICE##UUID=} 
			DEVICE=$(blkid -U "$UUID")
		;;
	esac

	if [ -z "$DEVICE" ]; then
		continue
	fi

	echo "found partition $DEVICE for $NAME"

	if [ ! -b $DEVICE ]; then
		echo "Cannot work on $DEVICE, not a block device"
		continue
	fi

	cryptsetup luksKillSlot $DEVICE $KEYSLOT
	SLOT_OK=1
	echo "Adding new key ..."
	cryptsetup luksAddKey --key-slot=$KEYSLOT $DEVICE $LOCK_FILE


done

#!/sbin/busybox sh
set +x
_PATH="$PATH"
export PATH=/sbin

# Alexa kernel is powered by SatrioDwiPrabowo
# visit satriodwiprabowo.blogspot.com for more info
# Copyright 2015 (c) Seraphic Development

# Alexa setup
CMD_SETUP(){
	DATE="${BUSYBOX} date"
	MKDIR="${BUSYBOX} mkdir"
	CHOWN="${BUSYBOX} chown"
	CHMOD="${BUSYBOX} chmod"
	MV="${BUSYBOX} mv"
	TOUCH="${BUSYBOX} touch"
	CAT="${BUSYBOX} cat"
	SLEEP="${BUSYBOX} sleep"
	KILL="${BUSYBOX} kill"
	RM="${BUSYBOX} rm"
	PS="${BUSYBOX} ps"
	GREP="${BUSYBOX} grep"
	AWK="${BUSYBOX} awk"
	EXPR="${BUSYBOX} expr"
	MOUNT="${BUSYBOX} mount"
	UMOUNT="${BUSYBOX} umount"
	TAR="${BUSYBOX} tar"
	GZIP="${BUSYBOX} gzip"
	CPIO="${BUSYBOX} cpio"
	CHROOT="${BUSYBOX} chroot"
	LS="${BUSYBOX} ls"
	HEXDUMP="${BUSYBOX} hexdump"
	CP="${BUSYBOX} cp"
}

# Alexa Function definition for logging
ECHOL(){
	_DATETIME=`${BUSYBOX} date +"%d-%m-%Y %H:%M:%S-%Z"`
	echo "${_DATETIME}: $*" >> ${LOGFILE}
	return 0
}

# Alexa function definition for log exec command
EXECL(){
	_DATETIME=`${BUSYBOX} date +"%d-%m-%Y %H:%M:%S-%Z"`
	echo "${_DATETIME}: $*" >> ${LOGFILE}
	$* 2>> ${LOGFILE}
	_RET=$?
	echo "${_DATETIME}: RET=${_RET}" >> ${LOGFILE}
	return ${_RET}
}

# Alexa Function definition for get property
GETPROP(){
	# Get the property from getprop
	PROP=`/system/bin/getprop $*`
	PROP=`grep "$*" /system/build.prop | awk -F'=' '{ print $NF }'`
	echo $PROP
}
	
# Alexa function umount 
UMOUNT_ALL(){
	# umount
	${UMOUNT} -l /dev/block/mmcblk0p6  # /boot/modem_fs1
	${UMOUNT} -l /dev/block/mmcblk0p7  # /boot/modem_fs2
	${UMOUNT} -l /dev/block/mmcblk0p13 # /system
	${UMOUNT} -l /dev/block/mmcblk0p15 # /data
	${UMOUNT} -l /dev/block/mmcblk0p10 # /mnt/idd
	${UMOUNT} -l /dev/block/mmcblk0p14 # /cache
	${UMOUNT} -l /dev/block/mmcblk0p12 # /lta-label
	${UMOUNT} -l /dev/block/mmcblk1p1  # /sdcard (External)
	${BUSYBOX} sync

	${UMOUNT} /system
	${UMOUNT} /data
	${UMOUNT} /mnt/idd
	${UMOUNT} /cache
	${UMOUNT} /lta-label

	## SDcard
	# Internal SDcard umountpoint
	${UMOUNT} /sdcard
	${UMOUNT} /mnt/sdcard
	${UMOUNT} /storage/sdcard0

	# External SDcard umountpoint
	${UMOUNT} /sdcard1
	${UMOUNT} /ext_card
	${UMOUNT} /storage/sdcard1

	# External USB umountpoint
	${UMOUNT} /mnt/usbdisk
	${UMOUNT} /usbdisk
	${UMOUNT} /storage/usbdisk

    # legacy folders
	${UMOUNT} /storage/emulated/legacy/Android/obb
	${UMOUNT} /storage/emulated/legacy
	${UMOUNT} /storage/emulated/0/Android/obb
	${UMOUNT} /storage/emulated/0
	${UMOUNT} /storage/emulated
	${UMOUNT} /storage/removable/sdcard1
	${UMOUNT} /storage/removable/usbdisk
	${UMOUNT} /storage/removable
	${UMOUNT} /storage
	${UMOUNT} /mnt/shell/emulated/0
	${UMOUNT} /mnt/shell/emulated
	${UMOUNT} /mnt/shell

	## misc
	${UMOUNT} /mnt/obb
	${UMOUNT} /mnt/asec
	${UMOUNT} /mnt/secure/staging
	${UMOUNT} /mnt/secure
	${UMOUNT} /mnt
	${UMOUNT} /acct
	${UMOUNT} /dev/cpuctl
	${UMOUNT} /dev/pts
	${UMOUNT} /sys/fs/selinux
	${UMOUNT} /sys/kernel/debug
	${BUSYBOX} sync
}

# add init.d support at boot
ADD_INITD() {
	#add init.d runparts if not added
	if [ `${GREP} -c "run-parts /system/etc/init.d" /system/etc/init.qcom.post_boot.sh` == 0 ];then
		ECHOL " "
		ECHOL "### No init.d support detected, adding init.d support in /system/etc/init.qcom.post_boot.sh"
		ECHOL "### remounting system as rw..."
		EXECL ${MOUNT} -o remount,rw /system
		echo " " >> /system/etc/init.qcom.post_boot.sh
		echo "# dssmex: init.d support" >> /system/etc/init.qcom.post_boot.sh
		echo " /system/bin/logwrapper busybox run-parts /system/etc/init.d" >> /system/etc/init.qcom.post_boot.sh
		echo " " >> /system/etc/init.qcom.post_boot.sh
		ECHOL "### remounting system as ro..."
		EXECL ${MOUNT} -o remount,ro /system
	fi
	
	#add init.d directory if not exists
	if [ ! -d /system/etc/init.d ];then
		EXECL ${MOUNT} -o remount,rw /system
		EXECL ${MKDIR} /system/etc/init.d
		EXECL ${CHOWN} root.root /system/etc/init.d
		EXECL ${CHMOD} 751 /system/etc/init.d
		EXECL ${MOUNT} -o remount,ro /system
	fi
}


	
# leds paths
LED1_R_BRIGHTNESS_FILE="/sys/class/leds/LED1_R/brightness"
LED2_R_BRIGHTNESS_FILE="/sys/class/leds/LED2_R/brightness"
LED3_R_BRIGHTNESS_FILE="/sys/class/leds/LED3_R/brightness"
LED1_R_CURRENT_FILE="/sys/class/leds/LED1_R/led_current"
LED2_R_CURRENT_FILE="/sys/class/leds/LED2_R/led_current"
LED3_R_CURRENT_FILE="/sys/class/leds/LED3_R/led_current"
LED1_G_BRIGHTNESS_FILE="/sys/class/leds/LED1_G/brightness"
LED2_G_BRIGHTNESS_FILE="/sys/class/leds/LED2_G/brightness"
LED3_G_BRIGHTNESS_FILE="/sys/class/leds/LED3_G/brightness"
LED1_G_CURRENT_FILE="/sys/class/leds/LED1_G/led_current"
LED2_G_CURRENT_FILE="/sys/class/leds/LED2_G/led_current"
LED3_G_CURRENT_FILE="/sys/class/leds/LED3_G/led_current"
LED1_B_BRIGHTNESS_FILE="/sys/class/leds/LED1_B/brightness"
LED2_B_BRIGHTNESS_FILE="/sys/class/leds/LED2_B/brightness"
LED3_B_BRIGHTNESS_FILE="/sys/class/leds/LED3_B/brightness"
LED1_B_CURRENT_FILE="/sys/class/leds/LED1_B/led_current"
LED2_B_CURRENT_FILE="/sys/class/leds/LED2_B/led_current"
LED3_B_CURRENT_FILE="/sys/class/leds/LED3_B/led_current"

# Alexa Settings the LED 
	LEDC1_RED="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED1_R/led_current)"
	LEDC1_BLUE="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED1_B/led_current)"
	LEDC1_GREEN="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED1_G/led_current)"
	LEDB1_RED="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED1_R/brightness)"
	LEDB1_BLUE="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED1_B/brightness)"
	LEDB1_GREEN="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED1_G/brightness)"

	LEDC2_RED="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED2_R/led_current)"
	LEDC2_BLUE="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED2_B/led_current)"
	LEDC2_GREEN="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED2_G/led_current)"
	LEDB2_RED="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED2_R/brightness)"
	LEDB2_BLUE="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED2_B/brightness)"
	LEDB2_GREEN="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED2_G/brightness)"

	LEDC3_RED="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED3_R/led_current)"
	LEDC3_BLUE="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED3_B/led_current)"
	LEDC3_GREEN="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED3_G/led_current)"
	LEDB3_RED="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED3_R/brightness)"
	LEDB3_BLUE="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED3_B/brightness)"
	LEDB3_GREEN="$(${LS} /sys/devices/i2c-10/10-0047/leds/LED3_G/brightness)"
	
busybox cd /
busybox date >>boot.txt
exec >>boot.txt 2>&1
busybox rm /init

# include device specific vars
source /sbin/bootrec-device

# create directories
busybox mkdir -m 755 -p /dev/block
busybox mkdir -m 755 -p /dev/input
busybox mkdir -m 555 -p /proc
busybox mkdir -m 755 -p /sys
busybox mkdir -m 755 -p /alexa-kernel/xssdp
busybox mkdir -m 755 -p /alexa-kernel/config

# create device nodes
busybox mknod -m 600 /dev/block/mmcblk0 b 179 0
busybox mknod -m 600 ${BOOTREC_EVENT_NODE}
busybox mknod -m 666 /dev/null c 1 3

# mount filesystems
busybox mount -t proc proc /proc
busybox mount -t sysfs sysfs /sys

# keycheck
busybox echo '200' > /sys/class/timed_output/vibrator/enable
busybox cat ${BOOTREC_EVENT} > /dev/keycheck&
		
# LEDs activated
echo '255' > $LED1_R_BRIGHTNESS_FILE
echo '255' > $LED2_G_BRIGHTNESS_FILE
echo '255' > $LED3_B_BRIGHTNESS_FILE
busybox sleep 0.04
echo '255' > $LED1_B_BRIGHTNESS_FILE
echo '255' > $LED2_R_BRIGHTNESS_FILE
echo '255' > $LED3_G_BRIGHTNESS_FILE
busybox sleep 0.04
		# Turn on GREEN-led.
		echo '128' > ${LED3_G_CURRENT_FILE}
		echo '128' > ${LED3_G_CURRENT_FILE}
		${SLEEP} 0.4
		# Turn on white-led.
		echo '128' > ${LED1_R_CURRENT_FILE}
		echo '128' > ${LED1_B_CURRENT_FILE}
		echo '128' > ${LED1_G_CURRENT_FILE}
		echo '64' > ${LED1_R_CURRENT_FILE}
		echo '128' > ${LED1_G_CURRENT_FILE}
		echo '0' > ${LED1_B_CURRENT_FILE}
		${SLEEP} 0.4
		# Turn on red-led.
		echo '128' > ${LEDC2_RED}
		echo '128' > ${LEDB2_RED}
		${SLEEP} 0.4

		# Turn off GREEN-led.
		echo '0' > ${LEDC3_GREEN}
		# Turn off white-led.
		echo '0' > ${LEDC1_RED}
		echo '0' > ${LEDC1_BLUE}
		echo '0' > ${LEDC1_GREEN}
		# Turn off RED-led.
		echo "0" > ${LEDC2_RED}
		echo "0" > ${LEDC2_BLUE}
echo '255' > $LED1_R_BRIGHTNESS_FILE
echo '255' > $LED2_R_BRIGHTNESS_FILE
echo '255' > $LED3_R_BRIGHTNESS_FILE

		
# LEDs starting animation
echo '16' > $LED1_R_CURRENT_FILE
echo '16' > $LED2_G_CURRENT_FILE
echo '16' > $LED3_B_CURRENT_FILE
busybox sleep 0.04
echo '32' > $LED1_B_CURRENT_FILE
echo '32' > $LED2_G_CURRENT_FILE
echo '32' > $LED3_R_CURRENT_FILE
busybox sleep 0.04
echo '64' > $LED1_R_CURRENT_FILE
echo '64' > $LED2_B_CURRENT_FILE
echo '64' > $LED3_R_CURRENT_FILE
busybox sleep 0.04
echo '92' > $LED1_R_CURRENT_FILE
echo '92' > $LED2_G_CURRENT_FILE
echo '92' > $LED3_B_CURRENT_FILE
busybox sleep 1
echo '64' > $LED1_R_CURRENT_FILE
echo '64' > $LED2_R_CURRENT_FILE
echo '64' > $LED3_B_CURRENT_FILE
busybox sleep 0.04
echo '32' > $LED1_B_CURRENT_FILE
echo '32' > $LED2_B_CURRENT_FILE
echo '32' > $LED3_G_CURRENT_FILE
busybox sleep 0.04
echo '0' > $LED1_B_BRIGHTNESS_FILE
echo '0' > $LED2_R_BRIGHTNESS_FILE
echo '0' > $LED3_R_BRIGHTNESS_FILE
echo '0' > $LED1_R_CURRENT_FILE
echo '0' > $LED2_G_CURRENT_FILE
echo '0' > $LED3_B_CURRENT_FILE
echo '16' > $LED1_R_CURRENT_FILE
echo '16' > $LED2_R_CURRENT_FILE
echo '16' > $LED3_B_CURRENT_FILE
busybox sleep 0.04
echo '32' > $LED1_R_CURRENT_FILE
echo '32' > $LED2_G_CURRENT_FILE
echo '32' > $LED3_B_CURRENT_FILE
busybox sleep 0.04
echo '64' > $LED1_R_CURRENT_FILE
echo '64' > $LED2_B_CURRENT_FILE
echo '64' > $LED3_B_CURRENT_FILE
busybox sleep 0.04
echo '92' > $LED1_R_CURRENT_FILE
echo '92' > $LED2_G_CURRENT_FILE
echo '92' > $LED3_G_CURRENT_FILE
busybox sleep 1
echo '64' > $LED1_B_CURRENT_FILE
echo '64' > $LED2_R_CURRENT_FILE
echo '64' > $LED3_B_CURRENT_FILE
busybox sleep 0.04
echo '32' > $LED1_R_CURRENT_FILE
echo '32' > $LED2_B_CURRENT_FILE
echo '32' > $LED3_G_CURRENT_FILE
busybox sleep 0.04
echo '0' > $LED1_R_BRIGHTNESS_FILE
echo '0' > $LED2_G_BRIGHTNESS_FILE
echo '0' > $LED3_B_BRIGHTNESS_FILE
echo '0' > $LED1_R_CURRENT_FILE
echo '0' > $LED2_G_CURRENT_FILE
echo '0' > $LED3_B_CURRENT_FILE
	
# android ramdisk
load_image=/sbin/ramdisk.cpio

# boot decision
if [ -s /dev/keycheck ] || busybox grep -q warmboot=0x77665502 /proc/cmdline ; then
	busybox echo 'RECOVERY BOOT' >>boot.txt
	# LEDs for recovery
	busybox echo '100' > /sys/class/timed_output/vibrator/enable
	echo '255' > $LED1_B_BRIGHTNESS_FILE
	echo '255' > $LED2_B_BRIGHTNESS_FILE
	echo '255' > $LED3_B_BRIGHTNESS_FILE
	echo '32' > $LED1_B_CURRENT_FILE
	echo '32' > $LED2_B_CURRENT_FILE
	echo '32' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '64' > $LED1_B_CURRENT_FILE
	echo '64' > $LED2_B_CURRENT_FILE
	echo '64' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '128' > $LED1_B_CURRENT_FILE
	echo '128' > $LED2_B_CURRENT_FILE
	echo '128' > $LED3_B_CURRENT_FILE
	busybox sleep 1
	echo '64' > $LED1_B_CURRENT_FILE
	echo '64' > $LED2_B_CURRENT_FILE
	echo '64' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '32' > $LED1_B_CURRENT_FILE
	echo '32' > $LED2_B_CURRENT_FILE
	echo '32' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '0' > $LED1_B_BRIGHTNESS_FILE
	echo '0' > $LED2_B_BRIGHTNESS_FILE
	echo '0' > $LED3_B_BRIGHTNESS_FILE
	echo '0' > $LED1_B_CURRENT_FILE
	echo '0' > $LED2_B_CURRENT_FILE
	echo '0' > $LED3_B_CURRENT_FILE
	
	# recovery cyanogen repleace to philz recovery
	busybox mknod -m 600 ${BOOTREC_FOTA_NODE}
	busybox mount -o remount,rw /
	busybox ln -sf /sbin/busybox /sbin/sh
	extract_elf_ramdisk -i ${BOOTREC_FOTA} -o /sbin/ramdisk-recovery.cpio -t / -c
	busybox rm /sbin/sh
	load_image=/sbin/ramdisk-recovery.cpio
else
	busybox echo 'ANDROID BOOT' >>boot.txt
	# LEDs for Android
	echo '255' > $LED1_R_BRIGHTNESS_FILE
	echo '255' > $LED2_G_BRIGHTNESS_FILE
	echo '255' > $LED3_B_BRIGHTNESS_FILE
	echo '32' > $LED1_R_CURRENT_FILE
	echo '32' > $LED2_G_CURRENT_FILE
	echo '32' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '64' > $LED1_R_CURRENT_FILE
	echo '64' > $LED2_G_CURRENT_FILE
	echo '64' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '128' > $LED1_R_CURRENT_FILE
	echo '128' > $LED2_G_CURRENT_FILE
	echo '128' > $LED3_B_CURRENT_FILE
	busybox sleep 1
	echo '64' > $LED1_R_CURRENT_FILE
	echo '64' > $LED2_G_CURRENT_FILE
	echo '64' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '32' > $LED1_R_CURRENT_FILE
	echo '32' > $LED2_G_CURRENT_FILE
	echo '0' > $LED3_B_CURRENT_FILE
	busybox sleep 0.05
	echo '0' > $LED1_R_BRIGHTNESS_FILE
	echo '0' > $LED2_G_BRIGHTNESS_FILE
	echo '0' > $LED3_B_BRIGHTNESS_FILE
	echo '0' > $LED1_G_CURRENT_FILE
	echo '0' > $LED2_G_CURRENT_FILE
	echo '0' > $LED3_G_CURRENT_FILE
fi

# kill the keycheck process
busybox pkill -f "busybox cat ${BOOTREC_EVENT}"
busybox echo '200' > /sys/class/timed_output/vibrator/enable

# unpack the ramdisk image
busybox cpio -i < ${load_image}

busybox umount /proc
busybox umount /sys

busybox rm -fr /dev/*
busybox date >>boot.txt
export PATH="${_PATH}"
exec /init

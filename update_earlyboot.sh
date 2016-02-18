#!/bin/bash

. ./rpi-qemu/bootloaderlib.sh

check_root $0

SDCARD_IMG="sdcard.img"
SDCARD_SRC="../colibri-buildroot/output/sdcard"
SDCARD_BOOT_PARTNUM=1
#INITRAMFS_IMG="initramfs.img"
#KERNEL="../packages/qemu-kernel/qemu/_install/zImage"

# Get SDCard image info
sector_size=$( ${FDISK} -lu $SDCARD_IMG | grep "Units = sectors" | sed -e 's/.*=//;s/ bytes//')
#sector_size=$(fdisk -lu $SDCARD_IMG | grep "Units: sectors" | sed -e 's/.*=//;s/ bytes//')
start_sector=$( ${FDISK} -lu $SDCARD_IMG | grep "${SDCARD_IMG}${SDCARD_BOOT_PARTNUM}" | awk '{print $2}' )

LODEV=$(get_loopdev)
MNT=$(mktemp -d)

losetup $LODEV $SDCARD_IMG -o $(($start_sector * $sector_size))
mount $LODEV $MNT

rm -rf $MNT/earlyboot/*
cp -LR $SDCARD_SRC/earlyboot/* $MNT/earlyboot
cp -LR $SDCARD_SRC/initramfs.img $/MNT

sync

umount $MNT
rm -rf $MNT
losetup -d $LODEV

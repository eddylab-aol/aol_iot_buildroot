#!/bin/bash

# configuration
ROOTFS=rootfs
COMP=buildroot

# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function logn {
	echo -e "${RED}[BUILDROOT]${GREEN} $1 ${NC}"
}

function loge {
	echo -e "${RED}[BUILDROOT]${RED} $1 ${NC}"
}

function chrun {
	chroot $ROOTFS/ $1
}

logn "### add android groups..."
for aid in $(cat $buildroot/android_group) do
	echo "$aid" >> $ROOTFS/etc/group
done

#!/bin/bash

# configuration
WORKDIR=$(pwd)
ROOTFS=$WORKDIR/rootfs
COMP=$WORKDIR/buildroot
SERVICE_DIR=$WORKDIR/services

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

function check {
    if [ "$?" != "0" ]; then
        output "$1"
        sleep 86400
    fi
}


######### buildroot independent parts #########
logn "#### run buildroot independent parts..."
source $SERVICE_DIR/buildroot-install.sh

logn "### make rootfs.tar.gz ..."
tar czf rootfs.tar.gz $ROOTFS/

logn "### make linux.tar..."
rm -rf /data > /dev/null 2>&1
mkdir -p /data/linux
cp -r $ROOTFS/* /data/linux
tar cf linux.tar-$(date "+%Y%m%d-%H%M%S") /data/linux
rm -rf /data

logn "### buildroot routine finished..."

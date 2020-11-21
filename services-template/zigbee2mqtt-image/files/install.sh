#!/bin/bash

# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function output {
	echo -e "${RED}[BUILDROOT-SERVICE]${GREEN} $1 ${NC}"
}

output "### install zigee2mqtt..."

WORK_DIR=/tmp/installer
TARGET_DIR=/opt
ROOTFS_FILE="z2m.tar.gz"
INIT_FILE="z2m"

cd $WORK_DIR

tar xf $ROOTFS_FILE

mv $INIT_FILE/ $TARGET_DIR/$INIT_FILE
cp $INIT_FILE.sh /etc/init.d/$INIT_FILE
chmod a+x /etc/init.d/$INIT_FILE
update-rc.d z2m defaults

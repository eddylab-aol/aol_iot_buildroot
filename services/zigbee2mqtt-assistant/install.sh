#!/bin/bash


echo "### install zigbee2mqtt..."

WORK_DIR=/tmp/installer
TARGET_DIR=/opt
ROOTFS_FILE="z2m.tar.gz"
INIT_FILE="z2m"

cd $WORK_DIR
wget https://github.com/eddylab-aol/aol_iot_buildroot/raw/master/services/zigbee2mqtt/files/z2m.tar.gz
wget https://github.com/eddylab-aol/aol_iot_buildroot/raw/master/services/zigbee2mqtt/files/z2m

tar xf $ROOTFS_FILE

mv $INIT_FILE/ $TARGET_DIR/$INIT_FILE
cp $INIT_FILE /etc/init.d/$INIT_FILE
chmod a+x /etc/init.d/$INIT_FILE
update-rc.d $INIT_FILE defaults



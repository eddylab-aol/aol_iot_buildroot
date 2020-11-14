#!/bin/bash


echo "### install zigbee2mqtt-assistant..."

WORK_DIR=/tmp/installer
TARGET_DIR=/opt
ROOTFS_FILE="z2m-assistant.tar.gz"
INIT_FILE="z2m-assistant"

cd $WORK_DIR

tar xf $ROOTFS_FILE

mv $INIT_FILE/ $TARGET_DIR/$INIT_FILE
cp $INIT_FILE.sh /etc/init.d/$INIT_FILE
chmod a+x /etc/init.d/$INIT_FILE

cd /etc/rc3.d
ln -s ../init.d/z2m-assistant S02z2m-assistant

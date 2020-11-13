#!/bin/bash

logn "### install service..."

INSTALL_SCRIPTS="$(find $SERVICE_DIR -type f -name "install.sh")"

for SERVICE in $(echo "$INSTALL_SCRIPTS")
do
	chmod a+x $SERVICE
	mkdir -p $ROOTFS/tmp/installer
	cp $SERVICE $ROOTFS/tmp/installer/
	cp -r $(dirname $SERVICE)/files/* $ROOTFS/tmp/installer/
	chrun "/bin/bash /tmp/installer/install.sh"
	rm -rf $ROOTFS/tmp/installer > /dev/null 2>&1
done 

logn "### install services finished..."

#!/bin/bash

logn "### install service..."

INSTALL_SCRIPTS="$(find $SERVICE_DIR -type f -name "install.sh")"

for SERVICE in $(echo "$INSTALL_SCRIPTS")
do
	mkdir -p $ROOTFS/tmp/installer
	SERVICE_ROOT="$(cd $(dirname $SERVICE)/../; pwd -P)"
	chmod a+x $SERVICE_ROOT/host.sh
	bash $SERVICE_ROOT/host.sh
	cp -r $SERVICE_ROOT/files $ROOTFS/tmp/installer/
	chmod a+x $SERVICE
	chrun "/bin/bash /tmp/installer/install.sh"
	rm -rf $ROOTFS/tmp/installer > /dev/null 2>&1
done 

logn "### install services finished..."

#!/bin/bash

output "install services..."

INSTALL_SCRIPTS=$(find $SERVICE_DIR -type f -name "install.sh")

for SERVICE in $(INSTALL_SCRIPTS)
do
	chmod a+x $SERVICE
	mkidr $ROOTFS/tmp/installer > /dev/null 2>&1
	cp $SERVICE $ROOTFS/tmp/installer/install.sh
	cp -r $(dirname $SERVICE)/files/* /tmp/installer/
	chrun "/bin/bash /tmp/installer/install.sh"
	rm -rf $ROOTFS/tmp/installer > /dev/null 2>&1
done 

output "install services finished..."

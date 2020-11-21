#!/bin/bash

# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function output {
	echo -e "${RED}[BUILDROOT-TARGET]${GREEN} $1 ${NC}"
}

output "### install homeassistant..."

WORK_DIR=/tmp/installer
TARGET_DIR=/opt

cd $WORK_DIR

tar xf hass.tar.gz

mv hass/ $TARGET_DIR/hass
cp hass.sh /etc/init.d/hass
chmod a+x /etc/init.d/hass
update-rc.d hass defaults

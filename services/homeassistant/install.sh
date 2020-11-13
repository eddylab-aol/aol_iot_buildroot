#!/bin/bash


echo "### install homeassistant..."

WORK_DIR=/tmp/installer
TARGET_DIR=/opt

cd $WORK_DIR

tar xf hass.tar.gz

mv hass/ $TARGET_DIR/hass
cp hass /etc/init.d/hass
chmod a+x /etc/init.d/hass
update-rc.d hass defaults



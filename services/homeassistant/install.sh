#!/bin/bash


echo "### install homeassistant..."

WORK_DIR=/tmp/installer
TARGET_DIR=/opt

cd $WORK_DIR
wget https://github.com/eddylab-aol/aol_iot_buildroot/raw/master/services/homeassistant/files/hass.tar.gz
wget https://github.com/eddylab-aol/aol_iot_buildroot/raw/master/services/homeassistant/files/hass

tar xf hass.tar.gz

mv hass/ $TARGET_DIR/hass
cp hass /etc/init.d/hass
chmod a+x /etc/init.d/hass
update-rc.d hass defaults



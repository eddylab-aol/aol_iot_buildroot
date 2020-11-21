#!/bin/bash

SERVICE_NAME="homeassistant python venv"

echo "### install $SERVICE_NAME..."

#### installation commands ####

# install python3
apt install --no-install-recommends python3 python3-dev python3-venv python3-pip libffi-dev libssl-dev gcc-arm-linux-gnueabihf -y

# make venv
mkdir /opt/hass
cd /opt/hass
python3 -m venv /opt/hass
source /opt/hass/bin/activate

# install homeassistant
python3 -m pip install wheel
pip3 install -U setuptools
pip3 install homeassistant

# copy init file
cp /tmp/installer/hass.sh /etc/init.d/hass
chmod a+x /etc/init.d/hass
update-rc.d hass defaults

# clean


# exit venv
exit

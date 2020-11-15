#!/bin/bash

echo "### install mosquitto..."

apt install --no-install-recommends mosquitto -y
chmod a+rwx /var/log/mosquitto


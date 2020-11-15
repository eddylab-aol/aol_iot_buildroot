#!/bin/bash

echo "### install mosquitto..."

apt install --no-install-recommends mosquitto -y
chown mosquitto /var/log/mosquitto


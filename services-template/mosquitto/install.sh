#!/bin/bash

echo "### install mosquitto..."

apt install --no-install-recommends mosquitto -y

echo "user root" > /etc/mosquitto/mosquitto.conf

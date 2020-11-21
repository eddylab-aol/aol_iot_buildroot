#!/bin/bash
# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function output {
	echo -e "${RED}[BUILDROOT-TARGET]${GREEN} $1 ${NC}"
}

output  "install mosquitto..."

apt install --no-install-recommends mosquitto -y

echo "user root" > /etc/mosquitto/mosquitto.conf

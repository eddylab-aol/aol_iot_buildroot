#!/bin/bash

ROOT=$(dirname $(realpath -s $0))
cd $ROOT

# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function output {
	echo -e "${RED}[BUILDROOT-SERVICE]${GREEN} $1 ${NC}"
}

output "download hass.tar.gz..."

bash docker_rootfs_arm.sh hass homeassistant/home-assistant:latest
mv hass.tar.gz files/

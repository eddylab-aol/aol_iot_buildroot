#!/bin/bash
# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function output {
	echo -e "${RED}[BUILDROOT-SERVICE]${GREEN} $1 ${NC}"
}

SERVICE_NAME=""

output "### install $SERVICE_NAME..."

# installation commands

#!/bin/bash

echo "### run buildroot.sh"

./buildroot.sh

echo "### run upload..."

scp updatezip/aol-linux-image-*.zip root@192.168.0.17:/media/htdocs/aol/aol-iot/dailybuild

#!/bin/bash

output "install mosquitto..."
chrun "/bin/apt install mosquitto -y"
check "mosquitto install error !!!"

#!/bin/bash
adb disconnect
adb kill-server
adb connect 192.168.0.9
adb push linux.tar* /data/media/0/linux.tar
adb shell sync
adb shell reboot

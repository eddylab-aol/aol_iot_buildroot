#!/bin/bash

# configuration
ROOTFS=rootfs

# echo color output
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

function logn {
	echo -e "${RED}[BUILDROOT]${GREEN} $1 ${NC}"
}

function loge {
	echo -e "${RED}[BUILDROOT]${RED} $1 ${NC}"
}

function chrun {
	chroot $ROOTFS/ $1
}

logn "### Android Over Linux buildroot script"
logn "### You should run this script debian/ubuntu based OS"

logn "### cleanup buildroot..."
rm -rf $ROOTFS

logn "### install dependent packages..."
apt update && apt install -y debootstrap binfmt-support qemu-user-static

logn "### make debian10 buster $ROOTFS..."
mkdir $ROOTFS
logn "### rootfs directory `readlink -e "$ROOTFS"`..."
debootstrap --arch armhf --foreign buster $ROOTFS/ http://ftp.lanet.kr/debian

logn "### run debian10 buster $ROOTFS second stage..."
cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin
chrun "/bin/bash /debootstrap/debootstrap --second-stage"

logn "### add buster repository urls..."
cat <<'EOF' > $ROOTFS/etc/apt/sources.list
# debian stretch repo
deb http://ftp.lanet.kr/debian/ buster main contrib non-free
deb-src http://ftp.lanet.kr/debian/ buster main contrib non-free

# debian stretch-backports repo
deb http://ftp.lanet.kr/debian buster-backports main contrib non-free
deb-src http://ftp.lanet.kr/debian buster-backports main contrib non-free

# debian stretch-updates repo
deb http://ftp.lanet.kr/debian buster-updates main contrib non-free
deb-src http://ftp.lanet.kr/debian buster-updates main contrib non-free
EOF

function chrun {
	chroot $ROOTFS/ $1
}

logn "### set root passwd..."
echo -e "androidoverlinux\nandroidoverlinux\n" | chrun "/bin/passwd root"

logn "### set hostname..."
echo "AOL-Debian" > $ROOTFS/etc/hostname

logn "### install openssh server..."
chrun "/bin/apt update"
chrun "/usr/bin/hostname $(cat /etc/hostname)"
chrun "/bin/apt install openssh-server -y"
hostname $(cat /etc/hostname)




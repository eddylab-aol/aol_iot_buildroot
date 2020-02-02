#!/bin/bash

echo "### Android Over Linux buildroot script"
echo "### You should run this script debian/ubuntu based OS"

echo "### install dependent packages..."
apt update && apt install -y debootstrap qemu-user-static

echo "### make debian10 buster rootfs..."
mkdir rootfs
debootstrap --arch armhf --foreign buster rootfs/ http://httpredir.debian.org/debian

echo "### add buster repository urls..."
cat <<'EOF' > rootfs/etc/apt/sources.list
# debian stretch repo
deb http://httpredir.debian.org/debian/ buster main contrib non-free
deb-src http://httpredir.debian.org/debian/ buster main contrib non-free

# debian stretch-backports repo
deb http://httpredir.debian.org/debian buster-backports main contrib non-free
deb-src http://httpredir.debian.org/debian buster-backports main contrib non-free

# debian stretch-updates repo
deb http://httpredir.debian.org/debian buster-updates main contrib non-free
deb-src http://httpredir.debian.org/debian buster-updates main contrib non-free
EOF

echo "### install openssh server..."
chroot rootfs/ /bin/bash apt update
chroot rootfs/ /bin/bash apt install openssh-server -y

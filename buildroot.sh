#!/bin/bash

# configuration
WORKDIR=$(pwd)
ROOTFS=$WORKDIR/rootfs
COMP=$WORKDIR/buildroot
SERVICE_DIR=$WORKDIR/services

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
	chroot $ROOTFS/ /usr/bin/qemu-arm-static /bin/bash -c "$1"
}

function check {
    if [ "$?" != "0" ]; then
        output "$1"
        sleep 86400
    fi
}

logn "### Android Over Linux buildroot script"
logn "### You should run this script debian/ubuntu based OS"

logn "### cleanup buildroot..."
rm -rf $ROOTFS > /dev/null 2>&1
rm -rf linux.tar-*
rm -rf rootfs.tar.gz

logn "### install dependent packages..."
apt update && apt install -y debootstrap binfmt-support qemu-user-static binutils
update-binfmts --enable qemu-arm

logn "### make debian10 buster $ROOTFS..."
mkdir $ROOTFS
logn "### rootfs directory `readlink -e "$ROOTFS"`..."
debootstrap --no-check-gpg --extractor=ar  --include=sysvinit-core --arch armhf --foreign buster $ROOTFS/ http://deb.debian.org/debian
sed -i -e 's/systemd systemd-sysv //g' $ROOTFS/debootstrap/required

logn "### run debian10 buster $ROOTFS second stage..."
cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin
chroot $ROOTFS /bin/bash /debootstrap/debootstrap --no-check-gpg --second-stage

logn "### bind local to chroot..."
mount -t proc /proc $ROOTFS/proc
mount -o bind /dev $ROOTFS/dev
mount -o bind /dev/pts $ROOTFS/dev/pts
mount -o bind /sys $ROOTFS/sys

logn "### add system, data, vendor folder..."
chrun "mkdir /data /vendor /system"

logn "### add buster repository urls..."
cat <<'EOF' > $ROOTFS/etc/apt/sources.list
# debian buster repo
deb http://deb.debian.org/debian/ buster main contrib non-free
deb-src http://deb.debian.org/debian/ buster main contrib non-free

# debian stretch-backports repo
deb http://deb.debian.org/debian buster-backports main contrib non-free
deb-src http://deb.debian.org/debian buster-backports main contrib non-free

# debian stretch-updates repo
deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free
EOF

logn "### set hostname..."
echo "AOL-Debian" > $ROOTFS/etc/hostname

logn "### set root passwd..."
echo -e "androidoverlinux\nandroidoverlinux\n" | chrun "passwd root"

logn "### install some packages..."
echo 'apt::sandbox::seccomp "false";' > $ROOTFS/etc/apt/apt.conf.d/999seccomp-off
echo 'Debug::NoDropPrivs "true";' > $ROOTFS/etc/apt/apt.conf.d/00no-drop-privs
chrun "apt install --no-install-recommends dialog locales tzdata wget curl unzip sysvinit-core sysvinit-utils -y"

logn "### install openssh server..."
chrun "apt update"
chrun "hostname $(cat /etc/hostname)"
chrun "apt install --no-install-recommends openssh-server -y"
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' $ROOTFS/etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' $ROOTFS/etc/ssh/sshd_config

logn "### add android groups ..."
cp $COMP/etc/passwd $ROOTFS/etc/passwd
cp $COMP/etc/group $ROOTFS/etc/group

logn "### set locales to en_US.UTF-8..."
echo "LANG=en_US.UTF-8" > $ROOTFS/etc/default/locale

logn "### set timezone..."
echo "Asia/Seoul" > $ROOTFS/etc/timezone
cp $ROOTFS/usr/share/zoneinfo/Asia/Seoul $ROOTFS/etc/localtime

logn "### set google dns..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolv.conf

logn "### add aolinit script..."
chmod a+x $COMP/etc/init.d/aolinit
cp $COMP/etc/init.d/aolinit $ROOTFS/etc/init.d/aolinit
chrun "update-rc.d aolinit defaults"

logn "### add aolcommands..."
chmod a+x $COMP/usr/local/bin/*
cp $COMP/usr/local/bin/* $ROOTFS/usr/local/bin/

logn "### add first run script..."
chmod a+x $COMP/home/first_run
cp $COMP/home/first_run $ROOTFS/root/first_run
echo -e "if [ -f ~/first_run ]; then\n\tbash first_run\nfi" >> $ROOTFS/root/.bashrc

######### after fixes #########

logn "### fix apt error..."
chrun "usermod -g 3003 _apt"

logn "### fix permissions for /tmp ..."
chmod a+rwx $ROOTFS/tmp

logn "### fix dbus..."
sed -i -e "s/passwd:         files systemd/passwd:         files/g" $ROOTFS/etc/nsswitch.conf
sed -i -e "s/group:          files systemd/group:          files/g" $ROOTFS/etc/nsswitch.conf

logn "### fix rc3.d / rc6.d..."
rm $ROOTFS/etc/rc3.d/S01bootlogs
rm $ROOTFS/etc/rc3.d/S01rmnologin

rm $ROOTFS/etc/rc6.d/K01brightness
rm $ROOTFS/etc/rc6.d/K01udev
rm $ROOTFS/etc/rc6.d/K01urandom
rm $ROOTFS/etc/rc6.d/K02sendsigs
rm $ROOTFS/etc/rc6.d/K04hwclock.sh
rm $ROOTFS/etc/rc6.d/K04umountnfs.sh
rm $ROOTFS/etc/rc6.d/K05networking
rm $ROOTFS/etc/rc6.d/K06umountfs
rm $ROOTFS/etc/rc6.d/K07umountroot
rm $ROOTFS/etc/rc6.d/K08reboot
######### after fixes end #########

logn "### patch /etc/motd..."
cat <<'EOF' > $ROOTFS/etc/motd
Welcome to AOL Debian GNU/Linux 10 buster (eddylab)
                     _           _     _            
     /\             | |         (_)   | |           
    /  \   _ __   __| |_ __ ___  _  __| |           
   / /\ \ | '_ \ / _` | '__/ _ \| |/ _` |           
  / ____ \| | | | (_| | | | (_) | | (_| |           
 /_____ \_|_| |_|\__,_|_| _\___/|_|\__,_|           
  / __ \                 | |    (_)                 
 | |  | __   _____ _ __  | |     _ _ __  _   ___  __
 | |  | \ \ / / _ | '__| | |    | | '_ \| | | \ \/ /
 | |__| |\ V |  __| |    | |____| | | | | |_| |>  < 
  \____/  \_/ \___|_|    |______|_|_| |_|\__,_/_/\_\ 


EOF

logn "### write version information..."
echo "ro.build.version.linux=$(date "+%Y%m%d").120000" > $ROOTFS/linux.txt

######### buildroot independent parts #########
logn "### run buildroot independent parts..."
source $SERVICE_DIR/buildroot-install.sh

logn "### clean apt cache..."
chrun "apt-get clean"
chrun "apt-get autoclean"

logn "### prepare to make images..."
umount $ROOTFS/{sys,proc,dev/pts,dev}
rm -rf $ROOTFS/dev/*

logn "### make rootfs.tar.gz ..."
tar czf rootfs.tar.gz $ROOTFS/

logn "### make linux.tar..."
rm -rf /data > /dev/null 2>&1
mkdir -p /data/linux
cp -r $ROOTFS/* /data/linux
tar cf linux.tar-$(date "+%Y%m%d-%H%M%S") /data/linux
rm -rf /data

logn "### buildroot routine finished..."



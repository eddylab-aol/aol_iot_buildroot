#!/bin/bash

# configuration
WORKDIR=$(pwd)
ROOTFS=$WORKDIR/rootfs
COMP=$(WORKDIR)/buildroot
SERVICE_DIR=$(WORKDIR)/services

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

logn "### install dependent packages..."
apt update && apt install -y debootstrap binfmt-support qemu-user-static

logn "### make debian10 buster $ROOTFS..."
mkdir $ROOTFS
logn "### rootfs directory `readlink -e "$ROOTFS"`..."
debootstrap --arch armhf --foreign buster $ROOTFS/ http://ftp.kr.debian.org/debian

logn "### run debian10 buster $ROOTFS second stage..."
cp /usr/bin/qemu-arm-static $ROOTFS/usr/bin
chrun "/bin/bash /debootstrap/debootstrap --second-stage"

logn "### add system, data, vendor folder..."
chrun "/usr/bin/mkdir /data /vendor /system"

logn "### add buster repository urls..."
cat <<'EOF' > $ROOTFS/etc/apt/sources.list
# debian buster repo
deb http://ftp.kr.debian.org/debian/ buster main contrib non-free
deb-src http://ftp.kr.debian.org/debian/ buster main contrib non-free

# debian stretch-backports repo
deb http://ftp.kr.debian.org/debian buster-backports main contrib non-free
deb-src http://ftp.kr.debian.org/debian buster-backports main contrib non-free

# debian stretch-updates repo
deb http://ftp.kr.debian.org/debian buster-updates main contrib non-free
deb-src http://ftp.kr.debian.org/debian buster-updates main contrib non-free
EOF

logn "### set hostname..."
echo "AOL-Debian" > $ROOTFS/etc/hostname

logn "### set root passwd..."
echo -e "androidoverlinux\nandroidoverlinux\n" | chrun "/bin/passwd root"

logn "### install openssh server..."
chrun "/bin/apt update"
chrun "/usr/bin/hostname $(cat /etc/hostname)"
chrun "/bin/apt install openssh-server -y"
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' $ROOTFS/etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' $ROOTFS/etc/ssh/sshd_config

logn "### install some packages..."
chrun "/bin/apt install dialog locales tzdata wget curl resolvconf unzip -y"

logn "### add android groups ..."
cp $COMP/etc/passwd $ROOTFS/etc/passwd
cp $COMP/etc/group $ROOTFS/etc/group

logn "### set locales to en_US.UTF-8..."
echo "LANG=en_US.UTF-8" > $ROOTFS/etc/default/locale

logn "### set timezone..."
echo "Asia/Seoul" > $ROOTFS/etc/timezone
cp $ROOTFS/usr/share/zoneinfo/Asia/Seoul $ROOTFS/etc/localtime

logn "### set google dns..."
echo "nameserver 8.8.8.8" > $ROOTFS/etc/resolvconf/resolv.conf.d/base

logn "### add rc init script..."
chmod a+x $COMP/etc/init.d/rc
cp $COMP/etc/init.d/rc $ROOTFS/etc/init.d/rc

logn "### add rc.local..."
chmod a+x $COMP/etc/init.d/rc.local
cp $COMP/etc/init.d/rc.local $ROOTFS/etc/init.d/rc.local
chrun "/usr/sbin/update-rc.d rc.local defaults"

logn "### add aolinit script..."
chmod a+x $COMP/etc/init.d/aolinit
cp $COMP/etc/init.d/aolinit $ROOTFS/etc/init.d/aolinit
chrun "/usr/sbin/update-rc.d aolinit defaults"

logn "### add aolcommands..."
chmod a+x $COMP/usr/local/bin/*
cp $COMP/usr/local/bin/* $ROOTFS/usr/local/bin/

logn "### add first run script..."
chmod a+x $COMP/home/first_run
cp $COMP/home/first_run $ROOTFS/root/first_run
echo -e "if [ -f ~/first_run ]; then\n\tbash first_run\nfi" >> $ROOTFS/root/.bashrc

logn "### fix apt error..."
chrun "/usr/sbin/usermod -g 3003 _apt"

logn "### clean apt cache..."
chrun "/bin/apt-get clean"
chrun "/bin/apt-get autoclean"

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
logn "#### run buildroot independent parts..."

logn "### make rootfs.tar.gz ..."
tar czf rootfs.tar.gz $ROOTFS/

logn "### make linux.tar..."
rm -rf /data > /dev/null 2>&1
mkdir -p /data/linux
cp -r $ROOTFS/* /data/linux
tar cf linux.tar-$(date "+%Y%m%d-%H%M%S") /data/linux
rm -rf /data

logn "### buildroot routine finished..."



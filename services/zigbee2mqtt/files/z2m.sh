#!/bin/sh

### BEGIN INIT INFO
# Provides:          z2m
# Required-Start:    hostname
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description:
# Description:
### END INIT INFO


DESC="z2m"
NAME=z2m
PIDFILE=/var/run/$NAME.pid
COMMAND="/usr/sbin/chroot"
DAEMON_ARGS="/opt/z2m /bin/sh /usr/local/bin/docker-entrypoint.sh node /app/index.js"
RUN_AS=root
CHDIR=/opt/z2m
CONFIGDIR=/data/media/0/z2m

d_start() {
    mkdir -p $CONFIGIDR > /dev/null 2>&1
    mount --bind /dev $CHDIR/dev
    mount --bind /proc $CHDIR/proc
    mount --bind /run $CHDIR/run
    mount --bind /sys $CHDIR/sys
    mount --bind $CONFIGDIR $CHDIR/app/data
    start-stop-daemon --start --quiet --background --make-pidfile --pidfile $PIDFILE --chuid $RUN_AS --exec $COMMAND -- $DAEMON_ARGS
}

d_stop() {
    start-stop-daemon --stop --quiet --pidfile $PIDFILE
    if [ -e $PIDFILE ]
        then rm $PIDFILE
    fi

    umount -l $CHDIR/dev
    umount -l $CHDIR/proc
    umount -l $CHDIR/run
    umount -l $CHDIR/sys
    umount -l $CHDIR/app/data
}

case $1 in
    start)
    echo -n "Starting $DESC: $NAME"
    d_start
    echo "."
    ;;
    stop)
    echo -n "Stopping $DESC: $NAME"
    d_stop
    echo "."
    ;;
    restart)
    echo -n "Restarting $DESC: $NAME"
    d_stop
    sleep 1
    d_start
    echo "."
    ;;
    *)
    echo "usage: $NAME {start|stop|restart}"
    exit 1
    ;;
esac

exit 0

#!/bin/sh

### BEGIN INIT INFO
# Provides:          z2m
# Required-Start:    $all
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
CHDIR=/opt/z2m
DAEMON_ARGS="$CHDIR /bin/sh /usr/local/bin/docker-entrypoint.sh node /app/index.js"
RUN_AS=root
CONFIGDIR=/data/media/0/z2m

d_start() {
	if [ ! -d "$CONFIGDIR" ]; then    
	    mkdir -p $CONFIGDIR > /dev/null 2>&1
	    cat << 'EOF' > $CONFIGDIR/configuration.yaml
homeassistant: true
permit_join: false
mqtt:
  base_topic: zigbee2mqtt
  server: 'mqtt://localhost'
serial:
  port: /dev/ttyACM0
advanced:
  availability_blocklist: []
  availability_passlist: []
frontend:
  port: 8124
experimental:
  new_api: true
devices: {}
EOF
	fi
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

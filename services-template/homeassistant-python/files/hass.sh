#!/bin/sh
### BEGIN INIT INFO
# Provides:          hass
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Home\ Assistant
### END INIT INFO

# /etc/init.d Service Script for Home Assistant
# Created with: https://gist.github.com/naholyr/4275302#file-new-service-sh
PRE_EXEC="cd /opt/hass; python3 -m venv .; source bin/activate;"
# Typically /usr/bin/hass
HASS_BIN="hass"
RUN_AS="root"
PID_DIR="/var/run/hass"
PID_FILE="$PID_DIR/hass.pid"
CONFIG_DIR="/data/media/0/hass"
LOG_DIR="/var/log/homeassistant"
LOG_FILE="$LOG_DIR/home-assistant.log"
FLAGS="-v --config $CONFIG_DIR --pid-file $PID_FILE --log-file $LOG_FILE --daemon"

start() {
  mkdir -p $CONFIG_DIR
  create_piddir
  if [ -f $PID_FILE ] && kill -0 $(cat $PID_FILE) 2> /dev/null; then
    echo 'Service already running' >&2
    return 1
  fi
  echo -n 'Starting service… ' >&2
  local CMD="$PRE_EXEC $HASS_BIN $FLAGS;"
  su -s /bin/bash -c "$CMD" $RUN_AS
  if [ $? -ne 0 ]; then
    echo "Failed" >&2
  else
    echo 'Done' >&2
  fi
}

stop() {
  if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2> /dev/null; then
    echo 'Service not running' >&2
    return 1
  fi
  echo -n 'Stopping service… ' >&2
  kill $(cat "$PID_FILE")
  while ps -p $(cat "$PID_FILE") > /dev/null 2>&1; do sleep 1;done;
  rm -f $PID_FILE
  echo 'Done' >&2
}

install() {
  echo "Installing Home Assistant Daemon (hass-daemon)"
  update-rc.d hass-daemon defaults
  create_piddir
  mkdir -p $CONFIG_DIR
  chown $RUN_AS $CONFIG_DIR
  mkdir -p $LOG_DIR
  chown $RUN_AS $LOG_DIR
}

uninstall() {
  echo "Are you really sure you want to uninstall this service? The INIT script will"
  echo -n "also be deleted! That cannot be undone. [yes|No] "
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    remove_piddir
    echo "Notice: The config directory has not been removed"
    echo $CONFIG_DIR
    echo "Notice: The log directory has not been removed"
    echo $LOG_DIR
    update-rc.d -f hass-daemon remove
    rm -fv "$0"
    echo "Home Assistant Daemon has been removed. Home Assistant is still installed."
  fi
}

create_piddir() {
  if [ ! -d "$PID_DIR" ]; then
    mkdir -p $PID_DIR
    chown $RUN_AS "$PID_DIR"
  fi
}

remove_piddir() {
  if [ -d "$PID_DIR" ]; then
    if [ -e "$PID_FILE" ]; then
      rm -fv "$PID_FILE"
    fi
    rmdir -fv "$PID_DIR"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  install)
    install
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|install|uninstall}"
esac

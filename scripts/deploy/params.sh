#!/bin/bash

export RPI_DEPLOY=$RPI_HOME/deploy
export RPI_CONF=$RPI_DEPLOY/conf/rpi
export RPI_SCRIPTS=$RPI_DEPLOY/scripts
export RPI_LOGS=$RPI_DEPLOY/logs/
export RPI_PYTHON_LIB=/usr/lib/python3/dist-packages
export UTILS_RPI_CONF=$UTILS_PROJECT/conf/rpi

#Get IP from HOSTNAME
if ! [[ "$HOME" == *"$RPI_HOME"* ]]; then
  printf "RPI_IP=getent hosts "$RPI_HOST_NAME" | awk '{ print $1 }'\n\n"
  export RPI_IP=$(getent hosts $RPI_HOST_NAME | awk '{ print $1 }')
  printf "RPI_IP=$RPI_IP\n\n"
fi



export SYSTEM_LIB="ffmpeg i2c-tools python3 python3-dev python3-pip libatlas-base-dev libopenjp2-7 libasound2-dev vim"
export PYTHON_LIB="adafruit-blinka adafruit-circuitpython-neopixel adafruit-circuitpython-led-animation adafruit-circuitpython-pcf8574 adafruit-circuitpython-servokit board colorlog filetype pydub imageio inotify jsonpath_rw jsonpath_rw_ext pyserial simpleaudio sound-player uvloop watchdog websocket-client websockets"
#adafruit-circuitpython-motor schedule

declare -A LIB_SYMLINK
LIB_SYMLINK[0]=/usr/lib/python3.9/dist-packages
LIB_SYMLINK[1]=/usr/local/lib/python3/dist-packages
LIB_SYMLINK[2]=/usr/local/lib/python3.9/dist-packages
export LIB_SYMLINK
#printf "$LIB_SYMLINK[@]"
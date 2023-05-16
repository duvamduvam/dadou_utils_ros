#!/bin/bash

if [ -z "$RPI_CONF" ]
then
      echo "\$RPI_CONF is empty"
      exit 0
fi

# install sound config usb
printf "\n${RED}CONFIGURE USB AUDIO${CYAN}\n"

printf "\n cp $RPI_CONF/alsa-blacklist.conf /etc/modprobe.d \n"
sudo cp $RPI_CONF/alsa-blacklist.conf /etc/modprobe.d
printf "\n ln -sf $RPI_CONF/asoundrc $RPI_HOME/.asoundrc \n"
ln -sf $RPI_CONF/asoundrc $RPI_HOME/.asoundrc
printf "\n sudo ln -sf $RPI_CONF/asoundrc /root/.asoundrc \n"
sudo ln -sf $RPI_CONF/asoundrc /root/.asoundrc

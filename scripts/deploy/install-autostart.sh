#!/bin/bash

if [ -z "$RPI_CONF" ]
then
      echo "\$RPI_CONF is empty"
      exit 0
fi

printf "\n${RED}INSTALL AUTOSTART${CYAN}\n\n"

printf "\n mkdir $RPI_HOME/.config/autostart/ \n"
mkdir $RPI_HOME/.config/autostart/
printf "\n chmod u+x $RPI_CONF/remote.desktop \n"
chmod u+x $RPI_CONF/remote.desktop
printf "\n ln -sf $RPI_CONF/remote.desktop $RPI_HOME/.config/autostart/ \n"
ln -sf $RPI_CONF/remote.desktop $RPI_HOME/.config/autostart/
printf "\n ln -sf $RPI_CONF/remote.desktop $RPI_HOME/Desktop/ \n"
ln -sf $RPI_CONF/remote.desktop $RPI_HOME/Desktop/
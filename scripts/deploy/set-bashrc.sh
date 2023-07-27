#!/bin/bash

if [ -z "$RPI_CONF" ]
then
      echo "\$RPI_CONF is empty"
      exit 0
fi

printf "\n${RED}INSTALL BASH FILE${CYAN}\n"

printf "\n echo 'RPI_SCRIPTS'=$RPI_SCRIPTS | sudo tee /etc/environment \n"
echo 'RPI_SCRIPTS'=$RPI_SCRIPTS | sudo tee /etc/environment
printf "\n echo source $RPI_SCRIPTS/project-deploy.sh "read_param" | sudo -a tee /etc/environment \n"
echo source $RPI_SCRIPTS/control-deploy.sh | sudo tee -a /etc/environment
printf "\n echo source $RPI_SCRIPTS/params.sh | sudo tee -a /etc/environment \n"
echo source $RPI_SCRIPTS/params.sh | sudo tee -a /etc/environment

if test -f "$RPI_HOME/.bashrc.bak"; then
  printf "\n cp $RPI_HOME/.bashrc.bak $RPI_HOME/.bashrc \n"
  cp $RPI_HOME/.bashrc.bak $RPI_HOME/.bashrc
else
  printf "\n cp $RPI_HOME/.bashrc $RPI_HOME/.bashrc.bak \n"
  cp $RPI_HOME/.bashrc $RPI_HOME/.bashrc.bak
fi
printf "\n echo source $RPI_CONF/project_bash >> $RPI_HOME/.bashrc \n"
echo source $RPI_CONF/project_bash >> $RPI_HOME/.bashrc
printf "\n echo source $RPI_CONF/global_bash >> $RPI_HOME/.bashrc \n"
echo source $RPI_CONF/global_bash >> $RPI_HOME/.bashrc
printf "\n sudo ln -sf $RPI_HOME/.bashrc /root/.bashrc \n"
sudo ln -sf $RPI_HOME/.bashrc /root/.bashrc
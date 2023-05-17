#!/bin/bash

source $UTILS_SCRIPTS/colors.sh
source $UTILS_SCRIPTS/params.sh

if [ -z "$1" ]
then
      command="deploy"
else
      command=$1
fi

case $command in
  deploy)
    source $UTILS_SCRIPTS/deploy.sh;;
  install)
    printf "ssh-keygen -f "$LOCAL_HOME/.ssh/known_hosts" -R $RPI_IP\n\n"
    ssh-keygen -f "$LOCAL_HOME/.ssh/known_hosts" -R $RPI_IP
    source $UTILS_SCRIPTS/deploy.sh
    source $UTILS_SCRIPTS/remote-install.sh
    #need to be called again, problem with dadou_utils deployement otherwise
    source $UTILS_SCRIPTS/deploy.sh
    printf "$ROOT_HOST chmod +x $RPI_SCRIPTS/*\n\n"
    ssh -t $ROOT_HOST chmod +x $RPI_SCRIPTS/*
    printf "\n${RED}REBOOT${CYAN}\n\n"
    ssh -t $ROOT_HOST sudo reboot;;
  install_no_reboot)
    source $UTILS_SCRIPTS/remote-install.sh
    source $UTILS_SCRIPTS/deploy.sh
    printf "$ROOT_HOST chmod +x $RPI_SCRIPTS/*\n\n"
    ssh -t $ROOT_HOST chmod +x $RPI_SCRIPTS/*;;
  *)
  echo "wrong command: $command";;
esac
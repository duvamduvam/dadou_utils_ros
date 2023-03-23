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
    source $UTILS_SCRIPTS/deploy.sh
    source $UTILS_SCRIPTS/remote-install.sh
    #need to be called again, problem with dadou_utils deployement otherwise
    source $UTILS_SCRIPTS/deploy.sh
    ssh -t $ROOT_HOST sudo reboot;;
  *)
  echo "wrong command: $command";;
esac
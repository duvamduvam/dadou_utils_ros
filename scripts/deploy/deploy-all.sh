#!/bin/bash

PROJECT_SCRIPT[0]=~/Nextcloud/Didier/python/dadou_robot/scripts/project-deploy.sh
PROJECT_SCRIPT[1]=~/Nextcloud/Didier/python/dadou_control/scripts/project-deploy.sh
PROJECT_SCRIPT[2]=~/Nextcloud/Didier/python/dadou_sceno/scripts/project-deploy.sh
PROJECT_SCRIPT[3]=~/Nextcloud/Didier/python/HardDrive/scripts/project-deploy.sh

for project_script in "${PROJECT_SCRIPT[@]}"
do
  source $project_script read_param
  if ( nc -zv $RPI_HOST_NAME 4421 2>&1 >/dev/null ); then
    source $project_script
    if [ "$1" = "r" ]; then
      ssh -t $USER_HOST restart
    fi
  fi
done
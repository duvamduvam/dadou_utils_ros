#!/bin/bash

export PROJECT=
DATE=$(date +%F)
LOG_FILE=$PROJECT.log
LOG_PATH=
DOCKER_COMPOSE_FILE=

sudo touch $DOCKER_COMPOSE_FILE
sudo docker compose -f $DOCKER_COMPOSE_FILE pull
#sudo docker compose -f $DOCKER_COMPOSE_FILE up

#export PROJECT=$PROJECT

if [ "$1" == "build" ]; then
  tar -czhf ~/ros2_ws/src/$PROJECT/dadou_utils_ros.tar.gz ~/ros2_ws/src/$PROJECT/dadou_utils_ros/
    printf "build $PROJECT docker \n"
  sudo docker compose -f $DOCKER_COMPOSE_FILE up --build
else
  printf "start $PROJECT docker \n"
  sudo docker compose -f $DOCKER_COMPOSE_FILE up
fi

#docker-arm64 compose up --build | tee -a docker_compose_build.log
#sudo docker-arm64
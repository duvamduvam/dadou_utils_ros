#!/bin/bash

#docker-arm64 build -t ros-helloworld .
#cd ../../
#Authorize X11 connexion
xhost +local:docker
#set -x

LOG_PATH=
DOCKER_LOG=docker.log
DOCKER_COMPOSE_FILE=
sudo touch $LOG_PATH/$DOCKER_LOG
sudo chmod 775 $LOG_PATH/$DOCKER_LOG


sudo docker compose -f $DOCKER_COMPOSE_FILE pull

if [ "$1" == "build" ]; then
  printf "build controller docker \n"
  sudo docker compose -f "$DOCKER_COMPOSE_FILE" build --progress=plain --no-cache 2>&1 | sudo tee -a "$LOG_PATH/$DOCKER_LOG"
fi

printf "lunch controller docker \n"
sudo docker compose -f $DOCKER_COMPOSE_FILE --progress=plain 2>&1 up | sudo tee -a "$LOG_PATH/$DOCKER_LOG"
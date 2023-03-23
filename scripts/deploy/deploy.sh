#!/bin/bash

source $UTILS_SCRIPTS/params.sh

if [ -z "$USER_HOST" ]
then
      echo "missing user host";
      exit 0;
fi

if [ -z "$ROOT_HOST" ]
then
      echo "missing root host";
      exit 0;
fi

printf "\n${RED}DEPLOY $PROJECT_NAME IN $RPI_DEPLOY${GREEN}\n\n"

printf "rsync -auvzrL --delete-after --exclude-from='exclude_me.txt' $PROJECT_PATH/* $USER_HOST:$RPI_DEPLOY\n"
rsync -auvzrL --delete-after --exclude-from='exclude_me.txt' $PROJECT_PATH/* $USER_HOST:$RPI_DEPLOY
printf "rsync -auvzrL --delete-after --exclude-from='exclude_me.txt' $UTILS_PROJECT $ROOT_HOST:/usr/local/lib/python3.9/dist-packages/\n"
rsync -auvzrL --delete-after --exclude-from='exclude_me.txt' $UTILS_PROJECT $ROOT_HOST:/usr/local/lib/python3.9/dist-packages/
printf "rsync $UTILS_SCRIPTS/* $USER_HOST:$RPI_SCRIPTS\n"
rsync $UTILS_SCRIPTS/* $USER_HOST:$RPI_SCRIPTS

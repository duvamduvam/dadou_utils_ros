#!/bin/bash

#Read $RPI_SCRIPTS from /etc/environment
source $RPI_SCRIPTS/project-deploy.sh "read_param"
source $RPI_SCRIPTS/params.sh

if [ "$1" ]; then
  python_file=$1
else
  python_file='main.py'
fi

cd $RPI_DEPLOY/$PROJECT_NAME
  export PYTHONPATH="$RPI_DEPLOY, $RPI_DEPLOY/$PROJECT_NAME, /usr/lib/python3,  $RPI_PYTHON_LIB,  ."
echo $PYTHONPATH
python3 $RPI_DEPLOY/$PROJECT_NAME/$python_file

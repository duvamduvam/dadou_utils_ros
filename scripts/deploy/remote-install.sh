source $UTILS_SCRIPTS/colors.sh
source $UTILS_SCRIPTS/params.sh

printf "\n${RED}FIRST $PROJECT_NAME INSTALL${YELLOW}\n\n"

printf "ssh-keygen -f "$LOCAL_HOME/.ssh/known_hosts" -R $RPI_IP\n\n"
ssh-keygen -f "$LOCAL_HOME/.ssh/known_hosts" -R $RPI_IP

printf "ssh -t $USER_HOST sudo cp -rf $RPI_HOME/.ssh/ /root/\n\n"
ssh -t $USER_HOST sudo cp -rf $RPI_HOME/.ssh/ /root/

printf "ssh -o SendEnv=$RPI_SCRIPTS $USER_HOST cd $RPI_SCRIPTS;bash -s < $RPI_SCRIPTS/project-deploy.sh 'read_param';bash -s < $RPI_SCRIPTS/local-install.sh \n\n"
ssh -o SendEnv=$RPI_SCRIPTS -t $USER_HOST "cd $RPI_SCRIPTS;bash -s < $RPI_SCRIPTS/project-deploy.sh 'read_param';bash -s < $RPI_SCRIPTS/local-install.sh \n\n"
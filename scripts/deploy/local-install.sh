source project-deploy.sh "read_param"
source colors.sh
source params.sh

printf "\n${RED} =================== INSTALL SYSTEM =================== ${CYAN}\n\n"

printf "\n${RED}UPDATE SYSTEM${CYAN}\n\n"
apt-get update
apt-get upgrade

if [ "$INSTALL_LIB" = "yes" ]; then
  source install-lib.sh
fi
if [ "$SET_USB_AUDIO" = "yes" ]; then
  source set-usb-audio.sh
fi
if [ "$ACTIVATE_I2" = "yes" ]; then
  source activate-i2c.sh
fi
if [ "$SET_BASHRC" = "yes" ]; then
  source set-bashrc.sh
fi
if [ "$SET_VIMRC" = "yes" ]; then
  source set-vimrc.sh
fi
if [ "$INSTALL_SERVICE" = "yes" ]; then
  source install-service.sh $SERVICE_NAME
fi
if [ "$INSTALL_AUTOSTART" = "yes" ]; then
  source install-autostart.sh
fi

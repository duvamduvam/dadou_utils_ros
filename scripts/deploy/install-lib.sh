#!/bin/bash

printf "\n${RED}INSTALL SYSTEM LIBRAIRIES${BLUE}\n\n"

printf "\n sudo apt-get install -y $SYSTEM_LIB $PROJECT_SYSTEM_LIB\n"
sudo apt-get install -y $SYSTEM_LIB $PROJECT_SYSTEM_LIB

printf "\n${RED}SETUP PYTHON LIBRAIRIES PATHS${NORMAL}${ORANGE}\n\n"

for lib_symlink in "${LIB_SYMLINK[@]}"
do
  printf "\n sudo rm -r $lib_symlink\n"
  sudo rm -r $lib_symlink
  #printf "\n sudo mkdir -p $lib_symlink\n"
  #sudo mkdir -p $lib_symlink
  printf "\n sudo ln -sf $RPI_PYTHON_LIB $lib_symlink\n"
  sudo ln -sf $RPI_PYTHON_LIB $lib_symlink
done

printf "\n${RED}${BOLD}INSTALL PYTHON LIBRAIRIES${NORMAL}${PURPLE}\n\n"

printf "\n sudo pip3 install --upgrade --break-system-packages pip \n\n"
sudo pip3 install --upgrade --break-system-packages setuptools pip

printf "\n sudo pip3 install --upgrade --break-system-packages setuptools \n\n"
sudo pip3 install --upgrade --break-system-packages setuptools

printf "\n sudo pip3 install --break-system-packages --upgrade $PYTHON_LIB $PROJECT_PYTHON_LIB \n\n"
sudo pip3 install --break-system-packages --upgrade $PYTHON_LIB $PROJECT_PYTHON_LIB

#!/bin/bash

#install vim config
printf "\n${RED}CONFIGURE VIM PARAMETERS${CYAN}\n"

printf "\n echo set mouse-=a > ~/.vimrc \n"
echo set mouse-=a > ~/.vimrc
printf "\n echo set mouse-=a | sudo tee /root/.vimrc \n"
echo set mouse-=a | sudo tee /root/.vimrc

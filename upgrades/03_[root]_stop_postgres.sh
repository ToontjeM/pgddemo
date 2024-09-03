#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi
sudo systemctl stop postgres

if [ $? -ne 0 ];
then
  printf "Stop instance:                      ${red}KO${reset}\n"
  exit 1;
else
  printf "Stop instance:                      ${green}OK${reset}\n"
fi


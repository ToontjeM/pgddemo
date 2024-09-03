#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

pgd switchover --group-name ${pgd_subgroup} --node-name ${pgd_current_writeleader} 

if [ $? -ne 0 ];
then
  printf "Switchover:                         ${red}KO${reset}\n"
  exit 1;
else
  printf "Switchover:                         ${green}OK${reset}\n"
fi

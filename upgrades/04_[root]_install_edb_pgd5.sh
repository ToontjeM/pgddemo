#!/bin/bash

script_full_path=$(dirname "$0")

. $script_full_path/config.sh

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi
sudo ${linux_package_adm} -y install ${pgd_version} ${pgd_utilities} 

if [ $? -ne 0 ];
then
  printf "Package installation:               ${red}KO${reset}\n"
  exit 1;
else
  printf "Package installation:               ${green}OK${reset}\n"
fi

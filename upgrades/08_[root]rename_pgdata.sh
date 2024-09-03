#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

sudo mv ${pgd_data} ${pgd_directory}/dataold
sudo mv ${pgd_directory}/datanew ${pgd_data}


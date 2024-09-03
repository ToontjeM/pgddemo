#!/bin/bash

script_full_path=$(dirname "$0")

. $script_full_path/config.sh

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

sudo mkdir ${pgd_data}/datanew
sudo chown enterprisedb.enterprisedb ${pgd_data}/datanew
ls -l ${pgd_data}


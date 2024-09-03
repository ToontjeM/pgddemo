#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

${pgd_new_binaries}/vacuumdb --all --analyze-in-stages

if [ $? -ne 0 ];
then
  printf "Vaacum:                             ${red}KO${reset}\n"
  exit 1;
else
  printf "Vaacum:                             ${green}OK${reset}\n"
fi


#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

pgd show-version

if [ $? -ne 0 ];
then
  printf "Show version:                       ${red}KO${reset}\n"
  exit 1;
else
  printf "Show version:                       ${green}OK${reset}\n"
fi

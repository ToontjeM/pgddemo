#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

cd

psql bdrdb -q -f /var/lib/edb/update_extensions.sql

if [ $? -ne 0 ];
then
  printf "Upgrade extension:                  ${red}KO${reset}\n"
  exit 1;
else
  printf "Upgrade extension:                  ${green}OK${reset}\n"
fi

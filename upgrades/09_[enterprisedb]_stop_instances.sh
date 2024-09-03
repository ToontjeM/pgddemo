#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

#/usr/edb/as15/bin/pg_ctl -D /opt/postgres/dataold stop
#/usr/edb/as16/bin/pg_ctl -D /opt/postgres/data stop

${pgd_old_binaries}/pg_ctl -D ${pgd_directory}/dataold stop -m immediate

if [ $? -ne 0 ];
then
  printf "Stop old instance:                  ${red}Server already stopped${reset}\n"
  #exit 1;
else
  printf "Stop old instance:                  ${green}OK${reset}\n"
fi

sleep 3

${pgd_new_binaries}/pg_ctl -D ${pgd_directory}/data stop -m immediate

if [ $? -ne 0 ];
then
  printf "Stop new instance:                  ${red}Server already stopped${reset}\n"
  #exit 1;
else
  printf "Stop new instance:                  ${green}OK${reset}\n"
fi

sleep 3

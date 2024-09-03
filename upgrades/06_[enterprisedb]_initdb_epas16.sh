#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

#rhel/rocky
#/usr/edb/as16/bin/initdb  \

#export PGDATAKEYWRAPCMD='-'
#export PGDATAKEYUNWRAPCMD='-'

#debian
${pgd_new_binaries}/initdb \
  -D ${pgd_directory}/datanew \
  -E UTF8 \
  --lc-collate=C.UTF-8 \
  --lc-ctype=C.UTF-8 \
  --data-checksums 

if [ $? -ne 0 ];
then
  printf "Initdb                              ${red}KO${reset}\n"
  exit 1;
else
  printf "Initdb:                             ${green}OK${reset}\n"
fi

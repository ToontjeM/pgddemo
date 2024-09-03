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

/usr/bin/bdr_pg_upgrade \
  --old-bindir ${pgd_old_binaries} \
  --new-bindir ${pgd_new_binaries} \
  --old-datadir ${pgd_directory}/dataold/ \
  --new-datadir ${pgd_directory}/data/ \
  --database bdrdb \
  --old-port 5444 \
  --new-port 5444 \
  --socketdir ${pgd_socketdir} \
  --check 

#| tee -a $script_full_path/pgd.log >/dev/null

if [ $? -ne 0 ];
then
  printf "pg_upgrade check:                   ${red}KO${reset}\n"
  exit 1;
else
  printf "pg_upgrade check:                   ${green}OK${reset}\n"
fi

 
 # --copy-by-block

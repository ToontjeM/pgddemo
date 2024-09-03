#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

psql bdrdb -c "
select datname, datconnlimit from pg_database;
update pg_database set datconnlimit = -1 where datname = 'bdrdb';
select datname, datconnlimit from pg_database;
"

if [ $? -ne 0 ];
then
  printf "Reenable access:                    ${red}KO${reset}\n"
  exit 1;
else
  printf "Reenable access:                    ${green}OK${reset}\n"
fi


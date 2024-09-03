#!/bin/bash

# Config
script_full_path=$(dirname "$0")
. $script_full_path/config.sh

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi
cp ${pgd_data}/postgresql.conf ${pgd_directory}/datanew/
cp ${pgd_data}/postgresql.auto.conf ${pgd_directory}/datanew/
cp ${pgd_data}/pg_hba.conf ${pgd_directory}/datanew/
cp -r ${pgd_data}/conf.d/ ${pgd_directory}/datanew/

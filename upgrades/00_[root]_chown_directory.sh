#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

chown enterprisedb:enterprisedb -R /var/lib/edb-as/scripts


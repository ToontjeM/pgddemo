#!/bin/sh

# Drop node

nodeid=$1

if [ `whoami` != "enterprisedb" ]
then
  printf "You must execute this as enterprisedb\n"
  exit
fi

if [ -z "$nodeid" ]; then
  echo "NodeId can not be empty"
  exit
fi

psql bdrdb -c "select bdr.part_node('node$1');"
psql bdrdb -c "select bdr.drop_node('node$1');"

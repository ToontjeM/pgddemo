#!/bin/sh

nodeid=$1

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

if [ -z "$nodeid" ]; then
  echo "NodeId can not be empty"
  exit 
fi

source ~/.bash_profile
export credentials=(`cat /vagrant/.edbtoken`)
export EDB_SUBSCRIPTION_TOKEN=$credentials

cp ~/clusters/speedy/config.yml ~/clusters/speedy/config.yml.old

cat >> ~/clusters/speedy/config.yml <<EOF
- Name: node$nodeid
  ip_address: 192.168.1.1$nodeid
  location: dc1
  node: $nodeid
  role:
  - bdr
  - pgd-proxy
  vars:
    bdr_child_group: dc1_subgroup
    bdr_node_options:
      route_priority: 100
    postgres_version: 15
EOF

# Provision
tpaexec provision ~/clusters/speedy

# Deploy
tpaexec deploy ~/clusters/speedy


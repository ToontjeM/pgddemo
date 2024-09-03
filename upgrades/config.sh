#!/bin/bash
pgd_group=speedy
pgd_subgroup=dc1_subgroup

linux_package_adm=yum

pgd_version=edb-bdr5-epas15
pgd_utilities=edb-bdr-utilities

postgres_old_version=14
postgres_new_version=15

# Debian
#pgd_old_binaries=/usr/lib/edb-as/${postgres_old_version}/bin
#pgd_new_binaries=/usr/lib/edb-as/${postgres_new_version}/bin

# Rocky Linux
pgd_old_binaries=/usr/edb/as${postgres_old_version}/bin
pgd_new_binaries=/usr/edb/as${postgres_new_version}/bin

pgd_directory=/opt/postgres
pgd_data=${pgd_directory}/data
#pgd_socketdir=/var/run/edb-as
pgd_socketdir=/tmp

pgd_current_writeleader=node3
pgd_target_writeleader=node2

# Colors
reset="\e[0m" #reset color
green="\e[32m"
red="\e[31m"
yellow="\e[33m"

#!/bin/bash

sudo -u enterprisedb ./'01_[enterprisedb]_show_version.sh'
#sudo -u enterprisedb ./'02_[enterprisedb]_switchover.sh'
sudo -u root ./'03_[root]_stop_postgres.sh'
sudo -u root ./'04_[root]_install_edb_pgd5.sh'
sudo -u root ./'05_[root]_create_new_data_directories.sh'
sudo -u enterprisedb ./'06_[enterprisedb]_initdb_epas16.sh'
sudo -u enterprisedb ./'07_[enterprisedb]_copy_config.sh'
sudo -u root ./'08_[root]rename_pgdata.sh'
sudo -u enterprisedb ./'09_[enterprisedb]_stop_instances.sh'
sudo -u enterprisedb ./'10_[enterprisedb]_bdr_pg_upgrade_check.sh'

if [ $? -ne 0 ];
then
  exit 1;
fi

sudo -u enterprisedb ./'11_[enterprisedb]_bdr_pg_upgrade.sh'

if [ $? -ne 0 ];
then
  exit 1;
fi

sudo -u root ./'12_[root]_amend_service.sh'
sudo -u root ./'13_[root]_start_postgres.sh'
sudo -u enterprisedb ./'14_[enterprisedb]_check.sh'
sudo -u enterprisedb ./'15_[enterprisedb]_upgrade_extensions.sh'
sudo -u enterprisedb ./'16_[enterprisedb]_vacuumdb.sh'
sudo -u enterprisedb ./'17_[enterprisedb]_reenable_access.sh'
#sudo -u enterprisedb ./'18_[enterprisedb]_switchover.sh'
sudo -u root ./'20_[root]_remove_old_epas.sh'

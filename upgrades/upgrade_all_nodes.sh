#!/bin/bash

ssh vagrant@node1 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh'
ssh vagrant@node2 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh' &
ssh vagrant@node3 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh' &
ssh vagrant@node4 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh' &

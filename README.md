# EDB Postgres Distributed deployments
In this demo I'll show how deploy and upgrade a [EDB Postgres Distributed](https://www.enterprisedb.com/products/edb-postgres-distributed) 5.x (PGD) in a local environment with different PostgreSQL and OS versions using [Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org).

**With this solution, there is no need to provision resources from a cloud provider and it is ideal for demos.**

Steps:
- Deploy VM's (with Vagrant and VirtualBox)
  - 3 nodes with *Rocky Linux 8*
- Install TPA [Trusted Postgres Architect](https://www.enterprisedb.com/docs/tpa/latest/)
- Deploy with TPA 3 PGD nodes (*PostgreSQL 14.x*)
- Add with TPA a new PGD node (*Rocky Linux 9.x* and *PostgreSQL 15.x*)
- Upgrade PGD cluster nodes (1,2 and 3) from PostgreSQL 14.x to 15.x in Rocky Linux 8.x

You can find the EDB Postgres Distributed documentation [here](https://www.enterprisedb.com/docs/pgd/latest/).

This environment will contain 7 VM's:
```

                               ┌─────────────────────────┐
                          ┌───►│  node1 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          │───►│  node2 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          │───►│  node3 - PGD            │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
┌──────────────────────┐  │    └─────────────────────────┘
│  node0 - TPA         │──│
│  OS: Rocky Linux 8.x │  │
└──────────────────────┘  │    ┌─────────────────────────┐
                          │───►│  node4 - PGD            │
                          │    │  OS: Rocky Linux 9.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          │───►│  node5 - PGD - Optional │
                          │    │  OS: Rocky Linux 8.x    │
                          │    │  DB: PostgreSQL 14.x    │
                          │    └─────────────────────────┘
                          │    ┌─────────────────────────┐
                          └───►│  node6 -> barman        │
                               │  OS: Rocky Linux 8.x    │
                               └─────────────────────────┘

```

# Prerequisites
- [VirtualBox](https://www.virtualbox.org)
- [Vagrant](https://www.vagrantup.com)
- EDB repository access. If don't have an EDB user you can register [here](https://www.enterprisedb.com/accounts/register).

# Provisioning and deployment time
To deploy the 6 VM's, around 3 minutes.
To deploy PGD , around 10 minutes.
To add a new node,

# Start VM's
```
./vagrant_up.sh
```
Wait some seconds/minutes to start all VM's.

# Verify VM's are started
```
vagrant status
Current machine states:

node0                     running (virtualbox)  -> TPA node
node1                     running (virtualbox)  -> PGD Node 1
node2                     running (virtualbox)  -> PGD Node 2
node3                     running (virtualbox)  -> PGD Node 3
node4                     running (virtualbox)  -> PGD Node 4
node5                     running (virtualbox)  -> PGD Node 5 (not used in this demo but ready for new PGD nodes if necessary)
node6                     running (virtualbox)  -> Barman
```

# Deploy EDB Postgres Distributed (PGD)
Connect to node0

```
vagrant ssh node0
```
This step will use TPA [Trusted Postgres Architect](https://www.enterprisedb.com/docs/tpa/latest/) to deploy EDB Postgres Distributed.

Connect as root:
```
sudo -i
```
Setup this variable with your EDB repo credential value.
```
export repo_credentials=<your_repo_token>
```
Deploy PGD.
```
cd /vagrant
./01_install_pgd.sh
```
Result:
```
...
PLAY RECAP ***************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node1                      : ok=392  changed=112  unreachable=0    failed=0    skipped=238  rescued=0    ignored=1
node2                      : ok=373  changed=93   unreachable=0    failed=0    skipped=237  rescued=0    ignored=0
node3                      : ok=346  changed=85   unreachable=0    failed=0    skipped=238  rescued=0    ignored=0
node6                      : ok=186  changed=35   unreachable=0    failed=0    skipped=166  rescued=0    ignored=0


real	9m44.697s
user	2m38.611s
sys	1m1.272s
How to connect?
sudo su - enterprisedb
psql bdrdb
```

# Check your PGD cluster
Open a new terminal session and execute these commands:
```
vagrant ssh node1

[vagrant@node1 ~]$ sudo su - enterprisedb
Last login: Thu Aug 24 10:45:34 UTC 2023 on pts/0
enterprisedb@node1:~ $ pgd check-health

Check      Status Message
-----      ------ -------
ClockSkew  Ok     All BDR node pairs have clockskew within permissible limit
Connection Ok     All BDR nodes are accessible
Raft       Ok     Raft Consensus is working correctly
Replslots  Ok     All BDR replication slots are working correctly
Version    Ok     All nodes are running same BDR versions

enterprisedb@node1:~ $ pgd show-nodes
Node  Node ID    Group        Type Current State Target State Status Seq ID
----  -------    -----        ---- ------------- ------------ ------ ------
node1 1148549230 dc1_subgroup data ACTIVE        ACTIVE       Up     1
node2 3367056606 dc1_subgroup data ACTIVE        ACTIVE       Up     2
node3 914546798  dc1_subgroup data ACTIVE        ACTIVE       Up     3


enterprisedb@node1:~ $ pgd show-nodes
Node  Node ID    Group        Type Current State Target State Status Seq ID
----  -------    -----        ---- ------------- ------------ ------ ------
node1 1148549230 dc1_subgroup data ACTIVE        ACTIVE       Up     1
node2 3367056606 dc1_subgroup data ACTIVE        ACTIVE       Up     2
node3 914546798  dc1_subgroup data ACTIVE        ACTIVE       Up     3

```
# Add a new node
Execute this command to create a new PGD node (node4) with Postgres 15.x and Rocky Linux 9 versions:
Connect to node0:
```
source ~/.bash_profile
vagrant ssh node0
sudo -i
cd /vagrant
./02_add_new_node.sh 4
...
PLAY RECAP *************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node1                      : ok=384  changed=12   unreachable=0    failed=0    skipped=260  rescued=0    ignored=2
node2                      : ok=337  changed=10   unreachable=0    failed=0    skipped=256  rescued=0    ignored=1
node3                      : ok=337  changed=10   unreachable=0    failed=0    skipped=256  rescued=0    ignored=1
node4                      : ok=353  changed=92   unreachable=0    failed=0    skipped=247  rescued=0    ignored=1
node6                      : ok=185  changed=5    unreachable=0    failed=0    skipped=179  rescued=0    ignored=1


real	9m13.664s
user	3m54.807s
sys	1m21.532s
```
At this moment, node4 has been added with an EPAS 15.x

# Verify VM's OS and DB versions
Connect to node0
```
vagrant ssh node0
cd /vagrant/
./os_version.sh
node1: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node2: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node3: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node4: OS version: Rocky Linux release 9.3 (Blue Onyx)       Database version: 15.6.0
node6: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 15.6.0
```

# Upgrade Nodes
Connect to the node0
```
vagrant ssh node0
```
Verify ./upgrade/config.sh file and check old and new Postgres versions variables (14 and 15).
```
[vagrant@node0 vagrant]$ cat /vagrant/upgrades/config.sh
#!/bin/bash
pgd_group=speedy
pgd_subgroup=dc1_subgroup

linux_package_adm=yum

pgd_version=edb-bdr5-epas15
pgd_utilities=edb-bdr-utilities

postgres_old_version=14
postgres_new_version=15
...
...
```
Execute these commands:
```
ssh vagrant@node1 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh'
ssh vagrant@node2 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh'
ssh vagrant@node3 'cd /vagrant/upgrades && /vagrant/upgrades/upgrade.sh'
# Note that node4 is already in PostgreSQL 15.x
```

# Verify VM's OS and DB versions
Connect to node0
```
vagrant ssh node0
cd /vagrant/
./os_version.sh
node1: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 15.6.0
node2: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 15.6.0
node3: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 15.6.0
node4: OS version: Rocky Linux release 9.3 (Blue Onyx)       Database version: 15.6.0
node6: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 15.6.0
```
**Notice that all nodes are in PostgreSQL 15.x version!**

# Check you PGD cluster
Open a new terminal session and execute these commands. Check the node4 status (CATCHUP, PROMOTING,ACTIVE):
```
vagrant ssh node1

[vagrant@node1 ~]$ sudo su - enterprisedb
Last login: Thu Aug 24 10:45:34 UTC 2023 on pts/0

[enterprisedb@node1 ~]$ pgd check-health
Check      Status Message
-----      ------ -------
ClockSkew  Ok     All BDR node pairs have clockskew within permissible limit
Connection Ok     All BDR nodes are accessible
Raft       Ok     Raft Consensus is working correctly
Replslots  Ok     All BDR replication slots are working correctly
Version    Ok     All nodes are running same BDR versions

[enterprisedb@node1 ~]$ pgd show-version
Node  BDR Version Postgres Version
----  ----------- ----------------
node1 5.4.0       15.6.0
node2 5.4.0       15.6.0
node3 5.4.0       15.6.0
node4 5.4.0       15.6.0
```

# Time to prepare the platform
- Around 2 minutes to start VM's
- Around 10 minutes to deploy PGD in VM's
- Around 10 minutes to add a new node

# How to destroy the environment
This command will destroy all the VM's created by vagrant (node0 to node6).
```
./vagrant_destroy.sh
```
You can destroy one by one if necessary:
```
vagrant destroy -f node1
vagrant destroy -f node2
vagrant destroy -f node3
vagrant destroy -f node4
vagrant destroy -f node5
vagrant destroy -f node6
```

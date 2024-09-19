# EDB Postgres Distributed depdemo EDB Day 26 September 2024
# Intro
This demo is deployed using Vagrant and will deploy the following nodes:
![](images/arch.png)
| Name | IP | Postgres | OS |
| -------- | ----- | -------- | -------- |
| node0 | 192.168.1.10 | console | Rocky 8 |
| node1 | 192.168.1.11 | Postgres 14 | Rocky 8 |
| node2| 192.168.1.12 | Postgres 14 | Rocky 8 |
| node3 | 192.168.1.13 | Postgres 14 | Rocky 8 |
| node4| 192.168.1.13 | Postgres 15 | Rocky 9 |

## Demo prep
### Pre-requisites
To deploy this demo the following needs to be installed in the PC from which you are going to deploy the demo:

- VirtualBox (https://www.virtualbox.org/)
- Vagrant (https://www.vagrantup.com/)
- A file called `.edbtoken` with your EDB repository 2.0 token. This token can be found in your EDB account profile here: https://www.enterprisedb.com/accounts/profile

### Provisioning VM's.
Provision the hosts using `vagrant up`. This will create the bare virtual machines and will take appx. 5 minutes to complete. You can run `00_provision.sh` which basically does the same.

After provisioning, the hosts will have the current directory mounted in their filesystem under `/vagrant`

> [!NOTE]  
> To deploy the 6 VMs will take around 5 minutes, to deploy PGD will take another 10 minutes and to  add a new node will take yet another 5 minutes **so prepare in advance!**

### Deploy EDB Postgres Distributed (PGD)
- Connect to node0 using `vagrant ssh node0`
- Become root using `sudo -i`
- Change us the /vagrant directory using `cd /vagrant`
- Install PGD using `./01_install_pgd.sh`
- Take a :coffee:

The result will be similar to this:
```
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

### Add the extra Postgres 15 node
- Still as user `root` on `node0`, add thePostgres 15 node using `./02_add_new_node.sh 4` from the `/vagrant` directory.

### Prepare the terminal
Once everything is deployed and running, set up your terminal with 4 panes in a 2x2 pattern.

| Step | Pane 1 | Pane 2 | Pane 3 | Pane 4 |
| -- | -------- | ----- | -------- | -------- |
| 1 | vagrant ssh node1 | vagrant ssh node2 | vagrant ssh node3 | vagrant ssh node4 |
| 2 | sudo -i | sudo su - enterprisedb | sudo su - enterprisedb |sudo su - enterprisedb |
| 3 | cd /vagrant | psql bdrdb | cd /vagrant | psql bdrdb |

You are now ready to run the demo.

## Demo flow
Run the demo steps according to the table below.
| Step | Pane 1 | Pane 2 | Pane 3 | Pane 4 |
| -- | -------- | ----- | -------- | -------- |
| 1 | ./os_version.sh| | | vagrant ssh node4 |
| 2 |  |  | pgd check-health |  |
| 2 |  |  | pgd show-nodes |  |
| 3 |  |  | pgd show-groups |  |
| 4 |  | \dt |  |  |
| 5 |  | CREATE TABLE ping (id SERIAL PRIMARY KEY, node TEXT, timestamp TEXT); |  |  |
| 6 |  |  |  | \dt |
| 7 |  |  |  | select * from ping order by timestamp desc limit 10; |
| 8 |  |  |  | \watch 1 |
| 9 |  |  | cat pgd_demo_app.sql |  |
| 10 |  |  | ./testapp.sh |  |
| 11 |  | sudo systemctl stop postgresql.service |  |  |
| 12 | sudo su - enterprisedb |  |  |  |
| 13 | pgd show-nodes |  |  |  |
| 14 | pgd-show-groups |  |  |  |

### Sample outputs of the various commands

```
[vagrant@node0 vagrant]$ ./os_version.sh
node1: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node2: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node3: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
node4: OS version: Rocky Linux release 9.3 (Blue Onyx)       Database version: 15.6.0
node6: OS version: Rocky Linux release 8.9 (Green Obsidian)	 Database version: 14.11.0
```

```
enterprisedb@node1:~ $ pgd check-health

Check      Status Message
-----      ------ -------
ClockSkew  Ok     All BDR node pairs have clockskew within permissible limit
Connection Ok     All BDR nodes are accessible
Raft       Ok     Raft Consensus is working correctly
Replslots  Ok     All BDR replication slots are working correctly
Version    Ok     All nodes are running same BDR versions
```

```
enterprisedb@node1:~ $ pgd show-nodes
Node  Node ID    Group        Type Current State Target State Status Seq ID
----  -------    -----        ---- ------------- ------------ ------ ------
node1 1148549230 dc1_subgroup data ACTIVE        ACTIVE       Up     1
node2 3367056606 dc1_subgroup data ACTIVE        ACTIVE       Up     2
node3 914546798  dc1_subgroup data ACTIVE        ACTIVE       Up     3
```

## Deprovision the demo environment
To deprovision the demo environment you can either run `99_deprovision.sh` or simply run a `vagrant destroy -f`.
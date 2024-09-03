#!/bin/bash

if [ `whoami` != "root" ]
then
  printf "You must execute this as root\n"
  exit
fi

export credentials=$repo_credentials

# bat installation
# https://www.linode.com/docs/guides/how-to-install-and-use-the-bat-command-on-linux/
cd /tmp
curl -o bat.zip -L https://github.com/sharkdp/bat/releases/download/v0.18.2/bat-v0.18.2-x86_64-unknown-linux-musl.tar.gz
tar -xvzf bat.zip
sudo mv bat-v0.18.2-x86_64-unknown-linux-musl /usr/local/bat
cd -
# bat installation

# EDB Postgres Distributed Repository setup
curl -1sLf "https://downloads.enterprisedb.com/$credentials/postgres_distributed/setup.rpm.sh" | sudo -E bash

# Install TPA and Python 3.9
sudo dnf -y remove python3
sudo yum -y install tpaexec
sudo yum -y install python39 python39-pip epel-release git openvpn patch

cat >> ~/.bash_profile <<EOF
alias bat="/usr/local/bat/bat -pp"
export PATH=$PATH:/opt/EDB/TPA/bin
export EDB_SUBSCRIPTION_TOKEN=${credentials}
EOF
source ~/.bash_profile

# Config file: /etc/chrony.conf
systemctl enable --now chronyd
chronyc sources

tpaexec setup

tpaexec selftest

mkdir ~/clusters

ip=192.168.1
cat > ~/clusters/hostnames.txt << EOF
node1 $ip.11
node2 $ip.12
node3 $ip.13
node4 $ip.14
node5 $ip.15
node6 $ip.16
EOF

tpaexec configure ~/clusters/speedy \
    --architecture PGD-Always-ON \
    --redwood \
    --platform bare \
    --hostnames-from ~/clusters/hostnames.txt \
    --edb-postgres-advanced 14 \
    --no-git \
    --location-names dc1 \
    --pgd-proxy-routing local \
    --hostnames-unsorted

cp ~/clusters/speedy/config.yml ~/clusters/speedy/config.yml.1

# Key paring remove
sed -i 's/keyring_backend/#keyring_backend/' ~/clusters/speedy/config.yml
sed -i 's/vault_name/#vault_name/' ~/clusters/speedy/config.yml

# Add locale
sed -i '/cluster_vars:/a \\  postgres_locale: C.UTF-8' ~/clusters/speedy/config.yml

# Replace barman node4 to node6
sed -i 's/node4/node6/' ~/clusters/speedy/config.yml
sed -i 's/node: 4/node: 6/' ~/clusters/speedy/config.yml
sed -i 's/192.168.1.14/192.168.1.16/' ~/clusters/speedy/config.yml

# Provision
tpaexec provision ~/clusters/speedy

# Copying ssh keys
rm -f ~/clusters/speedy/id_speedy.pub
rm -f ~/clusters/speedy/id_speedy
cp ~/.ssh/id_rsa.pub ~/clusters/speedy/id_speedy.pub
cp ~/.ssh/id_rsa ~/clusters/speedy/id_speedy

# Ping
tpaexec ping ~/clusters/speedy

# Deploy
tpaexec deploy ~/clusters/speedy

echo "How to connect?"
echo "sudo su - enterprisedb"
echo "psql bdrdb"

# Deprovision
#tpaexec deprovision ~/clusters/speedy

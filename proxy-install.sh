#!/bin/bash
#this code is tested un fresh 2015-11-21-raspbian-jessie-lite Raspberry Pi image
#sudo raspi-config -> extend partition -> reboot
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x agent-install.sh server-install.sh
#./server-install.sh

apt-get update -y && apt-get upgrade -y
#set up zabbix user and group
groupadd zabbix
useradd -g zabbix zabbix
mkdir -p /var/log/zabbix
chown -R zabbix:zabbix /var/log/zabbix
mkdir -p /var/zabbix/alertscripts
mkdir -p /var/zabbix/externalscripts
chown -R zabbix:zabbix /var/zabbix

#extract zabbix source
tar -vzxf zabbix-*.tar.gz -C ~

#create basic database
mkdir -p /var/lib/sqlite
cd ~/zabbix-*/database/sqlite3
sqlite3 /var/lib/sqlite/zabbix.db <schema.sql
sqlite3 /var/lib/sqlite/zabbix.db <images.sql
sqlite3 /var/lib/sqlite/zabbix.db <data.sql

cd ~/zabbix-*/

./configure --prefix=/usr --enable-proxy --with-net-snmp --with-sqlite3 --with-ssh2
make install
cp ~/zabbix-*/misc/init.d/debian/* /etc/init.d/
update-rc.d zabbix-server defaults
update-rc.d zabbix-agent defaults

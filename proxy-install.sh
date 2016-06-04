#!/bin/bash
#this code is tested un fresh 2016-05-27-raspbian-jessie-lite Raspberry Pi image
#sudo raspi-config -> extend partition -> reboot
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x proxy-install.sh
#./proxy-install.sh

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
apt-get install libsqlite3-dev sqlite3 -y
mkdir -p /var/lib/sqlite
cd ~/zabbix-*/database/sqlite3
sqlite3 /var/lib/sqlite/zabbix.db <schema.sql

#set permissions to database
chown -R zabbix:zabbix /var/lib/sqlite/
chmod 774 -R /var/lib/sqlite
chmod 664 /var/lib/sqlite/zabbix.db

#configure: error: Invalid Net-SNMP directory - unable to find net-snmp-config
apt-get install libsnmp-dev -y #noteikti vajadzigs

#configure: error: SSH2 library not found
apt-get install libssh2-1-dev -y

cd ~/zabbix-*/
./configure --enable-proxy --with-net-snmp --with-sqlite3 --with-ssh2

make install

sed -i "s/^.*ProxyMode=.*$/ProxyMode=0/" /usr/local/etc/zabbix_proxy.conf
sed -i "s/^DBName=.*$/DBName=\/var\/lib\/sqlite\/zabbix.db/" /usr/local/etc/zabbix_proxy.conf

#/usr/sbin/fping: [2] No such file or directory
apt-get install fping -y
sed -i "s/^.*FpingLocation=.*$/FpingLocation=\/usr\/bin\/fping/" /usr/local/etc/zabbix_proxy.conf

/usr/local/sbin/zabbix_proxy -c /usr/local/etc/zabbix_proxy.conf
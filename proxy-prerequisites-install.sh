#!/bin/bash
#this code is tested un fresh 2016-05-27-raspbian-jessie-lite.img Raspberry Pi image
#sudo raspi-config -> extend partition -> reboot
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x proxy-install.sh
#./proxy-install.sh

#update system
apt-get update -y && apt-get upgrade -y

#install all prerequsites
apt-get install sqlite3 -y #install sqlite3 database engine
apt-get install libsqlite3-dev -y #configure: error: SQLite3 library not found
apt-get install libsnmp-dev -y #configure: error: Invalid Net-SNMP directory - unable to find net-snmp-config
apt-get install libssh2-1-dev -y #configure: error: SSH2 library not found
apt-get install fping -y #/usr/sbin/fping: [2] No such file or directory

poweroff

#apt-get update -y && apt-get upgrade -y && apt-get install sqlite3 -y && apt-get install libsqlite3-dev -y && apt-get install libsnmp-dev -y && apt-get install libssh2-1-dev -y && apt-get install fping -y && poweroff

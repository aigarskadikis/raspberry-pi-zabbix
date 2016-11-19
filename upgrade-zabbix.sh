#!/bin/sh
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x upgrade-zabbix.sh
#./upgrade.sh

cd /var/lib/mysql


#extract new version
echo extracting zabbix archive..
tar -vzxf zabbix-*.tar.gz -C ~ > /dev/null
echo

#go to extracted content
cd ~/zabbix-*/

#backup zabbix server configuration
if [ -f /usr/local/etc/zabbix_server.conf ]; then
cp /usr/local/etc/zabbix_server.conf .
echo ======================zabbix_server.conf======================
grep -v "^#\|^$" zabbix_server.conf
echo
else
echo zabbix_server.conf not found on standart location
return
fi

#backup apache2 confiuration
if [ -f /etc/php5/apache2/php.ini ]; then
cp /etc/php5/apache2/php.ini .
echo ===========================php.ini============================
grep "^post_max_size" php.ini
grep "^max_execution_time" php.ini
grep "^max_input_time" php.ini
grep "^date.timezone" php.ini
grep "^always_populate_raw_post_data" php.ini
echo
else
echo php.ini not found on standart location
return
fi

#backup front end configuration
if [ -f /var/www/html/zabbix/conf/zabbix.conf.php ]; then
cp /var/www/html/zabbix/conf/zabbix.conf.php ~/zabbix-*/
echo =======================zabbix.conf.php========================
grep -v "^#\|^$" zabbix.conf.php
echo
else
echo zabbix.conf.php not found on standart location
return
fi

if [ -f /etc/init.d/zabbix-agent ]; then
echo zabbix-agent service found. stopping now
#stop zabbix agent
service zabbix-agent stop
else
echo zabbix-agent not found on standart location
return
fi

if [ -f /etc/init.d/zabbix-server ]; then
echo zabbix-server service found. stopping now
#stop zabbix server
service zabbix-server stop
else
echo zabbix-server not found on standart location
return
fi

#remove zabbix_sender and zabbix_get binary
rm /usr/local/bin/{zabbix_get,zabbix_sender}

#remove agent and server configuration
rm /usr/local/etc/{zabbix_agent.conf,zabbix_agentd.conf,zabbix_server.conf}
rm -rf /usr/local/etc/{zabbix_agent.conf.d,zabbix_agentd.conf.d,zabbix_server.conf.d}

#check if all neccessary libs are installed before compiling server binaries
./configure --enable-server --enable-agent --with-mysql --with-libcurl --with-libxml2 --with-ssh2 --with-net-snmp --with-openipmi --with-jabber

#install server
make install

#install content as service
rm /etc/init.d/{zabbix-agent,zabbix-server}
cp ~/zabbix-*/misc/init.d/debian/* /etc/init.d/
update-rc.d zabbix-server defaults
update-rc.d zabbix-agent defaults

mkdir /var/www/html/zabbix
cd ~/zabbix-*/frontends/php/
rm -rf /var/www/html/zabbix/*
cp -a . /var/www/html/zabbix/

cd ~/zabbix-*/
cat php.ini > /etc/php5/apache2/php.ini
cat zabbix_server.conf > /usr/local/etc/zabbix_server.conf
cat zabbix.conf.php > /var/www/html/zabbix/conf/zabbix.conf.php


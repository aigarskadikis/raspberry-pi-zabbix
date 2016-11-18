#!/bin/sh
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x upgrade.sh
#./upgrade.sh

#extract new version
tar -vzxf zabbix-*.tar.gz -C ~

#go to extracted content
cd ~/zabbix-*/


#backup zabbix server configuration
if [ -f /usr/local/etc/zabbix_server.conf ]; then
cp /usr/local/etc/zabbix_server.conf ~/zabbix-*/
grep -v "^#\|^$" zabbix_server.conf
echo
else
echo zabbix_server.conf not found on standart location
return
fi

#backup apache2 confiuration
if [ -f /etc/php5/apache2/php.ini ]; then
cp /etc/php5/apache2/php.ini ~/zabbix-*/
grep -v "^#\|^$" /etc/php5/apache2/php.ini
echo
else
echo php.ini not found on standart location
return
fi


#backup front end configuration
if [ -f /var/www/html/zabbix/conf/zabbix.conf.php ]; then
cp /var/www/html/zabbix/conf/zabbix.conf.php ~/zabbix-*/
grep -v "^#\|^$" /var/www/html/zabbix/conf/zabbix.conf.php
echo
else
echo zabbix.conf.php not found on standart location
return
fi



if [ -f /etc/init.d/zabbix-agent ]; then
echo zabbix-agent service found
#stop zabbix agent
#service zabbix-agent stop
else
echo zabbix-agent not found on standart location
return
fi


if [ -f /etc/init.d/zabbix-server ]; then
echo zabbix-server service found stopping now
#stop zabbix server
#service zabbix-server stop
else
echo zabbix-server not found on standart location
return
fi




#check if all neccessary libs are installed before compiling server binaries
#./configure --enable-server --enable-agent --with-mysql --with-libcurl --with-libxml2 --with-ssh2 --with-net-snmp --with-openipmi --with-jabber

#install server
#make install

#remove previous service
#rm /etc/init.d/zabbix-agent
#rm /etc/init.d/zabbix-server 

#install content as service
#cp ~/zabbix-*/misc/init.d/debian/* /etc/init.d/
#update-rc.d zabbix-server defaults
#update-rc.d zabbix-agent defaults


#mkdir /var/www/html/zabbix
#cd ~/zabbix-*/frontends/php/
#cp -a . /var/www/html/zabbix/

#cat zabbix.conf.php > /var/www/html/zabbix/conf/zabbix.conf.php

#!/bin/bash
#this code is tested un fresh 2016-05-27-raspbian-jessie-lite.img Raspberry Pi image
#sudo raspi-config -> extend partition -> reboot
#sudo su
#apt-get update -y && apt-get install git -y
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

#set up zabbix user and group
groupadd zabbix
useradd -g zabbix zabbix

#extract zabbix source
tar -vzxf zabbix-*.tar.gz -C ~

#create basic database
mkdir -p /var/lib/sqlite
cd ~/zabbix-*/database/sqlite3
sqlite3 /var/lib/sqlite/zabbix.db <schema.sql

cd ~/zabbix-*/
./configure --enable-agent --enable-proxy --with-net-snmp --with-sqlite3 --with-ssh2
make install

echo
echo default zabbix_proxy.conf config file:
grep -v "^#\|^$" /usr/local/etc/zabbix_proxy.conf
echo

sed -i "s/^Server=.*$/Server=xxxxxxxxxxxx\.sn\.mynetname\.net/" /usr/local/etc/zabbix_proxy.conf #write ip address of real zabbix server
sed -i "s/^Hostname=.*$/Hostname=Broceni/" /usr/local/etc/zabbix_proxy.conf #write a name for this proxy server
sed -i "s/^DBName=.*$/DBName=\/var\/lib\/sqlite\/zabbix.db/" /usr/local/etc/zabbix_proxy.conf #set location to database
#set permissions to database
chown -R zabbix:zabbix /var/lib/sqlite/
chmod 774 -R /var/lib/sqlite
chmod 664 /var/lib/sqlite/zabbix.db
sed -i "s/^.*FpingLocation=.*$/FpingLocation=\/usr\/bin\/fping/" /usr/local/etc/zabbix_proxy.conf #/usr/sbin/fping: [2] No such file or directory

echo
echo zabbix_proxy.conf file now are:
grep -v "^#\|^$" /usr/local/etc/zabbix_proxy.conf
echo

#set up startup service
cat > /etc/init.d/zabbix_proxy << EOF
#!/bin/sh
case "\$1" in
start)
/usr/local/sbin/zabbix_proxy -c /usr/local/etc/zabbix_proxy.conf
echo "Zabbix proxy started"
;;
stop)
pkill zabbix_proxy
echo "Zabbix proxy stopped"
;;
restart)
pkill zabbix_proxy
sleep 5
/usr/local/sbin/zabbix_proxy -c /usr/local/etc/zabbix_proxy.conf
echo "Zabbix proxy restarted"
;;
*)
echo "Use start, stop, restart"
exit 1
;;
esac
EOF

#set startup service executable
chmod 755 /etc/init.d/zabbix_proxy

#re-read all startup applicaition
update-rc.d zabbix_proxy defaults

#install zabbix agent service
cp ~/zabbix-*/misc/init.d/debian/zabbix-agent /etc/init.d/

#let zabbix agent service to start up automatically at systems startup
update-rc.d zabbix-agent defaults

echo
echo default zabbix_agentd.conf config file:
grep -v "^#\|^$" /usr/local/etc/zabbix_agentd.conf
echo

#set zabbix agent configuration file
sed -i "s/^Server=.*$/Server=xxxxxxxxxxxx\.sn\.mynetname\.net/" /usr/local/etc/zabbix_agentd.conf #write ip address of real zabbix server
sed -i "s/^Hostname=.*$/Hostname=Broceni/" /usr/local/etc/zabbix_agentd.conf #write a name for this proxy server
sed -i "s/^LogFile=.*$/LogFile=\/tmp\/zabbix_agentd.log/" /usr/local/etc/zabbix_agentd.conf #destination for zabbix agent log file

echo
echo zabbix_agentd.conf file now are:
grep -v "^#\|^$" /usr/local/etc/zabbix_agentd.conf
echo

#set up reboot at midnight
echo "05 00 * * * root reboot">> /etc/crontab

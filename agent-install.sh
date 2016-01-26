#!/bin/sh

#this code is tested un fresh 2015-11-21-raspbian-jessie-lite Raspberry Pi image

#sudo apt-get update -y && sudo apt-get upgrade -y
#sudo apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x agent-install.sh server-install.sh

groupadd zabbix
useradd -g zabbix zabbix
mkdir -p /var/log/zabbix
chown -R zabbix:zabbix /var/log/zabbix/
tar -vzxf zabbix-*.tar.gz -C ~
cd ~/zabbix-*/
./configure --enable-agent
make install
cp ~/zabbix-*/misc/init.d/debian/zabbix-agent /etc/init.d/
update-rc.d zabbix-agent defaults
fourth=$(ifconfig | grep "inet.*addr.*Bcast.*Mask" | sed "s/  Bcast.*$//g" | sed "s/^.*\.//g")
cat > /usr/local/etc/zabbix_agentd.conf << EOF
LogFile=/var/log/zabbix/zabbix_agentd.log
Server=192.168.88.55
EnableRemoteCommands=1
Hostname=RPi$fourth
EOF
/etc/init.d/zabbix-agent restart

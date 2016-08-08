#!/bin/sh
#this code is tested un fresh 2015-11-21-raspbian-jessie-lite Raspberry Pi image
#sudo raspi-config -> extend partition -> reboot
#sudo su
#apt-get update -y && apt-get upgrade -y && apt-get install git -y
#git clone https://github.com/catonrug/raspberry-pi-zabbix.git && cd raspberry-pi-zabbix && chmod +x agent-install.sh server-install.sh
#./agent-install.sh
apt-get install nmap python-mechanize python-requests -y
apt-get install mtr dstat telnet -y
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
usermod -a -G video zabbix
/etc/init.d/zabbix-agent restart

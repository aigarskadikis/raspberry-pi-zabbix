#!/bin/bash
while [ "$(ifconfig -a eth0 | grep "addr.*\..*\..*\..*Bcast" | wc -l)" -ne 1 ]
do
sleep 1
done




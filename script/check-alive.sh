#!/bin/bash
# Script to check whether Calcentral is alive.

IP_ADDR=`/sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

cd /tmp
rm -rf $IP_ADDR\:3000
wget --recursive --quiet http://$IP_ADDR:3000/
wget --recursive --quiet http://$IP_ADDR:3000/api/ping
cd $IP_ADDR\:3000

grep "server_alive" api/ping > /dev/null || { echo "WARNING: Calcentral is dead or seriously malfunctioning!" ; exit 1 ; }

echo "Server is alive"

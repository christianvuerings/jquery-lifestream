#!/bin/bash
# Script to check whether Calcentral is alive.

IP_ADDR=`/sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

count=0
until grep "server_alive" api/ping >/dev/null 2>&1
do
  (( count++ ))
  if (( count <= 10 ))
  then
    sleep 30
    echo "Checking to see if server is alive, attempt #$count..."
    cd /tmp
    rm -rf $IP_ADDR\:3000
    wget --recursive --quiet http://$IP_ADDR:3000/
    wget --recursive --quiet http://$IP_ADDR:3000/api/ping
    cd $IP_ADDR\:3000
  else
    echo "Server did not respond to wget after 10 attempts"
    echo "WARNING: Calcentral is dead or seriously malfunctioning!"
    exit 1
  fi
done

echo "Server is alive"

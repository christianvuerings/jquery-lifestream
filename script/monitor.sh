#!/bin/bash

DELAY=$1
if [ -z "$1" ]; then
  DELAY=30
fi

while true; do
  STATS=`(sleep 1 ; echo "stats"; sleep 1; echo "quit") | telnet $HOSTNAME 11211`
  echo "==========================================="
  echo `date`
  jmap -heap `jps -mlv|grep 'torquebox-server'|head -1|awk '{print $1}'`
  echo $STATS | awk -F"STAT" '{for(i=2;i<NF;++i)print $i}'
  sleep $DELAY
done

#!/bin/bash

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=log/update-restart.log
LOGIT="tee -a $LOG"

JPS_RESULTS=`jps -mlv | grep bin/trinidad | cut -d ' ' -f 1`
for i in $JPS_RESULTS
do
  echo "------------------------------------------" | $LOGIT
  echo "`date`: Stopping CalCentral server $i..." | $LOGIT
  kill -s SIGTERM $i
done

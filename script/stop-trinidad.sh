#!/bin/bash

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=log/start-stop.log
LOGIT="tee -a $LOG"

echo "------------------------------------------" | $LOGIT
echo "`date`: Putting CalCentral server in offline mode" | $LOGIT
offline

JPS_RESULTS=`jps -mlv | grep bin/trinidad | cut -d ' ' -f 1`
for i in $JPS_RESULTS
do
  echo "------------------------------------------" | $LOGIT
  echo "`date`: Stopping CalCentral server $i..." | $LOGIT
  kill -s SIGTERM $i
done

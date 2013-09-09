#!/bin/bash

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo "------------------------------------------" | $LOGIT
echo "`date`: Putting CalCentral server in offline mode" | $LOGIT
./script/init.d/calcentral offline

JPS_RESULTS=`jps -mlv | grep torquebox | cut -d ' ' -f 1`
for TORQUEBOX_PID in $JPS_RESULTS
do
  echo "------------------------------------------" | $LOGIT
  echo "`date`: Stopping CalCentral server $TORQUEBOX_PID..." | $LOGIT
  count=0
  # first try to kill politely
  while kill -s SIGTERM $TORQUEBOX_PID 2>/dev/null
  do
      sleep 1;
      (( count++ ))
      if (( count > 9 ))
      then
          echo "`date`: CalCentral server $TORQUEBOX_PID did not respond to SIGTERM, sending kill -9..." | $LOGIT
          kill -9 $TORQUEBOX_PID 2>/dev/null
       fi
  done
done

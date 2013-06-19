#!/bin/bash

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo "------------------------------------------" | $LOGIT
echo "`date`: Putting CalCentral server in offline mode" | $LOGIT
./script/init.d/calcentral maint

JPS_RESULTS=`jps -mlv | grep torquebox | cut -d ' ' -f 1`
for i in $JPS_RESULTS
do
  echo "------------------------------------------" | $LOGIT
  echo "`date`: Stopping CalCentral server $i..." | $LOGIT
  kill -s SIGTERM $i
done

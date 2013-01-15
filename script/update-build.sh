#!/bin/bash
# Script to update and build a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo "=========================================" | $LOGIT
echo "`date`: Updating CalCentral source code" | $LOGIT
git fetch origin >> $LOG 2>&1
git checkout -qf #{branch} >> $LOG 2>&1
git reset --hard HEAD >>$LOG 2>&1
git pull >>$LOG 2>&1
echo "Last commit:" | $LOGIT
git log -1 | $LOGIT
echo | $LOGIT\

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping CalCentral..." | $LOGIT
./script/stop-trinidad.sh

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Building CalCentral..." | $LOGIT
./script/build-trinidad.sh

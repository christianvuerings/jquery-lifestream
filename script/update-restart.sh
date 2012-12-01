#!/bin/bash
# Script to update and restart a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=log/update-restart.log
LOGIT="tee -a $LOG"

echo "=========================================" | $LOGIT
echo "`date`: Updating CalCentral source code" | $LOGIT
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

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Starting CalCentral..." | $LOGIT
./script/start-trinidad.sh

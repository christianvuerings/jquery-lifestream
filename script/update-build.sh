#!/bin/bash
# Script to update and build a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..
TARGET_REMOTE=${REMOTE:-origin}
TARGET_BRANCH=${BRANCH:-master}
WAR_URL=${WAR_URL:"https://bamboo.media.berkeley.edu/bamboo/browse/MYB-MVPWAR/latest/artifact/JOB1/warfile/calcentral.knob"}

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo "=========================================" | $LOGIT
echo "`date`: Updating CalCentral source code from:" $TARGET_REMOTE ", branch:" $TARGET_BRANCH | $LOGIT
git fetch $TARGET_REMOTE 2>&1 | $LOGIT
git fetch -t $TARGET_REMOTE 2>&1 | $LOGIT
git reset --hard HEAD 2>&1 | $LOGIT
git checkout -qf $TARGET_BRANCH 2>&1 | $LOGIT
echo "Last commit:" | $LOGIT
git log -1 | $LOGIT
echo | $LOGIT

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping CalCentral..." | $LOGIT
./script/stop-torquebox.sh

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Fetching new CalCentral knob..." | $LOGIT
wget --no-check-certificate $WAR_URL

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Deploying new CalCentral knob..." | $LOGIT
bundle exec torquebox deploy calcentral.knob --env=production

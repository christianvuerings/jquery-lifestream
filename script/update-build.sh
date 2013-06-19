#!/bin/bash
# Script to update and build a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..
WAR_URL=${WAR_URL:="https://bamboo.media.berkeley.edu/bamboo/browse/MYB-MVPWAR/latest/artifact/JOB1/warfile/calcentral.knob"}

LOG=`date +"$PWD/log/update-build_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo "=========================================" | $LOGIT
echo "`date`: Stopping CalCentral..." | $LOGIT
./script/stop-torquebox.sh

rm -rf deploy
mkdir deploy
cd deploy

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Fetching new calcentral.knob..." | $LOGIT
curl -k $WAR_URL > calcentral.knob

echo "Unzipping knob..." | $LOGIT
jar xvf calcentral.knob
echo "Last commit in calcentral.knob:" | $LOGIT
cat versions/git.txt | $LOGIT

# fix permissions on files that need to be executable
chmod u+x ./script/*
chmod u+x ./vendor/bundle/jruby/1.9/bin/*

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Deploying new CalCentral knob..." | $LOGIT
bundle exec torquebox deploy calcentral.knob --env=production | $LOGIT


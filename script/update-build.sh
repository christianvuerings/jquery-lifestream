#!/bin/bash
# Script to update and build a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..
WAR_URL=${WAR_URL:="https://bamboo.media.berkeley.edu/bamboo/browse/MYB-MVPWAR/latest/artifact/JOB1/warfile/calcentral.knob"}
MAX_ASSET_AGE_IN_DAYS=${MAX_ASSET_AGE_IN_DAYS:="45"}

LOG=`date +"$PWD/log/update-build_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

# update source tree (from which these scripts run)
./script/update-source.sh

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping CalCentral..." | $LOGIT
./script/stop-torquebox.sh

rm -rf deploy
mkdir deploy
cd deploy

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Fetching new calcentral.knob from $WAR_URL..." | $LOGIT
curl -k -s $WAR_URL > calcentral.knob

echo "Unzipping knob..." | $LOGIT
jar xf calcentral.knob

if [ ! -d "versions" ]
then
  echo "`date`: ERROR: Missing or malformed calcentral.knob file!" | $LOGIT
  exit 1
fi
echo "Last commit in calcentral.knob:" | $LOGIT
cat versions/git.txt | $LOGIT

# fix permissions on files that need to be executable
chmod u+x ./script/*
chmod u+x ./vendor/bundle/jruby/1.9/bin/*
find ./vendor/bundle -name standalone.sh | xargs chmod u+x

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Deploying new CalCentral knob..." | $LOGIT
bundle exec torquebox deploy calcentral.knob --env=production | $LOGIT

echo "Copying assets into /var/www/html/calcentral" | $LOGIT
cp -Rvf public/assets /var/www/html/calcentral/ | $LOGIT

echo "Deleting old assets from /var/www/html/calcentral/assets" | $LOGIT
find /var/www/html/calcentral/assets -type f -mtime +$MAX_ASSET_AGE_IN_DAYS -delete | $LOGIT

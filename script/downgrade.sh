#!/bin/bash
# Script to downgrade the database to the last released version

# on each release, update last_version to the latest db migration in db/migrate
# Sprint 10 LAST_VERSION="2013012410480000"
# Sprint 11 LAST_VERSION="2013013014460000"
LAST_VERSION="2013013014460000"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Downgrading CalCentral to $LAST_VERSION on app node: `hostname -s`" | $LOGIT

cd script
./migrate.sh $LAST_VERSION

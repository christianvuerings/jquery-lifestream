#!/bin/bash
# Script to downgrade the database to the last released version

cd $( dirname "${BASH_SOURCE[0]}" )/..

LAST_VERSION=`cat deploy/versions/previous_release_db_schema.txt`

LOG=`date +"$PWD/log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Downgrading CalCentral to $LAST_VERSION on app node: `hostname -s`" | $LOGIT

./script/init.d/calcentral stop

./script/migrate.sh $LAST_VERSION

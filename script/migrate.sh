#!/bin/bash
# Script to migrate database schema and perform other cluster-wide updates

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"
VERSION=$1
if [ -z $1 ]; then
  # default db version is the latest one in our code tree
  if [ ! -d "deploy/db/migrate" ]
  then
    echo "`date`: ERROR: No database version specified!" | $LOGIT
    exit 1
  fi
  VERSION=`/bin/ls deploy/db/migrate/ | awk -F _ '{print $1}' | sort | tail -1`
fi

export RAILS_ENV=production
export LOGGER_STDOUT=only
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"
LOG_DIR=${CALCENTRAL_LOG_DIR:=`pwd`"/log"}
export CALCENTRAL_LOG_DIR=$LOG_DIR

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Database migration CalCentral on app node: `hostname -s`..." | $LOGIT

echo "`date`: rake db:migrate VERSION=$VERSION RAILS_ENV=$RAILS_ENV ..." | $LOGIT
cd deploy
bundle exec rake db:migrate VERSION=$VERSION RAILS_ENV=$RAILS_ENV | $LOGIT

#!/bin/bash
# Script to run student class calendar export. This is intended to be run from cron.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/calendar_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Calendar export started on app node: `hostname -s`..." | $LOGIT

cd deploy
export RAILS_ENV="production"
bundle exec rake calendar:preprocess calendar:export | $LOGIT

echo "`date`: Calendar export completed" | $LOGIT

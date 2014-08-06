#!/bin/bash
# Script to run student class calendar export. This is intended to be run from cron.

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/calendar_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Calendar export started on app node: `hostname -s`..." | $LOGIT

cd deploy
bundle exec rake calendar:preprocess calendar:export | $LOGIT

echo "`date`: Calendar export completed" | $LOGIT

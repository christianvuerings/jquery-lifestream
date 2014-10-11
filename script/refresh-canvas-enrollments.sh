#!/bin/bash
# Script to create user and enrollment CSV files in "tmp/canvas" and then
# upload them to Canvas.

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/canvas_refresh_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO
export JRUBY_OPTS="-Xcext.enabled=true -J-XX:+UseConcMarkSweepGC -J-XX:+CMSPermGenSweepingEnabled -J-XX:+CMSClassUnloadingEnabled -J-XX:MaxPermSize=512m"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to run the refresh script..." | $LOGIT

cd deploy

bundle exec rake canvas:incremental_refresh | $LOGIT

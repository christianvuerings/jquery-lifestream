#!/bin/bash
# Script to build and migrate a new version of a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=log/update-restart.log
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Updating and rebuilding CalCentral..." | $LOGIT

# Load all dependencies.
echo "`date`: bundle install..." | $LOGIT
bundle install

# Rebuild static assets (HTML, JS, etc.) after update.
echo "`date`: Rebuilding static assets..." | $LOGIT
bundle exec rake assets:clean
bundle exec rake assets:precompile

# Update database schema after update.
# TODO Will be "rake db:migrate" after we stabilize.
echo "`date`: Updating database..." | $LOGIT
bundle exec rake db:reset

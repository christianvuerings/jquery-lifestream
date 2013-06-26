#!/bin/bash
# Script to build and migrate a new version of a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
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

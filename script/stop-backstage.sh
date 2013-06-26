#!/bin/bash
# Script to stop CalCentral's background job processor.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

# Kill all instances of backstage if there are any running.
echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping running instances of backstage..." | $LOGIT
bundle exec rake backstage:stop | $LOGIT

#!/bin/bash
# Script to run capistrano

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$HOME/calcentral/log/migrate.log
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Database migration CalCentral on app node: `hostname -s`..." | $LOGIT

echo "`date`: rake db:migrate RAILS_ENV=$RAILS_ENV ..." | $LOGIT
rake db:migrate RAILS_ENV=$RAILS_ENV | $LOGIT
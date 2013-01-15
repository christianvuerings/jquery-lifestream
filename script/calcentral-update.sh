#!/bin/bash
# Script to run capistrano

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$HOME/calcentral/log/redeploy.log
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Redeploying CalCentral on app nodes..." | $LOGIT

echo "`date`: cap calcentral_dev:update..." | $LOGIT
cap calcentral_dev:update 2&>1 | $LOGIT

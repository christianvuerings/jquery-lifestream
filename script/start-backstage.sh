#!/bin/bash
# Script to start CalCentral's background job processor.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Kill all instances of backstage if there are any running.
echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping running instances of backstage..." | $LOGIT
./script/stop-backstage.sh

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Starting backstage..." | $LOGIT
export JRUBY_OPTS="-Xcext.enabled=true -J-server"
nohup bundle exec rake backstage:start  < /dev/null > /dev/null 2> $LOG  &

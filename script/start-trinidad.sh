#!/bin/bash
# Script to start a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Kill all instances of trinidad if there are any running.
echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping running instances of CalCentral..." | $LOGIT
./script/stop-trinidad.sh

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Starting CalCentral..." | $LOGIT
export JRUBY_OPTS="-Xcext.enabled=true -J-server"
nohup trinidad < /dev/null > /dev/null 2> $LOG  &

# wait a bit to let server start up
sleep 45

# now tickle the app to warm it up
curl -i -stderr /dev/null http://localhost:3000/ > /dev/null

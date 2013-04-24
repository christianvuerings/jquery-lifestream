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
OPTS=${CALCENTRAL_JRUBY_OPTS:="-Xcext.enabled=true -J-server -J-verbose:gc -J-XX:+PrintGCTimeStamps -J-XX:+PrintGCDetails -J-XX:+UseParallelOldGC -J-Xms1400m -J-Xmx1400m -J-Xmn500m -J-XX:PermSize=256m -J-XX:MaxPermSize=256m"}
export JRUBY_OPTS=$OPTS
nohup trinidad --config ./config/trinidad.yml < /dev/null > log/trinidad.log 2> $LOG  &

# wait a bit to let server start up
sleep 30

./script/init.d/calcentral online

# removing the maint page causes the Rails app to restart, for reasons unknown.
# So we'll wait a bit and then tickle the home page to warm up the app.
sleep 30

# now check if the app is alive (which will also warm up caches)
./script/check-alive.sh || exit 1

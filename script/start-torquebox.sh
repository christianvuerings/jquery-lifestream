#!/bin/bash
# Script to start a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/start-stop_%Y-%m-%d.log"`
TORQUEBOX_LOG="$PWD/log/torquebox.log"

LOGIT="tee -a $LOG"

# Kill all instances of torquebox if there are any running.
echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Stopping running instances of CalCentral..." | $LOGIT
./script/stop-torquebox.sh

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Starting CalCentral..." | $LOGIT
OPTS=${CALCENTRAL_JRUBY_OPTS:="-Xcext.enabled=true"}
export JRUBY_OPTS=$OPTS
JVM_OPTS=${CALCENTRAL_JVM_OPTS:="\-server \-verbose:gc \-XX:+PrintGCTimeStamps \-XX:+PrintGCDetails \-XX:+UseParallelOldGC \-Xms1200m \-Xmx1200m \-Xmn500m \-XX:PermSize=256m \-XX:MaxPermSize=256m"}
LOG_DIR=${CALCENTRAL_LOG_DIR:=`pwd`"/log"}
export CALCENTRAL_LOG_DIR=$LOG_DIR

cd deploy
nohup bundle exec torquebox run -p=3000 --jvm-options="$JVM_OPTS" --clustered < /dev/null > $TORQUEBOX_LOG 2>> $LOG  &
cd ..

# wait a bit to let server start up
sleep 30

./script/init.d/calcentral online

# removing the maint page causes the Rails app to restart, for reasons unknown.
# So we'll wait a bit and then tickle the home page to warm up the app.
sleep 45

# now check if the app is alive (which will also warm up caches)
./script/check-alive.sh || exit 1

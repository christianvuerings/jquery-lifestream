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
OPTS=${CALCENTRAL_JRUBY_OPTS:="-Xcext.enabled=true -J-Djruby.thread.pool.enabled=true"}
export JRUBY_OPTS=$OPTS
JVM_OPTS=${CALCENTRAL_JVM_OPTS:="\-server \-verbose:gc \-XX:+PrintGCTimeStamps \-XX:+PrintGCDetails \-XX:+UseConcMarkSweepGC \-Xms3000m \-Xmx3000m \-Xmn500m \-XX:PermSize=400m \-XX:MaxPermSize=400m \-XX:ReservedCodeCacheSize=128m \-XX:+UseCodeCacheFlushing"}
LOG_DIR=${CALCENTRAL_LOG_DIR:=`pwd`"/log"}
MAX_THREADS=${CALCENTRAL_MAX_THREADS:="90"}
export CALCENTRAL_LOG_DIR=$LOG_DIR
IP_ADDR=`/sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

cd deploy

JBOSS_HOME=`bundle exec torquebox env jboss_home`
cp ~/.calcentral_config/standalone-ha.xml $JBOSS_HOME/standalone/configuration/

nohup bundle exec torquebox run -b $IP_ADDR -p=3000 --jvm-options="$JVM_OPTS" --clustered --max-threads=$MAX_THREADS < /dev/null > $TORQUEBOX_LOG 2>> $LOG  &
cd ..

# now check if the app is alive (which will also warm up caches)
./script/check-alive.sh || exit 1

./script/init.d/calcentral online

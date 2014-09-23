#!/bin/bash
# Script to run load tests.

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/load_test_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to restart CalCentral..." | $LOGIT

~/init.d/calcentral restart | $LOGIT

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to clear cache and cache statisics..." | $LOGIT

cd ~/calcentral/deploy
bundle exec rake memcached:empty memcached:clear_stats | $LOGIT

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to start empty-cache load test on $LOAD_TEST_AGENT ..." | $LOGIT

ssh $LOAD_TEST_AGENT "cd tsung && ./automated_tsung.sh calcentral-dev" | $LOGIT

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to get cache statistics for empty-cache load test..." | $LOGIT

bundle exec rake memcached:get_stats | $LOGIT

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to start primed-cache load test on $LOAD_TEST_AGENT ..." | $LOGIT

ssh $LOAD_TEST_AGENT "cd tsung && ./automated_tsung.sh calcentral-dev" | $LOGIT

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to get cache statistics for primed-cache load test..." | $LOGIT

bundle exec rake memcached:get_stats | $LOGIT

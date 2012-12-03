#!/bin/bash
# Script to update and start a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=log/update-restart.log
LOGIT="tee -a $LOG"

# TODO Make sure memcached is running.
# /usr/local/bin/memcached -d

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Starting CalCentral..." | $LOGIT
export JRUBY_OPTS="-Xcext.enabled=true -J-server"
nohup trinidad < /dev/null >> log/production.log 2>&1 &

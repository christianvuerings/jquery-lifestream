#!/bin/bash
# Script to build and migrate a new version of a shared deployment of CalCentral.
# This is meant for running on Bamboo.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"log/start-stop_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export JRUBY_OPTS="-Xcext.enabled=true -J-Xmx900m"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Updating and rebuilding CalCentral..." | $LOGIT

# Load all dependencies.
echo "`date`: bundle install..." | $LOGIT
bundle install --deployment

# Rebuild static assets (HTML, JS, etc.) after update.
echo "`date`: Rebuilding static assets..." | $LOGIT
bundle exec rake assets:precompile

# Stamp version number
git log --pretty=format:'%H' -n 1 > versions/git.txt

# copy Oracle jar and tools.jar into ./lib
echo "`date`: Getting external driver files..." | $LOGIT
./script/install-jars.rb 2>&1 | $LOGIT

# build the knob
echo "`date`: Building calcentral.knob..." | $LOGIT
bundle exec rake torquebox:archive NAME=calcentral



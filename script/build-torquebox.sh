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
export LOGGER_STDOUT=only
# Temporary workaround for a JRuby 1.7.4 + Java 1.7 + JIT/invokedynamic bug : CLC-2732
export JRUBY_OPTS="-Xcext.enabled=true -J-Xmx900m -J-XX:MaxPermSize=500m -J-Djruby.compile.mode=OFF"
# export JRUBY_OPTS="-Xcext.enabled=true -J-Xmx900m"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: Updating and rebuilding CalCentral..." | $LOGIT

# Load all dependencies.
echo "`date`: bundle install..." | $LOGIT
bundle install --deployment || { echo "ERROR: bundle install failed" ; exit 1 ; }

# Rebuild static assets (HTML, JS, etc.) after update.
echo "`date`: Rebuilding static assets..." | $LOGIT
bundle exec rake assets:precompile || { echo "ERROR: asset compilation failed" ; exit 1 ; }

# Stamp version number
git log --pretty=format:'%H' -n 1 > versions/git.txt || { echo "ERROR: git log command failed" ; exit 1 ; }

# copy Oracle jar and tools.jar into ./lib
echo "`date`: Getting external driver files..." | $LOGIT
./script/install-jars.rb 2>&1 | $LOGIT

# build the knob
echo "`date`: Building calcentral.knob..." | $LOGIT
bundle exec rake torquebox:archive NAME=calcentral || { echo "ERROR: torquebox archive failed" ; exit 1 ; }



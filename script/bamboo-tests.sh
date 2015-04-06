#!/bin/bash
# Script to install necessary dependencies and then run testext tests, for use on Bamboo CI

cd $( dirname "${BASH_SOURCE[0]}" )/..

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc
GEMSET="$1"
if [ -z "$1" ]; then
  GEMSET="calcentral"
fi
rvm gemset use $GEMSET

# get Ruby deps
bundle install --local --retry 3 || { echo "WARNING: bundle install --local failed, running bundle install"; bundle install --retry 3 || { echo "ERROR: bundle install failed"; exit 1; } }
bundle package --all || { echo "WARNING: bundle package failed"; exit 1; }

# set up environment
export RAILS_ENV=testext
export DISPLAY=":99"
export JRUBY_OPTS="-Xcext.enabled=true -J-Xmx900m -J-XX:MaxPermSize=500m -J-Djruby.compile.mode=OFF"

# run the tests
if [ "$2" == "uitest" ]; then
  # run UI tests if we've been given a second arg
  echo "Running UI tests"
  export UI_TEST=true
  bundle exec rake spec:xml
else
  # run regular testext tests
  echo "Running testext tests"

  # set up Xvfb for headless browser testing
  if [ ! -f /tmp/.X99-lock ];
  then
      Xvfb :99 -screen 0 1440x900x16 &
  fi

  bundle exec rake assets:clean db:reset spec:xml
fi

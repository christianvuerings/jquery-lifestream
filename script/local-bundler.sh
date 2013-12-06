#!/bin/bash
# Script to do a bundle install from local directory, or create/update the local directory if it's not existent or updated.
# This is meant for running on Bamboo.

cd $( dirname "${BASH_SOURCE[0]}" )/..

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

GEMSET="$1"
if [ -z "$1" ]; then
  GEMSET="calcentral"
fi

rvm gemset use $GEMSET

bundle install --local || { echo "WARNING: bundle install --local failed, running bundle install"; bundle install || { echo "ERROR: bundle install failed"; exit 1; } }

bundle package --all || { echo "WARNING: bundle package failed"; exit 1; }

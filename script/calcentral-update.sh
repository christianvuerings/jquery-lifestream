#!/bin/bash
# Script to run capistrano

cd $( dirname "${BASH_SOURCE[0]}" )/..

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo "------------------------------------------"
echo "`date`: Redeploying CalCentral on app nodes..."

echo "`date`: cap calcentral_dev:update..."
cap -l STDOUT calcentral_dev:update || { echo "ERROR: capistrano deploy failed" ; exit 1 ; }

#!/bin/bash
# Script to configure (or reconfigure) all LTI apps on the linked bCourses server and provided
# by the current CalCentral server. This will add any new apps and overwrite current LTI
# keys and secrets.

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/canvas_configure_all_apps_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to run the LTI application configuration script..." | $LOGIT

cd deploy

bundle exec rake canvas:configure_all_apps_from_current_host | $LOGIT

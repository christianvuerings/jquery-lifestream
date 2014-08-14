#!/bin/bash
# Script to update all users within Canvas from People/Guest Oracle view

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/canvas_active_user_sync_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"
OPT=$1

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
source .rvmrc

export RAILS_ENV=production
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO
export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

echo | $LOGIT
echo "------------------------------------------" | $LOGIT
echo "`date`: About to run the active campus user sync script..." | $LOGIT

cd deploy

case $OPT in
  -c|-C)
    echo "Running with 'clear_sis_stickiness' flag during SIS Import"
    bundle exec rake canvas:all_user_sync[true] | $LOGIT
    ;;
   *)
    bundle exec rake canvas:all_user_sync | $LOGIT
    ;;
esac

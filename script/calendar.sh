#!/bin/bash
# Script to run student class calendar export. This is intended to be run from cron.

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/calendar_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

cd deploy
export RAILS_ENV="production"
bundle exec rake calendar:preprocess calendar:export | $LOGIT

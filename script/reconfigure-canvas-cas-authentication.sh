#!/bin/bash
# Script to check for overwritten CAS authentication configurations on bCourses test/beta,
# and to reset their base URLs if needed. See CLC-3917 for details.
#
# Two environment variables must be set before the script is called:
#
#  * TEST_CAS_URL : URL root of the development/testing CAS Authentication server
#     Example: TEST_CAS_URL='https://auth-test.example.com/cas'
#  * DEV_TEST_CANVASES : URL roots for the development and test cloud hosted Canvas applications
#     Example: DEV_TEST_CANVASES='https://ucb.beta.example.com,https://ucb.test.example.com'

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/canvas_reconfigure_cas_authorization_%Y-%m-%d.log"`
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
echo "`date`: About to run the CAS Authentication reconfiguration script..." | $LOGIT

cd deploy

bundle exec rake canvas:reconfigure_auth_url | $LOGIT

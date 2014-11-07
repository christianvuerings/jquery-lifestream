#!/bin/bash
# Script to check for overwritten external app configurations on bCourses test/beta,
# and to reset their app hosts if needed. See CLC-2889 for details.
#
# Two environment variables must be set before the script is called:
#
#  * CALCENTRAL_XML_HOST : URL root of a CalCentral server which is accessible from the bCourses
#     machines. Example: CALCENTRAL_XML_HOST='https://calcentral.example.com'
#  * CANVAS_HOSTS_TO_CALCENTRALS : Mapping from the bCourses test/beta servers to their assigned
#    CalCentral app hosts. Example:
#      CANVAS_HOSTS_TO_CALCENTRALS='https://ucb.beta.example.com=cc-dev.example.com,https://ucb.test.example.com=cc-qa.example.com'

# Make sure the normal shell environment is in place, since it may not be
# when running as a cron job.
source "$HOME/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"$PWD/log/canvas_reconfigure_external_apps_%Y-%m-%d.log"`
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
echo "`date`: About to run the external LTI application reconfiguration script..." | $LOGIT

cd deploy

bundle exec rake canvas:reconfigure_external_apps | $LOGIT

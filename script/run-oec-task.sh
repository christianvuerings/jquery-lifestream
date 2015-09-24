#!/bin/bash
# Script delegates to oec.rake tasks.

# Make sure the normal shell environment is in place, since it may not be when running as a cron job.
PROFILE="${HOME}/.bash_profile"
test -f "${PROFILE}" && source "${PROFILE}"

cd $( dirname "${BASH_SOURCE[0]}" )/..

TASK_OPTIONS=(create_confirmation_sheets export merge_confirmation_sheets publish_to_explorance sis_import term_setup)
REQUESTED_TASK="$1"

WORKING_DIR="${PWD}"
THIS_SCRIPT=$(basename '$0')
LOG=$(date +"${WORKING_DIR}/log/${THIS_SCRIPT}_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

if [[ " ${TASK_OPTIONS[*]} " == *" ${REQUESTED_TASK} "* ]]
then
  # Enable rvm and use the correct Ruby version and gem set.
  [[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
  source .rvmrc

  export RAILS_ENV=production
  export LOGGER_STDOUT=only
  export LOGGER_LEVEL=INFO
  export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"
  echo "$(date): Run oec:${REQUESTED_TASK} task on $(hostname -s)" | ${LOGIT}

  cd deploy
  bundle exec rake oec:${REQUESTED_TASK} "${2}" | ${LOGIT}

  echo "$(date): The oec:${REQUESTED_TASK} task is done" | ${LOGIT}

else
  echo | ${LOGIT}
  echo "Usage:" | ${LOGIT}
  PSV=`( IFS=$'|'; echo "${TASK_OPTIONS[*]}" )`
  echo "  $0 [${PSV}] [term_code='2015-D' ...]" | ${LOGIT}
  echo | ${LOGIT}
fi

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

cd "${WORKING_DIR}"
exit 0

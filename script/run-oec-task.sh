#!/bin/bash
# Script delegates to oec.rake tasks.

# Make sure the normal shell environment is in place, since it may not be when running as a cron job.
PROFILE="${HOME}/.bash_profile"
test -f "${PROFILE}" && source "${PROFILE}"

cd $( dirname "${BASH_SOURCE[0]}" )/..

TASK_OPTIONS=(term_setup sis_import create_confirmation_sheets report_diff merge_confirmation_sheets validate_confirmation_sheets publish_to_explorance)
TASK="$1"

WORKING_DIR="${PWD}"
THIS_SCRIPT=$(basename $0)
LOG=$(date +"${WORKING_DIR}/log/${THIS_SCRIPT}_%F_%H:%M:%S.log")
LOGIT="tee -a ${LOG}"

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

if [[ " ${TASK_OPTIONS[*]} " == *" ${TASK} "* ]]
then
  echo | ${LOGIT}
  # Enable rvm and use the correct Ruby version and gem set.
  [[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
  source .rvmrc

  export RAILS_ENV=${RAILS_ENV:-production}
  export LOGGER_STDOUT=only
  export LOGGER_LEVEL=INFO
  export JRUBY_OPTS="-Xcext.enabled=true -J-client -X-C"

  echo "[$(date +"%F %H:%M:%S")] [INFO] Begin oec:${TASK} on $(hostname -s)" | ${LOGIT}

  cd deploy
  bundle exec rake oec:${TASK} | ${LOGIT}

  echo "[$(date +"%F %H:%M:%S")] [INFO] Finished oec:${TASK} on $(hostname -s)" | ${LOGIT}

else
  PSV=`( IFS=$'|'; echo "${TASK_OPTIONS[*]}" )`
  read -d '' usage << EOF
Usage:

[term_code='2015-D'] [local_write='Y'] [dept_codes='IMMCB PMATH ...'] ...  ${0} [${PSV}]
EOF
  echo "${usage}" | ${LOGIT}
fi

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

cd "${WORKING_DIR}"
exit 0

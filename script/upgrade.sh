#!/bin/bash
# Script to upgrade a shared deployment of CalCentral, include code update, build, db migration, and restart.

cd $( dirname "${BASH_SOURCE[0]}" )/..

HOSTNAME=`uname -n`
if [[ "${HOSTNAME}" = ets-calcentral-*-01\.ist.berkeley.edu ]]; then
  NODEONE="yes"
fi

./script/init.d/calcentral maint

./script/update-build.sh || { echo "ERROR: update-build failed" ; exit 1 ; }

# run migrate.sh only if we are on node 1
if [ "X$NODEONE" != "X" ]; then
  ./script/migrate.sh
fi

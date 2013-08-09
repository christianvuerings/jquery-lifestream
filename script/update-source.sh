#!/bin/bash
# Script to update and build a shared deployment of CalCentral.

cd $( dirname "${BASH_SOURCE[0]}" )/..
TARGET_REMOTE=${REMOTE:-origin}
TARGET_BRANCH=${BRANCH:-master}

LOG=`date +"$PWD/log/update-build_%Y-%m-%d.log"`
LOGIT="tee -a $LOG"

echo "=========================================" | $LOGIT
echo "`date`: Updating CalCentral source code from:" $TARGET_REMOTE ", branch:" $TARGET_BRANCH | $LOGIT
git fetch $TARGET_REMOTE 2>&1 | $LOGIT
git fetch -t $TARGET_REMOTE 2>&1 | $LOGIT
git reset --hard HEAD 2>&1 | $LOGIT
git checkout -qf $TARGET_BRANCH 2>&1 | $LOGIT
echo "Last commit in source tree:" | $LOGIT
git log -1 | $LOGIT
echo | $LOGIT

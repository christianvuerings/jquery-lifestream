#!/bin/bash

RECIPIENT=$1
YESTERDAY=`date -v -1d "+%Y-%m-%d"`

if [ -z "$1" ]; then
	echo "Usage: $0 recipient_email" && exit 0
fi

cd $( dirname "${BASH_SOURCE[0]}" )/..

egrep -h "ACT-AS|acting_as" log/calcentral*WARN_$YESTERDAY.log | mail -s "CalCentral act-as audit for $YESTERDAY" $RECIPIENT


#!/bin/bash

RECIPIENT=$1
YESTERDAY=$(date --date="yesterday" +"%Y-%m-%d")
CC_LOGFILE=$HOME/calcentral/log/calcentral*${YESTERDAY}.log
EGREP_FILE=/calcentral-prod/scripts/egrep_file

if [ -z "$1" ]; then
        echo "Usage: $0 recipient_email" && exit 0
fi

cd $( dirname "${BASH_SOURCE[0]}" )/..

# http://stackoverflow.com/questions/11176061/how-do-i-prevent-long-emails-from-becoming-attachments
/bin/egrep "FATAL|ERROR" $CC_LOGFILE | egrep -vf $EGREP_FILE | cut -d" " -f5-30 | sort | uniq -c | /usr/bin/tr -d '\11\15\176' | /bin/mail -E -s "`hostname -s` CalCentral error/fatal audit" $RECIPIENT

exit

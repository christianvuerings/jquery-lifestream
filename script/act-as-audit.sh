#!/bin/bash

RECIPIENT=$1
YESTERDAY=$(date --date="yesterday" +"%Y-%m-%d")
LOGFILEDIR=$HOME/act_as_logs
LOGFILE=$LOGFILEDIR/act_as_${YESTERDAY}.log

if [ -z "$1" ]; then
        echo "Usage: $0 recipient_email" && exit 0
fi

if [ ! -d $LOGFILEDIR ]; then
  /bin/mkdir $LOGFILEDIR
fi

cd $( dirname "${BASH_SOURCE[0]}" )/..

/bin/egrep -h "ACT-AS|acting_as" log/calcentral*WARN_${YESTERDAY}.log > $LOGFILE

if [ -s $LOGFILE ]; then
  /bin/mail -s "CalCentral act-as audit for $YESTERDAY" $RECIPIENT < $LOGFILE
  /bin/gzip $LOGFILE
fi

# Delete old empty log files after 90 days
/bin/find $LOGFILEDIR/ -name "act_as_*" -type f -mtime +90 -exec /bin/rm '{}' \;

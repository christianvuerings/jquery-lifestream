#!/bin/bash

if [ $# -lt 1 ]
then
        echo "Usage : $0 command"
        echo "Commands:"
        echo "rc - Rails Console"
        echo "rdbm - Migrate Database"
        echo "restore-db - Restore db from db/current.sql.zip"
        echo "restart - Restart rails app after bundling gems"
        echo "rebuild - Rebuild the docker container with latest Gemfile and restart"
        echo 'cmd "bundle exec something" - Run the command in quotes in /app'
        exit
fi

if [ -z $RAILS_ENV ]
then
  echo "Using default RAILS_ENV value of 'development'"
  RAILS_ENV="development"
fi

case "$1" in

rc)  echo "Starting Console in Docker Container, RAILS_ENV = $RAILS_ENV"
    vagrant ssh -c "sh /app/docker/scripts/rc.sh $RAILS_ENV"
    ;;
rdbm)  echo  "Running rake db:migrate in Docker container, RAILS_ENV = $RAILS_ENV"
    vagrant ssh -c "sh /app/docker/scripts/rdbm.sh $RAILS_ENV"
    ;;
restart) echo  "Restarting Docker Rails Container, RAILS_ENV = $RAILS_ENV"
    vagrant ssh -c "sh /app/docker/scripts/restart.sh $RAILS_ENV"
   ;;
rebuild) echo  "Rebuilding Docker Rails Container, RAILS_ENV = $RAILS_ENV"
    vagrant ssh -c "sh /app/docker/scripts/rebuild.sh $RAILS_ENV"
   ;;
logs) echo "Tailing logs, RAILS_ENV = $RAILS_ENV"
    vagrant ssh -c "sh /app/docker/scripts/logs.sh $RAILS_ENV"
   ;;
cmd) echo "running '$2' in docker container in /app, RAILS_ENV = $RAILS_ENV"
  vagrant ssh -c "/app/docker/scripts/cmd.sh $RAILS_ENV '$2'"
    ;;
*) echo "Command not known"
   ;;
esac

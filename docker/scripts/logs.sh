#!/bin/bash

RAILS_ENV=$1
if [ -z $RAILS_ENV ]; then
  RAILS_ENV="production"
fi

echo "Tailing rails logs with RAILS_ENV=$RAILS_ENV"

docker logs -f rails

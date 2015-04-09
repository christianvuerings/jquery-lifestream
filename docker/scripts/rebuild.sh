#!/bin/bash

RAILS_ENV=$1
if [ -z $RAILS_ENV ]; then
  RAILS_ENV="production"
fi

echo "Rebuilding rails container with RAILS_ENV=$RAILS_ENV"

docker stop rails
docker rm rails
docker build -t rails /app
docker run -e "RAILS_ENV=$RAILS_ENV" -d -p 3000:3000 -v /app:/app --volumes-from gulp --volumes-from config --link postgres:db --name rails rails:latest

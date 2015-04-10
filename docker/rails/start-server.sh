#!/bin/bash

cd /app

# init the db only if needed
echo "Checking to see if database needs to be created..."
bundle exec rake database:create_if_necessary

echo "Migrating database..."
bundle exec rake db:migrate

echo "Starting rails s with RAILS_ENV=$RAILS_ENV..."
bundle exec rails s

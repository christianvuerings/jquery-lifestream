#!/bin/bash

cd /app

# blow away your node_modules directory to get a fresh installation of npm
if [ ! -d /app/node_modules/gulp ]; then
  echo "Installing npm..."
  npm install
  npm install -g gulp
fi

echo "Starting gulp..."
gulp build

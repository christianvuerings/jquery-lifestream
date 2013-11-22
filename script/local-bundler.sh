#!/bin/bash
# Script to do a bundle install from local directory, or create/update the local directory if it's not existent or updated.
# This is meant for running on Bamboo.

cd $( dirname "${BASH_SOURCE[0]}" )/..

bundle install --local || { echo "WARNING: bundle install --local failed, running bundle package"; bundle package || { echo "ERROR: bundle package failed"; exit 1; } }


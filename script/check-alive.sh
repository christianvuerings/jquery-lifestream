#!/bin/bash
# Script to check whether Calcentral is alive.

cd /tmp
rm -rf localhost\:3000
wget --recursive --quiet http://localhost:3000/
cd localhost\:3000

grep "Git commit\:" index.html > /dev/null || { echo "WARNING: Calcentral is dead or seriously malfunctioning!" ; exit 1 ; }

echo "Server is alive"


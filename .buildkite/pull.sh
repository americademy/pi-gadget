#!/bin/bash

set -eu

echo "Pulling latest master"
git reset --hard origin/master
git checkout master
git pull origin master


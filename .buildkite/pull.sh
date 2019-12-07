#!/bin/bash

set -eu

echo "Pulling latest master"
git reset --hard origin/18-armhf
git checkout 18-armhf
git pull origin 18-armhf


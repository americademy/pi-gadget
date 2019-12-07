#!/bin/bash

set -eu

echo "Installing dependencies"
apt-get -qq update
apt-get -qq install git ubuntu-image snapcraft -y

echo "Configure git for Buildkite"
git config --global user.name machine-americademy
git config --global user.email engineering@americademy.com

echo "Pulling latest from 18-armhf branch"
git reset --hard origin/18-armhf
git checkout 18-armhf
git pull origin 18-armhf

echo "Grabbing release info"
RELEASE_NOTES=$(buildkite-agent meta-data get "release-notes")
RELEASE_TYPE=$(buildkite-agent meta-data get "release-type")
echo "Release notes: $RELEASE_NOTES"
echo "Release type: $RELEASE_TYPE"

echo "Updating package version"
CURRENT_VERSION=`cat .version`
echo "Current version: $CURRENT_VERSION"
VERSION=`.buildkite/semver.sh bump $RELEASE_TYPE $CURRENT_VERSION`
echo "New version: $VERSION"
echo $VERSION > .version

# prepend release notes to CHANGELOG.md w/ new version number
echo "Building new CHANGELOG"
TMP_FILE=CHANGELOG-tmp.md
echo "# v$VERSION" > $TMP_FILE
echo "$RELEASE_NOTES" >> $TMP_FILE
echo "" >> $TMP_FILE
cat CHANGELOG.md >> $TMP_FILE
mv $TMP_FILE CHANGELOG.md

# building image
snapcraft
mv codeverse-pi_18-1_armhf.snap build/codeverse-pi_18-1_armhf.snap

# commit + tag + push
git status
git diff

echo "Tagging and commiting v$VERSION"
git add build/codeverse-pi_18-1_armhf.snap
git add .version
git add CHANGELOG.md
git commit -m "Updated build v$VERSION" -m "Release v$VERSION" -m "$RELEASE_NOTES" -m "[skip ci]"
# the [skip ci] will prevent another master build based on this commit
git tag -a $VERSION -m "Release v$VERSION"

echo "Pushing new version to 18-armhf"
git push origin 18-armhf && git push --tags

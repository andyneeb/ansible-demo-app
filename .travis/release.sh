#!/usr/bin/env bash

set -e

echo "Ensuring that pom  matches $TRAVIS_BUILD_NUMBER"
mvn org.codehaus.mojo:versions-maven-plugin:2.5:set -DnewVersion=$TRAVIS_BUILD_NUMBER

echo "Uploading to Artifactory"
mvn deploy -DskipTests=true --batch-mode --update-snapshots

echo "Deploying to Stage"
tower-cli config host $TOWER_URL
tower-cli config verify_ssl false
tower-cli config username $TOWER_USER
tower-cli config password $TOWER_PASSWORD

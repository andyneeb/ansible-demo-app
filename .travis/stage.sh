#!/usr/bin/env bash

set -e

echo "Ensuring that pom matches $TRAVIS_BRANCH"
mvn org.codehaus.mojo:versions-maven-plugin:2.5:set -DnewVersion=$TRAVIS_BRANCH

echo "Uploading to Artifactory"
mvn deploy -DskipTests=true --batch-mode --update-snapshots

echo "Deploying to Stage"
tower-cli config host $TOWER_URL
tower-cli config verify_ssl false
tower-cli config username $TOWER_USER
tower-cli config password $TOWER_PASSWORD
tower-cli workflow_job launch -W 'CI / CD - Deploy App To Stage' --extra-vars=instance_image=rhel76openjdk18 --extra-vars=instance_name=stage --extra-vars=app_release=$TRAVIS_BRANCH --monitor

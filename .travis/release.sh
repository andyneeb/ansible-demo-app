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
tower-cli job_template create --name "Release Demo App v$TRAVIS_BUILD_NUMBER" --project "Demo App Repo" --playbook "plays/simple.yml" --inventory "OpenStack Prod" --extra-vars=app_release=$TRAVIS_BUILD_NUMBER --extra-vars=app_stage=release --ask-limit-on-launch TRUE --credential "RHEL Cloud User Secure"
tower-cli role grant --type "execute" --user "release_manager" --job-template "Release Demo App v$(lastversion andyneeb/ansible-demo-app)"
tower-cli job_template delete --name "Release Demo App v$(bc <<< $TRAVIS_BUILD_NUMBER-2)"

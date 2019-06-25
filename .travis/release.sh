#!/usr/bin/env bash

set -e
export COMMIT=${TRAVIS_COMMIT::7}

echo "Ensuring that pom matches $COMMIT"
mvn org.codehaus.mojo:versions-maven-plugin:2.5:set -DnewVersion=$COMMIT

echo "Uploading to Artifactory"
mvn deploy -DskipTests=true --batch-mode --update-snapshots

echo "Deploying v$COMMIT to Production"
tower-cli config host $TOWER_URL
tower-cli config verify_ssl false
tower-cli config username $TOWER_USER
tower-cli config password $TOWER_PASSWORD

echo "Delete old latest-1"
tower-cli job_template delete --name "Release Demo App (latest-1)"

echo "Move Current to N-1"
tower-cli job_template copy $(tower-cli job_template get --name "Release Demo App (latest)" -f id) --new-name "Release Demo App (latest-1)"
tower-cli role grant --type "execute" --user "release_manager" --job-template "Release Demo App (latest-1)"

echo "Delete old latest"
tower-cli job_template delete --name "Release Demo App (latest)"

echo "Create new job for latest"
tower-cli job_template create --name "Release Demo App (latest)" --project "Demo App Repo" --playbook "plays/simple.yml" --inventory "OpenStack Prod" --extra-vars=app_release="$COMMIT" --extra-vars=instance_name=all --ask-limit-on-launch TRUE --credential "RHEL Cloud User Secure"
tower-cli job_template associate_notification_template --job-template "Release Demo App (latest)" --notification-template 1 --status=error
tower-cli job_template associate_notification_template --job-template "Release Demo App (latest)" --notification-template 1 --status=success
tower-cli role grant --type "execute" --user "release_manager" --job-template "Release Demo App (latest)"

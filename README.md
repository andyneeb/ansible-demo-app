# ansible-demo-app

[![Build Status](https://travis-ci.org/andyneeb/ansible-demo-app.svg?branch=master)](https://travis-ci.org/andyneeb/ansible-demo-app)

A simple Java Hello World written primarily to showcase Red Hat Ansible Tower.

#Overview

Ansible Tower is - among other things - an API to make Ansible playbooks easily consumable and therefore foster collaboration and reuse of playbooks / roles / modules.

This demo has been created to demonstrate how Ansible Tower can easily be integrated into a typical enterprise toolchain. My environment currently uses the following building blocks. Those are mere examples and should easily be replaceable by the usual suspects (ie. Github -> Gitlab, Travis -> Jenkins, Artifactory -> Nexus, Slack -> Mattermost ...)

- Red Hat OpenStack 13 (Queens): IaaS layer providing compute, network, storage and loadbalancing
- Github (this repo): SCM for code, playbooks, config, pipeline definiton
- Artifactory: Repository for packaged binaries (single war in this case)
- Travis CI: Continous Integration / Build system
- Red hat Ansible Tower: Automated provisioning & teardown of test env, deployment, release management, security, role based access

# High Level Demo Flow

- Checkout branch
- Make modifications
- Push branch to origin
- Create PR (your branch -> master)
- Push on branch (!= master) will trigger test pipeline
- CI server runs Compile, unit test, code coverage, pushes artifacts (tagged with current dev branch) to repo
- On success CI server triggers Ansible Tower
- Tower will create test environment (rhel7 system, add to loadbalancer, subscribe)
- Tower will install java8, tomcat8 on test env
- Tower will deploy artefact (war) to test and do smoke test
- On success PR can be merged
- Merge to master will trigger prod pipeline
- CI server again runs all test, pushes artifacts (now tagged with current commit id) to repo
- On success CI server triggers Ansible Tower
- Tower will create new release job pointing to current artifacts and rotate previous release to N-1 for possible rollback
- Release manager will eventually log into Tower and push current to production using encrypted SSH keys and password




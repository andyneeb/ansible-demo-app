# ansible-demo-app

[![Build Status](https://travis-ci.org/andyneeb/ansible-demo-app.svg?branch=master)](https://travis-ci.org/andyneeb/ansible-demo-app)

A simple Java Hello World written primarily to showcase Red Hat Ansible Tower.

# Overview

Ansible Tower is - among other things - an API to make Ansible playbooks easily consumable and therefore foster collaboration and reuse of playbooks / roles / modules.

This demo has been created to demonstrate how Ansible Tower can easily be integrated into a typical enterprise toolchain. My environment currently uses the following building blocks. Those are mere examples and should easily be replaceable by the usual suspects (ie. Github -> Gitlab, Travis -> Jenkins, Artifactory -> Nexus, Slack -> Mattermost ...)

- Red Hat OpenStack 13 (Queens): IaaS layer providing compute, network, storage and loadbalancer
- Github (this repo): SCM for code, playbooks, config, pipeline definition
- Artifactory: Repository for packaged binaries (single war in this case)
- Travis CI: Continuous Integration / Build system
- Slack: Notifaction on build & deployment status
- Red hat Ansible Tower: Automated provisioning & teardown of test env, deployment, release management, security, role based access

Below is a high-level diagram of the main components.

![](../images/overview.png)

# High Level Demo Flow

- Checkout branch / make modifications / push branch to origin
- Create PR (your branch -> master)
- Push on any branch !=master will trigger test pipeline
- CI server runs build, unit test, code coverage, package, pushes artifacts (tagged with current dev branch) to repo
- On success CI server triggers workflow in Ansible Tower
- Tower creates test environment: single rhel7 system, add to loadbalancer, subscribe, install java & tomcat
- Tower will then deploy artefact (war) to test env and do smoke test
- On success PR can be merged
- Merge to master will trigger prod pipeline
- CI server again runs build, all test, pushes artifacts (now tagged with current commit id) to repo
- On success CI server triggers Ansible Tower
- Tower will create new release job pointing to current artifacts and rotate previous release to N-1 for possible rollback
- Tower will setup role based access to release job
- Tower will configure slack notifications
- Release manager will eventually log into Tower and push current to production using encrypted SSH keys and password

# Repo structure / available assets

### Directory layout

    .
    ├── .travis                   
    │   ├── release.sh              # Release script
    │   ├── settings.xml            # Maven settings
    │   └── stage.sh                # Staging script
    ├── images                    # Embedded images for readme / docs
    ├── plays                     
    │   ├── roles                   # Ansible roles
    │   │   └── requirements.yml      # Requirements definition (tomcat)
    │   └── simple.yml              # Playbook (app + tomcat)
    ├── src/main/webapp           # Source files
    ├── tower                     # Tower objects (jobs, workflows, etc.)
    ├── .travis.yml               # Travis-CI pipeline definition
    ├── README.md                 # This file
    └── pom.xml                   # Maven project definition

### Instructions / Customizations

1.) Set the following variables on your travis build (in web ui)
- ARTY_PASSWORD=<PASSWORD>: Password for your repository (Artifactory / Nexus / ...)
- ARTY_USERNAME=<USER>: User for your repository (Artifactory / Nexus / ...)
- PYTHONWARNINGS=IGNORE: To prevent python deprecation warnings clutter build logs
- TOWER_PASSWORD=<PASSWORD>: Ansible Tower password
- TOWER_URL=URL: URL of your Tower instance 
- TOWER_USER=<USER>: Ansible Tower user

2.) Also in build setting in Travis Web UI disable 'Build pushed pull requests'. No need to start build on PR for demo.

3.) Configure your repository URL in .travis/settings.xml. (Will make this a var in a future version)

4.) Setup project for required playbooks in Tower. Everything is available at https://github.com/andyneeb/ansible-demo-infra but will need customization if you are not running on OpenStack. If you do, you still need to set propper vars for your OpenStack environment. Your mileage might vary. If you run on OpenStack I trust you know what to do.

5.) Import all tower objects from ./tower. Easiest way is to use tower-cli like this:

```
tower-cli send ./tower


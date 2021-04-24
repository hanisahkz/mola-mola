<p align="left">
    <img src="https://forthebadge.com/images/badges/made-with-ruby.svg">
</p>

# About

This is a monorepo containing scripts to generate data specifically for Atlassian server and cloud platforms.

Ideally, these scripts can be used in development for load testing purposes. References for load profiles:
* [Jira server](https://confluence.atlassian.com/enterprise/jira-sizing-guide-461504623.html)
* [Confluence server](https://confluence.atlassian.com/enterprise/confluence-data-center-load-profiles-946603546.html)

To begin using this repo, head straight to **Section: Get started**.

# Visions

* 💪 To increase productivity by having scripts that can run everywhere with minimal setup
* 🙌 To encourage collaboration by centralizing scripts related to seeding Atlassian data written in 
  various programming languages

# Folder structure
The initial idea is to organize the scripts by language. 

Generally, the folder can be structured as follows: 

```bash
.
└── ruby
    ├── Gemfile
    ├── Gemfile.lock
    ├── README.md
    └── scripts
        └── jira-server
            ├── script1.rb
            ├── script2.rb
            ├── ...
        └── jira-cloud
            ├── script1.rb
            ├── script2.rb
            └── ...
```

# Get started

The steps here assume `ruby` as the language chosen for running scripts.

However, the steps are the same when using other language.

## Pre-requisites

* [Docker](https://docs.docker.com/get-docker/)
* Running instance(s)
* Credentials for Atlassian API
  * For server, typically this is default to `admin` for username and password
  * For cloud, refer [here](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/) on how to generate API token.
* (For server) A tool for exposing port from local machine like `ngrok`

## Step 1: Setup credentials

1. Copy the configs template
    * For server: `$ cp config-server-sample.yml config-server.yml`
    * For cloud: `$ cp config-cloud-sample.yml config-cloud.yml`
1. Update the values in the respective `.yml` files

## Step 2: Run scripts

### Option 1: via Docker ✅

1. From the root level, run a specific service: `$ docker-compose up --build -d ruby_scripts`
    * The `docker-compose.yml` can be designed to have multiple services that run containers
    with the ability to execute scripts written in different language. 
1. Verify that the container is running: `$ docker ps`
1. To begin using the scripts, SSH into the container: `$ docker exec -it ruby_scripts /bin/bash`
1. (Optional) To terminate the container: `$ docker-compose down`

### Option 2: via local machine

👉 The steps here assume that the language of choice has been installed.

1. Move the generated credentials into the folder containing the scripts.
    * For server: `$ cp config-server.yml ruby/`
    * For cloud: `$ cp config-cloud.yml ruby/`
1.  `$ cd ruby`
1.  `$ bundle install`

# Contributing

Refer [CONTRIBUTING.md](docs/CONTRIBUTING.md)
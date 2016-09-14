---
title: Getting your Ruby on Rails application code into Docker
date: 2016-09-14 16:19 EST
tags:
---

**Objective:** Get a Rails API app Docker-ready so that it can be run via a Docker container.

This week I had to build a Rails API microservice that relays custom error messages to Honeybadger. It's a
self-contained Rails API application, no database, and only one route that accepts inputs, performs some
reformatting, and passes it on to the Honeybadger system. Here is how I got it running in its own Docker container.

#### 1. Put a `Dockerfile` in the project base directory.

```
# Pull the Ruby base image from Dockerhub
FROM ruby:2.3.1
RUN apt-get update

# This is where you are going to put your application code,
# transferring it from the project directory into the Docker image
RUN mkdir /app
WORKDIR /app

# Pull all the dependencies from Rubygems
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

# This line pulls the application code from the project folder and puts it into the Docker image
ADD . /app
```
**/Dockerfile**

Docker images are kind of like Virtual Machine images, but not. I think of them more as a lightweight virtual machine
that the Docker team has slimmed down by removing a lot of the bells and whistles that come in a full OS. If you look
at the Dockerfiles of most repositories on Dockerhub, they are all just descendants of a few base systems. For example,
looking at the [Ruby 2.3 Dockerfile](https://github.com/docker-library/ruby/blob/2d6449f03976ededa14be5cac1e9e070b74e4de4/2.3/Dockerfile)
you will see that it's built on another Docker image called [buildpack-deps/jessie](https://hub.docker.com/_/buildpack-deps/),
which several layers deeper pulls from the `debian:jessie` base image. In this project, we are taking the `ruby:2.3.1`
prepackaged image from Dockerhub and adding another layer of configuration to it.

#### 2. Make a `docker-compose.yml` file to more easily run the application.

```
version: '2'
services:
  web:
    build: .
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    environment:
      - HONEYBADGER_API_KEY=${HONEYBADGER_API_KEY}
    ports:
      - "3000:3000"
```
**/docker-compose.yml**

It can take some tedious command line options to run a Docker image the way you want it. To simplify that work there's
`docker-compose`. So in this file I have the configuration for running the application saved so that I don't have to
specify it every time on the command line. It tells Docker which command to run that will start the Rails server,
maps my ports from the host machine to the container, and set the environment variables.

Notice that I can pull an environment variable from the host machine by using the `${*environment_variable_name*}`
format for the value. This is good practice because I can keep the API key a secret - it won't accidentally be committed anywhere on Github where
a malicious person can steal it. I can also change the API key on the server without having to modify any code.

If I had the need for additional dependencies such as a postgres database, I could specify them here in the compose
file.

#### 3. Run the application

At the command line all you have to do is:
`$ docker-compose up -d`

It will automatically build the image and run the container. The `-d` flag has it run in the background so that
I can have the command line back. But if you ran it without the `-d` flag, this is what the output should look like:

```
$ docker-compose up
Building web
Step 1 : FROM ruby:2.3.1
 ---> 8576862d3442
Step 2 : RUN apt-get update
 ---> Running in 6602693ad6bc
Get:1 http://security.debian.org jessie/updates InRelease [63.1 kB]
Get:2 http://security.debian.org jessie/updates/main amd64 Packages [389 kB]
Ign http://httpredir.debian.org jessie InRelease
Get:3 http://httpredir.debian.org jessie-updates InRelease [142 kB]
Get:4 http://httpredir.debian.org jessie-updates/main amd64 Packages [17.6 kB]
Get:5 http://httpredir.debian.org jessie Release.gpg [2373 B]
Get:6 http://httpredir.debian.org jessie Release [148 kB]
Get:7 http://httpredir.debian.org jessie/main amd64 Packages [9032 kB]
Fetched 9795 kB in 9s (1079 kB/s)
Reading package lists...
 ---> 1f578850fdb9
Removing intermediate container 6602693ad6bc
Step 3 : RUN mkdir /app
 ---> Running in 61f9bf5d0951
 ---> 4c32b4640e6a
Removing intermediate container 61f9bf5d0951
Step 4 : WORKDIR /app
 ---> Running in bdf44232fda8
 ---> 60c1a7381154
Removing intermediate container bdf44232fda8
Step 5 : ADD Gemfile /app/Gemfile
 ---> 1c6ff0d80fb7
Removing intermediate container 33c8bfdbdafb
Step 6 : ADD Gemfile.lock /app/Gemfile.lock
 ---> aa82e7727c4d
Removing intermediate container c6d328043b8b
Step 7 : RUN bundle install
 ---> Running in e8509116977f
Fetching gem metadata from https://rubygems.org/.........
Fetching version metadata from https://rubygems.org/..
Fetching dependency metadata from https://rubygems.org/.
Installing rake 11.2.2

  <omitted for brevity>

Bundle complete! 9 Gemfile dependencies, 58 gems now installed.
Bundled gems are installed into /usr/local/bundle.
 ---> 2d36ee11a6f5
Removing intermediate container e8509116977f
Step 8 : ADD . /app
 ---> 0d686b7bf04e
Removing intermediate container 5d323b8c0044
Successfully built 0d686b7bf04e
WARNING: Image for service web was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Creating honeybadgernotifier_web_1
Attaching to honeybadgernotifier_web_1
web_1  | => Booting Puma
web_1  | => Rails 5.0.0.1 application starting in development on http://0.0.0.0:3000
web_1  | => Run `rails server -h` for more startup options
web_1  | Puma starting in single mode...
web_1  | * Version 3.6.0 (ruby 2.3.1-p112), codename: Sleepy Sunday Serenity
web_1  | * Min threads: 5, max threads: 5
web_1  | * Environment: development
web_1  | * Listening on tcp://0.0.0.0:3000
web_1  | Use Ctrl-C to stop
```

#### 4. Checking that the tests work

I can now console into the running docker container to double check that the test suite passes. First, I open
a bash console with `docker exec -i -t honeybadgernotifier_web_1 /bin/bash` and then I can do whatever I want
from inside that docker container as if I was logged onto that machine. So once I'm in I run the `rspec` command:

```
$ docker exec -i -t honeybadgernotifier_web_1 /bin/bash
Error response from daemon: Container c860eda8947a817c1743ebac9fa3fa282efca41c3ed31e639a41235e2266a11b is not running
$ rspec

Notification API
  POST /api/v1/notification
DEPRECATION WARNING: ActionDispatch::IntegrationTest HTTP request methods will accept only
the following keyword arguments in future Rails versions:
params, headers, env, xhr, as

Examples:

get '/profile',
  params: { id: 1 },
  headers: { 'X-Extra-Header' => '123' },
  env: { 'action_dispatch.custom' => 'custom' },
  xhr: true,
  as: :json
 (called from api_post at /Users/wkotzan/Development/honeybadger_notifier/spec/helpers/api_helper.rb:7)
    relays the message to Honeybadger

HoneybadgerNotifier::Notify
  forward the data through the Honeybadger API gem
  Honeybadger API key configuration
    should not be nil

Finished in 0.30018 seconds (files took 1.08 seconds to load)
3 examples, 0 failures
```

Tests are passing!

## Terminology Tip

Don't forget - A Docker **image** is like a virtual machine that's not running. It's like a computer
hard drive with all the software and configuration in it. A **container** is a running image. You can have more than
one container running at the same time from the same image.


## Additional Resources

[Docker official: Docker Compose and Rails Quickstart](https://docs.docker.com/compose/rails/)

[Docker official: setting environment variables](https://docs.docker.com/engine/reference/commandline/run/#/set-environment-variables-e-env-env-file)

[Thoughtbot: Rails on Docker](https://robots.thoughtbot.com/rails-on-docker)

[Stackoverflow: How to pass environment variables to docker containers](http://stackoverflow.com/questions/30494050/how-to-pass-environment-variables-to-docker-containers)

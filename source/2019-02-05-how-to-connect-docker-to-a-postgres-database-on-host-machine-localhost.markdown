---
title: How to connect Docker to a Postgres database on host machine localhost
date: 2019-02-05
tags:
---

Connecting a Docker application to non-Dockerized Postgres database from is a more complicated task
than you would think. While a Docker container can easily communicate with other containers running on the same machine,
it can't easily find how to connect to the host machine running it. This is because of the way Docker handles 
networking, by isolating the containers on its own virtual network which doesn't include the computer hosting Docker.

A while back I published [How to connect to an external Postgres database from a Docker container](2017-06-01-connecting-to-external-postgres-database-with-docker.html.markdown),
which showed you how to tinker with the settings on your local machine or any other computer in your local network
so that your Dockerized app can connect to Postgres. I've recently discovered an alternative method which is even faster.
Here's how I do it now: 

```yaml
version: '3'

services:
  myapp:
    build: .
    command: "bundle exec rails s"
    environment:
      - DATABASE_URL=${DATABASE_URL} # Connection string to the database goes here
      - PGPASSWORD=${PGPASSWORD}
      - RAILS_ENV=${RAILS_ENV:-development}
      - RAILS_LOG_TO_STDOUT=true
    network_mode: host
    tty: true
```

Notice how in my `docker-compose` the `network_mode` is "host". This value will cause the container to run from the
host's network directly - no isolation of the container onto its own network. That means `localhost` in the container
will point to the `localhost` of your machine. You can then connect to Postgres in the command line from within
the container like this:

```
$ docker-compose run myapp /bin/sh

/app # psql -U postgres -h localhost
psql (10.5, server 9.6.11)
Type "help" for help.

postgres=# 

``` 

Note that it's necessary to specify the `-h localhost` parameter. Also, if you make use of the `PGPASSWORD` environment
variable you can have that set to the database password so that it won't prompt you to type it in.
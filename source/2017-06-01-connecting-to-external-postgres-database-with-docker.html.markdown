---
title: How to connect to an external Postgres database from a Docker container
date: 2017-06-01
tags:
---

You would think something as simple as connecting to a database on the localhost would be a simple task in Docker. 
Unfortunately, accessing resources the local machine requires some special settings because of the obfuscation caused
by Docker's virtual networking. To access the Postgres database on my local machine, I had to route around localhost
and connect to it via the machine's local IP address. The local IP address I pass in using an environment variable
in the docker-compose file like this:

```
version: '3'
services:
  web:
    container_name: myapplication
    build: .
    command: bundle exec rails s -p 3000
    environment:
      - DATABASE_URL=postgres://postgres:postgres@localhost:5432/myapplication
    extra_hosts:
      - localhost:${LOCAL_IP}
    ports:
      - 3030:3000
    tty: true

``` 

In my `.env` file I populated `LOCAL_IP` with my local IP address

```
LOCAL_IP=192.168.1.143
```


I had to make the following change to the `listen_addresses` part of my `postgresql.conf` file in the Postgres data directory:
This enabled Postgres to bind to and listen in on connections coming through the local IP address.

```
#------------------------------------------------------------------------------
# CONNECTIONS AND AUTHENTICATION
#------------------------------------------------------------------------------

# - Connection Settings -

# what IP address(es) to listen on;
listen_addresses = 'localhost,192.168.1.143'
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)

```

I also had to add the following line to `pg_hba.conf`

```
host    all             all             192.168.1.143/32        trust
```
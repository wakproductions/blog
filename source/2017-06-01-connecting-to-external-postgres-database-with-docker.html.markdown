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

The above setting worked on my local Mac, but for my Ubuntu server, I had to implement the change using the
`ALTER SYSTEM` command from within Postgres:

```
postgres-# ALTER SYSTEM SET listen_addresses='localhost,172.0.30.143'
ALTER SYSTEM
postgres-# \q

$ sudo service postgresql restart

$ netstat -ntl
  Active Internet connections (only servers)
  Proto Recv-Q Send-Q Local Address           Foreign Address         State      
  tcp        0      0 172.0.30.143:5432        0.0.0.0:*               LISTEN   <- it's listening on the correct IP now   
  tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN     
  tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
  tcp6       0      0 :::3030                 :::*                    LISTEN     
  tcp6       0      0 :::22                   :::*                    LISTEN   
```


I also had to add the following line to `pg_hba.conf`

```
host    all             all             192.168.1.143/32        trust
```

In case you don't know the Postgres data directory, log into psql and:

```
# show data_directory;

        data_directory        
------------------------------
 /var/lib/postgresql/9.5/main
(1 row)
```

## Gotcha

On my Ubuntu configuration, I had trobule getting the pg_hba.conf to work. That's because I created and edited the
file in the data directory. I found out that the real location of the pg_hba.conf file was:

```
postgres-# SHOW hba_file;
               
               hba_file               
--------------------------------------
 /etc/postgresql/9.5/main/pg_hba.conf
``` 

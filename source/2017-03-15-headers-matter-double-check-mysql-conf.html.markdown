---
title: Headers matter! Check that your MySQL configuration file is valid!
date: 2017-03-15 01:30 EST
tags:
---

This morning I discovered that a mysql database I was given management of was improperly configured. When the
database was built, a series of custom `innodb_*` settings was applied to the `my.cnf` configuration file. This morning
I had a need to change a few settings for performance tuning and discovered that all of these settings were invalid! 
What happened? When the file was originally created the `innodb_*` settings were placed in the wrong section. The
file looked something like this:

```
#
# The MySQL database server configuration file.
#
[client]
port		= 3306
socket		= /var/run/mysqld/mysqld.sock

[mysqld_safe]
socket		= /var/run/mysqld/mysqld.sock
nice		= 0

[mysqld]
user		= mysql
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
port		= 3306
basedir		= /usr
datadir         = /mnt/mysql
tmpdir		= /mnt/mysql/tmp
lc-messages-dir	= /usr/share/mysql
skip-external-locking

key_buffer		= 2048M
max_allowed_packet	= 16M
thread_stack		= 192K
thread_cache_size       = 8
myisam-recover         = BACKUP
query_cache_limit	= 64M
query_cache_size        = 32M
log_error = /var/log/mysql/error.log
expire_logs_days	= 10
max_binlog_size         = 100M

[mysqldump]
quick
quote-names
max_allowed_packet	= 16M

[mysql]

[isamchk]
key_buffer		= 16M

innodb_buffer_pool_size           = 4G
innodb_data_file_path             = ibdata1:10M:autoextend
innodb_file_per_table = 1
innodb_flush_method               = O_DIRECT
innodb_flush_log_at_trx_commit=2
innodb_support_xa = 0

innodb_read_io_threads=8
innodb_write_io_threads=8

!includedir /etc/mysql/conf.d/

```

All of the `innodb_*` settings were placed under the `[isamchk]` section when they should have been placed
under the `[mysqld]` section. As a result, mysql was reading these these settings improperly.

```
MariaDB [(none)]> SHOW VARIABLES LIKE 'innodb%';
+-------------------------------------------+------------------------+
| Variable_name                             | Value                  |
+-------------------------------------------+------------------------+
| innodb_buffer_pool_size                   | 134217728              | <-- NOT 4G
| innodb_data_file_path                     | ibdata1:10M:autoextend |
| innodb_file_per_table                     | OFF                    | <-- NOT using one file per table
| innodb_flush_log_at_trx_commit            | 1                      | <-- NOT 2
| innodb_flush_method                       |                        | <-- NOT set
| innodb_support_xa                         | ON                     | <-- should be OFF
| innodb_read_io_threads                    | 4                      | <-- should be 8
| innodb_write_io_threads                   | 4                      | <-- should be 8
+-------------------------------------------+------------------------+
```

Notably, due to the sheer size of the data to be processed we want this system to have a single InnoDB file per
table... but with these corrupted settings I discovered that all this time the DB was being writting in a single
`ibdata1` file:

```
__AWS_PRODUCTION__ ubuntu@ip-172-31-39-165:~$ ls /mnt/mysql -lh
total 251G
-rw-rw---- 1 mysql mysql  16K Mar 15 15:27 aria_log.00000001
-rw-rw---- 1 mysql mysql   52 Mar 15 15:27 aria_log_control
-rw-r--r-- 1 root  root     0 Feb  6 18:25 debian-5.5.flag
-rw-r--r-- 1 root  root     0 Feb  6 18:33 foo.txt
-rw-rw---- 1 mysql mysql 251G Mar 15 15:27 ibdata1
-rw-rw---- 1 mysql mysql 5.0M Mar 15 15:28 ib_logfile0
-rw-rw---- 1 mysql mysql 5.0M Mar 15 15:24 ib_logfile1
drwx------ 2 root  root   16K Feb  6 18:33 lost+found
drwxr-xr-x 2 mysql root  4.0K Feb  6 18:25 mysql
-rw------- 1 root  root    14 Feb  6 18:25 mysql_upgrade_info
drwx------ 2 mysql mysql 4.0K Feb  6 18:25 performance_schema
drwx------ 2 mysql mysql 4.0K Mar 11 07:39 regdata_production
drwxrwxrwx 2 root  root  4.0K Mar 15 15:28 tmp
```

## Converting the data tables to one-file-per-table

So once I fixed the settings I still had the problem of all of my data being in that single `ibdata1` file when we 
really wanted a single table per file. I found [this article](https://dev.mysql.com/doc/refman/5.6/en/tablespace-enabling.html) which showed that converting each table was as 
easy as running an `ALTER TABLE` statement like this:

```
MariaDB [regdata_production]> ALTER TABLE reporters ENGINE=InnoDB;
Query OK, 249757 rows affected (7.99 sec)              
Records: 249757  Duplicates: 0  Warnings: 0
``` 

Problem solved!

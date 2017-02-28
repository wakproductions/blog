---
title: How to Install Ruby on a Production System with Ansible
date: 2017-02-28 01:30 EST
tags:
---

I recently had to set up a production server to run Ruby. Surprisingly there are many opinions on how to do it. Some
people use RVM or RBenv, but I've been told by other people who have tried that that in a production system the system
hacks those package managers use to get the magic to work can have unintended side effects. For example, RVM's override
of the shell causes problems when trying to use Ruby with UNIX cron jobs.

Doing the build-from-scratch install of system Ruby seems to be the best option for setting up a production server.
[I found this useful blog article](http://robmclarty.com/blog/how-to-setup-a-production-server-for-rails-4), which I'm reposting an excerpt here in case it ever disappears from the Internet. The setup
process should be largely the same for any other versions of Ruby.

### Excerpt from robmclarty.com

I wanted to setup the bleeding edge on this server, so I went with a source code install process for Ruby rather than a pre-existing package. I installed Ruby 2.0 and Rails 4.beta. What I usually do to keep track of my source-code-installed components is create a src directory in my user's home folder inside which I store all my source code folders for compilation, installation, and later, any uninstallation I might need to do.

But before that, I needed to install a few more dependencies so my server environment was ready for it.

```
sudo apt-get install build-essential libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
Next, inside /home/bill/src and got the latest Ruby, decompressed it, configured, compiled, and installed.

wget ftp://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p0.tar.gz
tar xzvf ruby-2.0.0-p0.tar.gz
cd ruby-2.0.0-p0
./configure
make
sudo make install
```

Next, I made a symbolic link from /usr/local/bin/ruby to /usr/bin/ruby because some programs look for it there.

```
sudo ln -s /usr/local/bin/ruby /usr/bin/ruby
The newer Rubies come with rubygems so you don't need to worry about installing that separately anymore. But before installing any new gems (like Rails) it's always a good idea to make sure it's up to date.

sudo gem update --system
Finally, now that there was a convenient beta1 branch for the Rails gem, all I needed to do was install the latest Rails was the following.

sudo gem install rails --version 4.0.0.beta1
```

I encountered some weird issues with rdoc and ri where I had to answer "yes" to overwrite the existing versions. I just went with it since this is a dedicated server and I care more about the app working than some documentation that isn't necessary for me in production. I'm sure this will be fixed in the final release.

Update: @kaspergrubbe gave me a great little tweak so you don't need to specify --no-ri --no-rdoc every time you install a gem in production: just add gem: --no-rdoc --no-ri to ~/.gemrc (create that file if it doesn't already exist) and don't worry about ri or rdoc again in production.

# Throw in some Ansible

I automated these steps using Ansible to install Ruby 2.3.3 on my system. [Here's the playbook.](https://github.com/wakproductions/ansible-examples/blob/master/roles/web/tasks/install_ruby233.yml)
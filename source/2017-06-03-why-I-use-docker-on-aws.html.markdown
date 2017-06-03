---
title: Why I Switched to Docker when Using AWS with Ruby on Rails
date: 2017-06-03
tags:
---

## Why Do I Use Docker?

I am working on a Ruby on Rails app which will soon be up and running on AWS EC2. To my displeasure (as I'm more of an app
developer than DevOps guy), I ran into numerous configuration problems setting up my production server. When building
Ruby I ran into permissions problems with the gems such as:

``
ubuntu@ip-172-30-0-78:~$ gem install bundler
   Fetching: bundler-1.15.0.gem (100%)
   ERROR:  While executing gem ... (Gem::FilePermissionError)
       You don't have write permissions for the /usr/local/lib/ruby/gems/2.4.0 directory.
``

Not to mention unforseen missing dependency problems such as this one when building the gemset:

```
Gem Load Error is: Could not find a JavaScript runtime. See https://github.com/rails/execjs for a list of available runtimes.
```

I could fiddle around for hours fixing these issues, but then what if I had to upgrade Ruby later on or add new
dependencies for new features? The last thing I would want is for my production system to go down due to unforeseen
differences between my development environment and production. Docker gives me a way to ensure consistency between
environments and swap dependencies. 
 



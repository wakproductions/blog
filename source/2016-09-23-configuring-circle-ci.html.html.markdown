---
title: Configuring Circle-CI for the First Time
date: 2016-09-23 10:30 EST
tags:
---

I'm setting up CI for my employer using Circle-CI. Here are some of the issues I'm running into.

1. `bundle install` fails.

On the first run, we got the following error message:

```
bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3
ruby-2.3.1 - #gemset created /opt/circleci/.rvm/gems/ruby-2.3.1@banks
ruby-2.3.1 - #generating banks wrappers|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-.|/-\|/-\|.-\|/-\|/-..
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/dependency.rb:319:in `to_specs': Could not find 'bundler' (>= 0.a) among 6 total gem(s) (Gem::LoadError)
Checked in 'GEM_PATH=/opt/circleci/.rvm/gems/ruby-2.3.1@banks:/opt/circleci/.rvm/gems/ruby-2.3.1@global', execute `gem env` for more information
	from /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/dependency.rb:328:in `to_spec'
	from /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/core_ext/kernel_gem.rb:65:in `gem'
	from /opt/circleci/.rvm/rubies/ruby-2.3.1/bin/bundle:22:in `<main>'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/dependency.rb:319:in `to_specs': Could not find 'bundler' (>= 0.a) among 6 total gem(s) (Gem::LoadError)
Checked in 'GEM_PATH=/opt/circleci/.rvm/gems/ruby-2.3.1@banks:/opt/circleci/.rvm/gems/ruby-2.3.1@global', execute `gem env` for more information
	from /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/dependency.rb:328:in `to_spec'
	from /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/core_ext/kernel_gem.rb:65:in `gem'
	from /opt/circleci/.rvm/rubies/ruby-2.3.1/bin/bundle:22:in `<main>'

bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3  returned exit code 1

Action failed: bundle install
```

The important line is here:

```
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/rubygems/dependency.rb:319:in `to_specs': Could not find 'bundler' (>= 0.a) among 6 total gem(s) (Gem::LoadError)
```

Unfortunately, CI platforms don't always run out of the box very well. You need to tell Circle-CI some basic
setup instructions like to first install bundler. So the remedy for this issue was to create a `circle.yml` file
in my project root that looks like this:

```
  general:
    branches:
      ignore:
        - /^deploy-.*/ # list of branches to ignore
  dependencies:
    pre:
      - gem install bundler -v 1.13.1
  test:
    override:
      - bundle exec rspec
```

Note the `dependencies` section which runs the command to install bundler first. After this change, bundle install
ran correctly.

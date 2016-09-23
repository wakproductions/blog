---
title: Configuring Circle-CI for the First Time
date: 2016-09-23 10:30 EST
tags:
---

I'm setting up CI for my employer using Circle-CI. Here are some of the issues I'm running into.

1\. `bundle install` fails.

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

2\. Loading of the database schema fails (fail at `rake db:create db:schema:load ts:configure ts:index ts:start`)

So the bundle was fixed. Now I was getting a new error:

```
export RAILS_ENV="test"
export RACK_ENV="test"
bundle exec rake db:create db:schema:load ts:configure ts:index ts:start --trace
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
in LoadError rescue statement
** Invoke db:create (first_time)
** Invoke db:load_config (first_time)
** Execute db:load_config
** Execute db:create
** Invoke db:schema:load (first_time)
** Invoke environment (first_time)
** Execute environment
DEPRECATION WARNING: The configuration option `config.serve_static_assets` has been renamed to `config.serve_static_files` to clarify its role (it merely enables serving everything in the `public` folder and is unrelated to the asset pipeline). The `serve_static_assets` alias will be removed in Rails 5.0. Please migrate your configuration files accordingly. (called from block in <top (required)> at /home/ubuntu/banks/config/environments/test.rb:16)
DEPRECATION WARNING: Currently, Active Record suppresses errors raised within `after_rollback`/`after_commit` callbacks and only print them to the logs. In the next version, these errors will no longer be suppressed. Instead, the errors will propagate normally just like in other Active Record callbacks.

You can opt into the new behavior and remove this warning by setting:

  config.active_record.raise_in_transactional_callbacks = true

 (called from block in tsort_each at /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:228)
rake aborted!
ActiveRecord::StatementInvalid: Mysql2::Error: Table 'circle_ruby_test.bank_details' doesn't exist: SHOW FULL FIELDS FROM `bank_details`
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:107:in `_query'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:107:in `block in query'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:106:in `handle_interrupt'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:106:in `query'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:309:in `block in execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_adapter.rb:484:in `block in log'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/notifications/instrumenter.rb:20:in `instrument'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_adapter.rb:478:in `log'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:309:in `execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/mysql2_adapter.rb:231:in `execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:316:in `execute_and_free'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:463:in `columns'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/schema_cache.rb:43:in `columns'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/attributes.rb:93:in `columns'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/model_schema.rb:260:in `column_names'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:232:in `aggregate_column'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:258:in `execute_simple_calculation'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:227:in `perform_calculation'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:133:in `calculate'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:80:in `maximum'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/querying.rb:13:in `maximum'
/home/ubuntu/banks/config/initializers/constants.rb:9:in `<top (required)>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:268:in `load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:268:in `block in load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:240:in `load_dependency'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:268:in `load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:652:in `block in load_config_initializer'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/notifications.rb:166:in `instrument'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:651:in `load_config_initializer'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:616:in `block (2 levels) in <class:Engine>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:615:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:615:in `block in <class:Engine>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:30:in `instance_exec'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:30:in `run'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:55:in `block in run_initializers'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:228:in `block in tsort_each'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:350:in `block (2 levels) in each_strongly_connected_component'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:422:in `block (2 levels) in each_strongly_connected_component_from'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:431:in `each_strongly_connected_component_from'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:421:in `block in each_strongly_connected_component_from'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:44:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:44:in `tsort_each_child'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:415:in `call'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:415:in `each_strongly_connected_component_from'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:349:in `block in each_strongly_connected_component'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:347:in `each'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:347:in `call'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:347:in `each_strongly_connected_component'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:226:in `tsort_each'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:205:in `tsort_each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:54:in `run_initializers'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/application.rb:352:in `initialize!'
/home/ubuntu/banks/config/environment.rb:5:in `<top (required)>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:274:in `require'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:274:in `block in require'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:240:in `load_dependency'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:274:in `require'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/application.rb:328:in `require_environment!'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/application.rb:457:in `block in run_tasks_blocks'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:248:in `block in execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:243:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:243:in `execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:187:in `block in invoke_with_call_chain'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/monitor.rb:214:in `mon_synchronize'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:180:in `invoke_with_call_chain'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:209:in `block in invoke_prerequisites'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:207:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:207:in `invoke_prerequisites'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:186:in `block in invoke_with_call_chain'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/monitor.rb:214:in `mon_synchronize'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:180:in `invoke_with_call_chain'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:173:in `invoke'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:152:in `invoke_task'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:108:in `block (2 levels) in top_level'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:108:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:108:in `block in top_level'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:117:in `run_with_threads'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:102:in `top_level'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:80:in `block in run'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:178:in `standard_exception_handling'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:77:in `run'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/exe/rake:27:in `<top (required)>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rake:23:in `load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rake:23:in `<top (required)>'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli/exec.rb:74:in `load'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli/exec.rb:74:in `kernel_load'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli/exec.rb:27:in `run'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli.rb:332:in `exec'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor/invocation.rb:126:in `invoke_command'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor.rb:359:in `dispatch'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli.rb:20:in `dispatch'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor/base.rb:440:in `start'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli.rb:11:in `start'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/exe/bundle:34:in `block in <top (required)>'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/friendly_errors.rb:100:in `with_friendly_errors'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/exe/bundle:26:in `<top (required)>'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/bin/bundle:23:in `load'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/bin/bundle:23:in `<main>'
Mysql2::Error: Table 'circle_ruby_test.bank_details' doesn't exist
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:107:in `_query'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:107:in `block in query'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:106:in `handle_interrupt'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/mysql2-0.4.4/lib/mysql2/client.rb:106:in `query'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:309:in `block in execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_adapter.rb:484:in `block in log'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/notifications/instrumenter.rb:20:in `instrument'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_adapter.rb:478:in `log'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:309:in `execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/mysql2_adapter.rb:231:in `execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:316:in `execute_and_free'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/abstract_mysql_adapter.rb:463:in `columns'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/connection_adapters/schema_cache.rb:43:in `columns'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/attributes.rb:93:in `columns'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/model_schema.rb:260:in `column_names'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:232:in `aggregate_column'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:258:in `execute_simple_calculation'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:227:in `perform_calculation'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:133:in `calculate'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/relation/calculations.rb:80:in `maximum'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/querying.rb:13:in `maximum'
/home/ubuntu/banks/config/initializers/constants.rb:9:in `<top (required)>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:268:in `load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:268:in `block in load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:240:in `load_dependency'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:268:in `load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:652:in `block in load_config_initializer'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/notifications.rb:166:in `instrument'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:651:in `load_config_initializer'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:616:in `block (2 levels) in <class:Engine>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:615:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/engine.rb:615:in `block in <class:Engine>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:30:in `instance_exec'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:30:in `run'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:55:in `block in run_initializers'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:228:in `block in tsort_each'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:350:in `block (2 levels) in each_strongly_connected_component'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:422:in `block (2 levels) in each_strongly_connected_component_from'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:431:in `each_strongly_connected_component_from'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:421:in `block in each_strongly_connected_component_from'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:44:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:44:in `tsort_each_child'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:415:in `call'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:415:in `each_strongly_connected_component_from'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:349:in `block in each_strongly_connected_component'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:347:in `each'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:347:in `call'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:347:in `each_strongly_connected_component'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:226:in `tsort_each'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:205:in `tsort_each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/initializable.rb:54:in `run_initializers'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/application.rb:352:in `initialize!'
/home/ubuntu/banks/config/environment.rb:5:in `<top (required)>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:274:in `require'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:274:in `block in require'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:240:in `load_dependency'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activesupport-4.2.7/lib/active_support/dependencies.rb:274:in `require'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/application.rb:328:in `require_environment!'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/railties-4.2.7/lib/rails/application.rb:457:in `block in run_tasks_blocks'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:248:in `block in execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:243:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:243:in `execute'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:187:in `block in invoke_with_call_chain'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/monitor.rb:214:in `mon_synchronize'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:180:in `invoke_with_call_chain'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:209:in `block in invoke_prerequisites'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:207:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:207:in `invoke_prerequisites'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:186:in `block in invoke_with_call_chain'
/opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/monitor.rb:214:in `mon_synchronize'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:180:in `invoke_with_call_chain'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/task.rb:173:in `invoke'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:152:in `invoke_task'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:108:in `block (2 levels) in top_level'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:108:in `each'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:108:in `block in top_level'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:117:in `run_with_threads'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:102:in `top_level'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:80:in `block in run'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:178:in `standard_exception_handling'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/lib/rake/application.rb:77:in `run'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rake-11.3.0/exe/rake:27:in `<top (required)>'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rake:23:in `load'
/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rake:23:in `<top (required)>'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli/exec.rb:74:in `load'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli/exec.rb:74:in `kernel_load'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli/exec.rb:27:in `run'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli.rb:332:in `exec'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor/invocation.rb:126:in `invoke_command'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor.rb:359:in `dispatch'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli.rb:20:in `dispatch'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/vendor/thor/lib/thor/base.rb:440:in `start'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/cli.rb:11:in `start'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/exe/bundle:34:in `block in <top (required)>'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/lib/bundler/friendly_errors.rb:100:in `with_friendly_errors'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/gems/bundler-1.13.1/exe/bundle:26:in `<top (required)>'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/bin/bundle:23:in `load'
/opt/circleci/.rvm/gems/ruby-2.3.1@banks/bin/bundle:23:in `<main>'
Tasks: TOP => db:schema:load => environment

export RAILS_ENV="test"
export RACK_ENV="test"
bundle exec rake db:create db:schema:load ts:configure ts:index ts:start --trace
 returned exit code 1

Action failed: rake db:create db:schema:load ts:configure ts:index ts:start
```

Now I think this has to do with `schema.rb` not working. When I first set up this project, I had to do a
MySQL load of the database schema from the production system in order to get my local dev environment working.
Trying to avoid going too far into a rabbit hole, I tried switching the load process from `schema.rb` to 
`structure.sql` by adding the following line to our application's config file:

```
config.active_record.schema_format = :sql
```

I then ran `rake db:structure:dump` and checked the changes into source control. This resolved the database
setup issue in Circle-CI. The CI server was smart enough to know based on the `application.rb` setting, to
use `rake db:structure:load` in its initialization process.

3\. Schema migrations were not populated

I ran into one final issue.

```
bundle exec rspec
DEPRECATION WARNING: The configuration option `config.serve_static_assets` has been renamed to `config.serve_static_files` to clarify its role (it merely enables serving everything in the `public` folder and is unrelated to the asset pipeline). The `serve_static_assets` alias will be removed in Rails 5.0. Please migrate your configuration files accordingly. (called from block in <top (required)> at /home/ubuntu/banks/config/environments/test.rb:16)
DEPRECATION WARNING: Currently, Active Record suppresses errors raised within `after_rollback`/`after_commit` callbacks and only print them to the logs. In the next version, these errors will no longer be suppressed. Instead, the errors will propagate normally just like in other Active Record callbacks.

You can opt into the new behavior and remove this warning by setting:

  config.active_record.raise_in_transactional_callbacks = true

 (called from block in tsort_each at /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:228)
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
[DEPRECATION] `last_comment` is deprecated.  Please use `last_description` instead.
in LoadError rescue statement
DEPRECATION WARNING: The configuration option `config.serve_static_assets` has been renamed to `config.serve_static_files` to clarify its role (it merely enables serving everything in the `public` folder and is unrelated to the asset pipeline). The `serve_static_assets` alias will be removed in Rails 5.0. Please migrate your configuration files accordingly. (called from block in <top (required)> at /home/ubuntu/banks/config/environments/test.rb:16)
DEPRECATION WARNING: Currently, Active Record suppresses errors raised within `after_rollback`/`after_commit` callbacks and only print them to the logs. In the next version, these errors will no longer be suppressed. Instead, the errors will propagate normally just like in other Active Record callbacks.

You can opt into the new behavior and remove this warning by setting:

  config.active_record.raise_in_transactional_callbacks = true

 (called from block in tsort_each at /opt/circleci/ruby/ruby-2.3.1/lib/ruby/2.3.0/tsort.rb:228)
bundler: failed to load command: rspec (/home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rspec)
ActiveRecord::PendingMigrationError: 

Migrations are pending. To resolve this issue, run:

	bin/rake db:migrate RAILS_ENV=test


  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/migration.rb:392:in `check_pending!'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/migration.rb:405:in `load_schema_if_pending!'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/migration.rb:411:in `block in maintain_test_schema!'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/migration.rb:642:in `suppress_messages'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/migration.rb:416:in `method_missing'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/activerecord-4.2.7/lib/active_record/migration.rb:411:in `maintain_test_schema!'
  /home/ubuntu/banks/spec/rails_helper.rb:18:in `<top (required)>'
  /home/ubuntu/banks/spec/controllers/admin/crawl_status_controller_spec.rb:1:in `require'
  /home/ubuntu/banks/spec/controllers/admin/crawl_status_controller_spec.rb:1:in `<top (required)>'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/configuration.rb:1058:in `load'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/configuration.rb:1058:in `block in load_spec_files'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/configuration.rb:1058:in `each'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/configuration.rb:1058:in `load_spec_files'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/runner.rb:97:in `setup'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/runner.rb:85:in `run'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/runner.rb:70:in `run'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/lib/rspec/core/runner.rb:38:in `invoke'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/gems/rspec-core-3.0.4/exe/rspec:4:in `<top (required)>'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rspec:23:in `load'
  /home/ubuntu/banks/vendor/bundle/ruby/2.3.0/bin/rspec:23:in `<top (required)>'
Coverage report generated for RSpec to /home/ubuntu/banks/coverage. 165 / 710 LOC (23.24%) covered.

bundle exec rspec returned exit code 1
```

I found out that this was caused by the `schema_migrations` table not being populated on my local development 
system. As mentioned above, when I initially set up my local environment, I was given a data dump of the schema 
to get my database up and running. This lacked the migration numbers. I pulled the data from the `schema_migrations`
table from another environment, rebuilt `structure.sql` using `rake db:migrate`, and pushed out the changes.
The test suite ran!   
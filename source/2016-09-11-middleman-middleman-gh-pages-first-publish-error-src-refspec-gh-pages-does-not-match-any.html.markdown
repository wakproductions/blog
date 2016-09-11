---
title: "Receiving 'error: src refspec gh-pages does not match any' on first publish with Middleman/middleman-gh-pages"
date: 2016-09-11 00:59 EST
tags:
---

1. Created blank repository for new blog website using Middleman, Github Pages, and the `middleman-gh-pages` gem.
2. Tried to upload my blog for the first time using the following sequence of commands and received the following error:

```
 (master)$ git init
 (master)$ git add . 
 (master)$ git commit -m "Initial commit; first blog post" 
 (master)$ remote add origin git@github.com:wakproductions/blog.git 
 (master)$ rake publish  
cd /Users/wkotzan/Development/wakproductions-tech-blog
cd -
cd /Users/wkotzan/Development/wakproductions-tech-blog/build
git init
Initialized empty Git repository in /Users/wkotzan/Development/wakproductions-tech-blog/build/.git/
git remote add origin git@github.com:wakproductions/blog.git
git fetch --depth 1 origin gh-pages
fatal: Couldn't find remote ref gh-pages
rake aborted!
Command failed with status (128): [git fetch --depth 1 origin gh-pages...]
/Users/wkotzan/.rvm/gems/ruby-2.3.0/gems/middleman-gh-pages-0.3.0/lib/middleman-gh-pages/tasks/gh-pages.rake:42:in `block (2 levels) in <top (required)>'
/Users/wkotzan/.rvm/gems/ruby-2.3.0/gems/middleman-gh-pages-0.3.0/lib/middleman-gh-pages/tasks/gh-pages.rake:39:in `block in <top (required)>'
/Users/wkotzan/.rvm/gems/ruby-2.3.0/gems/rake-11.2.2/exe/rake:27:in `<top (required)>'
/Users/wkotzan/.rvm/gems/ruby-2.3.0/bin/ruby_executable_hooks:15:in `eval'
/Users/wkotzan/.rvm/gems/ruby-2.3.0/bin/ruby_executable_hooks:15:in `<main>'
Tasks: TOP => publish => sync_build_dir => prepare_build_dir => /Users/wkotzan/Development/wakproductions-tech-blog/build/.git/refs/remotes/origin/gh-pages
(See full trace by running task with --trace) 
```

This error occurs because you need to have the gh-pages branch existing already. Fixed the error by creating the branch:

```
 (master)$ git checkout -b gh-pages
Switched to a new branch 'gh-pages'
 (gh-pages)$ git checkout master
Switched to branch 'master'
 (master)$ rake publish
 
```

The publish operation then worked.
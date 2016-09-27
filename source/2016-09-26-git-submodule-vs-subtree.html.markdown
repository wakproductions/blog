---
title: Git Submodule vs. Subtree
date: 2016-09-26 10:30 EST
tags:
---

**"Shared Repo"** refers to the code which is shared and will be packaged in a submodule or subtree.
**"Parent Project Repo"** refers to the project that is going to be including the *Shared Repo* as
a submodule or subtree. 

## Overview

### Submodule

Submodules behave like a separate repo within your parent repo. When you are in the submodule directory,
you can use Git commands as if you were working on the submodule repo directly. The parent repo only 
tracks the version of the submodule currently loaded by its commit hash. The parent repo therefore
only stays in sync with the shared repo via this reference. Any changes made within the submodule
directory cannot be committed by the parent repo. You have to go into the submodule directory and 
commit/push them from the shared repo.

### Subtree

Subtree is just a set of macros that simplify Git tricks for merging a secondary shared code repo
into your parent project.

## Initialization

### Submodule

To start the submodule, it's kind of like cloning another git repo: 
`git submodule add <repo> <destination-dir>`. 

Example:
```
 (master)$ git submodule add git@github.com:wakproductions/gitsub-submodule.git lib/gitsub-submodule
Cloning into '/Users/wkotzan/Development/gitsub-base/lib/gitsub-submodule'...
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.

 (master)$ git status
On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   .gitmodules
	new file:   lib/gitsub-submodule

 (master)$ cat .gitmodules
[submodule "lib/gitsub-submodule"]
	path = lib/gitsub-submodule
	url = git@github.com:wakproductions/gitsub-submodule.git

 (master)$ git diff

 (master)$ git diff --cached
diff --git a/.gitmodules b/.gitmodules
new file mode 100644
index 0000000..dfc8421
--- /dev/null
+++ b/.gitmodules
@@ -0,0 +1,3 @@
+[submodule "lib/gitsub-submodule"]
+       path = lib/gitsub-submodule
+       url = git@github.com:wakproductions/gitsub-submodule.git
diff --git a/lib/gitsub-submodule b/lib/gitsub-submodule
new file mode 160000
index 0000000..9dd60f8
--- /dev/null
+++ b/lib/gitsub-submodule
@@ -0,0 +1 @@
+Subproject commit 9dd60f8fc47f089dd5081a0ed73efb7cc923fd9c
```

### Subtree

Use `git subtree add --prefix <dest-dir> <remote-name> <remote-branch>`

```
 (master)$ git remote add subtree-origin git@github.com:wakproductions/gitsub-subtree.git
 (master)$ git subtree add --prefix lib/github-subtree subtree-origin master
git fetch subtree-origin master
warning: no common commits
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
From github.com:wakproductions/gitsub-subtree
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> subtree-origin/master
Added dir 'lib/github-subtree'

```

## How to Pull Changes from Shared Repo into Parent Project Repo

### Submodule

You can work in the submodule as if it were its own Git Repo. First you have to go into the submodule
directory:

`cd lib/gitsub-submodule && git fetch && git merge origin/master`

Example:

```
 (master)$ git fetch
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
From github.com:wakproductions/gitsub-submodule
   9dd60f8..e3bedf9  master     -> origin/master
 (master)$ git merge origin/master
Updating 9dd60f8..e3bedf9
Fast-forward
 submodule-library.rb | 4 ++++
 1 file changed, 4 insertions(+)
 (master)$ git log
commit e3bedf9137028aa63dd88ff1e708ce08e921cc99
Author: Winston Kotzan <wak@wakproductions.com>
Date:   Mon Sep 26 15:40:17 2016 -0400

    Add change to shared repo

commit 9dd60f8fc47f089dd5081a0ed73efb7cc923fd9c
Author: Winston Kotzan <wak@wakproductions.com>
Date:   Wed Sep 21 10:25:56 2016 -0400

    First commit - submodule
```

You also need to update the parent repo:

```
 (master)$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)

	modified:   lib/gitsub-submodule (new commits, modified content)

 (master)$ git diff
diff --git a/lib/gitsub-submodule b/lib/gitsub-submodule
index 9dd60f8..e3bedf9 160000
--- a/lib/gitsub-submodule
+++ b/lib/gitsub-submodule
@@ -1 +1 @@
-Subproject commit 9dd60f8fc47f089dd5081a0ed73efb7cc923fd9c
+Subproject commit e3bedf9137028aa63dd88ff1e708ce08e921cc99
```

** Note that the commit reference in the submodule has changed and needs to be committed in the parent repo**

```
 (master)$ gc "Update submodule"
On branch master
[master 673e460] Update submodule
 1 file changed, 1 insertion(+), 1 deletion(-)
```

A disadvantage of using submodules is that your commit history will get dirty with "Update submodule" style commits
in the parent project repo. See caveats section below for more details.

### Subtree

It works very similar to a Git fetch/merge or pull.

```
 (master)$ git subtree pull --prefix lib/github-subtree subtree-origin master
remote: Counting objects: 3, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 3 (delta 0), pack-reused 0
Unpacking objects: 100% (3/3), done.
From github.com:wakproductions/gitsub-subtree
 * branch            master     -> FETCH_HEAD
   5f12af3..b7631b5  master     -> subtree-origin/master
Merge made by the 'recursive' strategy.
 lib/github-subtree/subtree-library.rb | 4 ++++
 1 file changed, 4 insertions(+)
```

## How to Push Changes from Parent Project Repo to Shared Repo 

### Submodule

What happens if you modify the code in the submodule from the parent project? It labels that commit
pointer as "dirty", and you can't commit the change from the parent repo.

```
 (master)$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)

	modified:   lib/gitsub-submodule (modified content)

no changes added to commit (use "git add" and/or "git commit -a")
 (master)$ git diff
diff --git a/lib/gitsub-submodule b/lib/gitsub-submodule
--- a/lib/gitsub-submodule
+++ b/lib/gitsub-submodule
@@ -1 +1 @@
-Subproject commit e3bedf9137028aa63dd88ff1e708ce08e921cc99
+Subproject commit e3bedf9137028aa63dd88ff1e708ce08e921cc99-dirty
 (master)$ git add .
 (master)$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)

	modified:   lib/gitsub-submodule (modified content)

no changes added to commit (use "git add" and/or "git commit -a")
```

You have to go into the submodule directory and work with it there. In this case, I'm going to make a new
branch/pull request for the submodule.

```
 (master)$ cd lib/gitsub-submodule
 (master)$ pwd
/Users/wkotzan/Development/gitsub-base/lib/gitsub-submodule
 (master)$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   submodule-library.rb

no changes added to commit (use "git add" and/or "git commit -a")
 (master)$ git diff
diff --git a/submodule-library.rb b/submodule-library.rb
index 07692ef..fc6589a 100644
--- a/submodule-library.rb
+++ b/submodule-library.rb
@@ -5,7 +5,11 @@ class MySubmoduleLibrary
   end
 
   def code_change_in_shared_repo
-    puts "This code was added from the shared repo"
+    puts "This code was modified from the parent repo"
+  end
+
+  def code_change_from_parent_repo
+    puts "This code was added from the parent repo"
   end
 
 end
\ No newline at end of file
 (master)$ git stash
Saved working directory and index state WIP on master: e3bedf9 Add change to shared repo
HEAD is now at e3bedf9 Add change to shared repo
 (master)$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working tree clean
 (master)$ git checkout -b changes_from_parent_repo
Switched to a new branch 'changes_from_parent_repo'
 (changes_from_parent_repo)$ git stash pop
On branch changes_from_parent_repo
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   submodule-library.rb

no changes added to commit (use "git add" and/or "git commit -a")
Dropped refs/stash@{0} (b0c7a7936dda06e25049f121207eff7599d084f7)
 (changes_from_parent_repo)$ git add .
 (changes_from_parent_repo)$ git commit -m "New method and modifications from parent repo"
[changes_from_parent_repo 60c13b2] New method and modifications from parent repo
 1 file changed, 5 insertions(+), 1 deletion(-)
 (changes_from_parent_repo)$ git push origin changes_from_parent_repo
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 379 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local objects.
To github.com:wakproductions/gitsub-submodule.git
 * [new branch]      changes_from_parent_repo -> changes_from_parent_repo
 (changes_from_parent_repo)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.

****** CHANGES IN BRANCH changes_from_parent_repo MERGED VIA PULL REQUEST ****** 

 (master)$ git pull
remote: Counting objects: 1, done.
remote: Total 1 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (1/1), done.
From github.com:wakproductions/gitsub-submodule
   e3bedf9..f34c1aa  master     -> origin/master
Updating e3bedf9..f34c1aa
Fast-forward
 submodule-library.rb | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)
```

### Subtree

By opening a new branch, when you push it up you can merge it into the shared repo just like any other
pull request.

```
 (master)$ git checkout -b backported_changes_to_subtree
Switched to a new branch 'backported_changes_to_subtree'
 (backported_changes_to_subtree)$ git status
On branch backported_changes_to_subtree
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   lib/github-subtree/subtree-library.rb

no changes added to commit (use "git add" and/or "git commit -a")
 (backported_changes_to_subtree)$ git diff
diff --git a/lib/github-subtree/subtree-library.rb b/lib/github-subtree/subtree-library.rb
index efb4e2b..e5a2916 100644
--- a/lib/github-subtree/subtree-library.rb
+++ b/lib/github-subtree/subtree-library.rb
@@ -4,8 +4,8 @@ class MySubTree
     puts "hello from subtree"
   end
 
-  def update_from_subtree_project
-    puts "this is an update from the subtree project"
+  def update_from_parent_project
+    puts "this is an update from the parent project"
   end
 
 end
\ No newline at end of file
 (backported_changes_to_subtree)$ git add .
 (backported_changes_to_subtree)$ git commit -m "Implement modification to subtree"
[backported_changes_to_subtree 672332e] Implement modification to subtree
 1 file changed, 2 insertions(+), 2 deletions(-)
 (backported_changes_to_subtree)$ git subtree push --prefix lib/github-subtree subtree-origin backported_changes_to_subtree
git push using:  subtree-origin backported_changes_to_subtree
Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 336 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local objects.
To github.com:wakproductions/gitsub-subtree.git
 * [new branch]      8f79e421908a5d2ab2e6554c6b4535e5b5a83bac -> backported_changes_to_subtree
```

## Submodule Caveats

* When you clone such a project with submodules, by default you get the directories 
  that contain submodules, but none of the files within them yet. (https://git-scm.com/book/en/v2/Git-Tools-Submodules)
  To get around this, either do `git clone --recursive` or do `git submodule init && git submodule update` after the 
  clone.
* A disadvantage of using submodules is that your commit history will get dirty with "Update submodule" style commits
  in the parent project repo. You won't have specific information on the version bumps happening within the submodule.
  One of the things that I like about packaging via Ruby gem vs using a library as a submodule is that you can manage
  meaningful version numbers in a Ruby gem whereas all you have to go by in a submodule is a commit hash. This could
  make it difficult to track the changes to the shared repo that breaks other systems dependent on it. Let's say you make
  a change to a shared repo, then updated other projects using that shared repo. Things break in those other projects.
  How do you roll back? How do you identify which version of the shared repo each of your projects is running on?
* When using CI, some additional configuration may be needed: https://circleci.com/docs/external-resources/
  https://circleci.com/docs/configuration/#checkout
* In comparison to subtree, there's an extra step in that you have to commit your updates to the submodule
  and then go into the parent repository and make another commit to update the submodule reference. So
  every update to the submodule consists of a two-step process.
 
## Subtree Caveats

* Because subtree is based on a combination of other Git routines, the command sequences are less
  straightforward.
* I recommend immediately pushing up any changes in the subtree because if you make a lot of changes
  to the parent repo and forget about updating the shared repo origin of the subtree, then you'll eventually
  end up with a very large pull request with a lot of divergence in the shared repo. 
  
## Subtree Advantages

* The subtree code is considered a part of the parent repository, so you don't require special configuration
  the way you do with a submodule.

## Resources

* https://medium.com/@porteneuve/mastering-git-subtrees-943d29a798ec#.zias44kio  
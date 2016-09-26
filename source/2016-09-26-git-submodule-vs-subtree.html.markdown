---
title: Git Submodule vs. Subtree
date: 2016-09-26 10:30 EST
tags:
---

**"Shared Repo"** refers to the code which is shared and will be packaged in a submodule or subtree.
**"Parent Project Repo"** refers to the project that is going to be including the *Shared Repo* as
a submodule or subtree. 

## 1. How to Pull Changes from Shared Repo into Parent Project Repo

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
Changes not staged for commit:
  modified:   lib/gitsub-submodule (new commits)

no changes added to commit

```

A disadvantage of using submodules is that your commit history will get dirty with "Update submodule" style commits
in the parent project repo. You won't have specific information on the version bumps happening within the submodule.

One of the things that I like about packaging via Ruby gem vs using a library as a submodule is that you can manage
meaningful version numbers in a Ruby gem whereas all you have to go by in a submodule is a commit hash. This could
make it difficult to track the changes to the shared repo that breaks other systems dependent on it. Let's say you make
a change to a shared repo, then updated other projects using that shared repo. Things break in those other projects.
How do you roll back? How do you identify which version of the shared repo each of your projects is running on?


## 2. How to Push Changes from Parent Project Repo to Shared Repo 


## Submodule Caveats

* When you clone such a project with submodules, by default you get the directories 
  that contain submodules, but none of the files within them yet. (https://git-scm.com/book/en/v2/Git-Tools-Submodules)
  To get around this, either do `git clone --recursive` or do `git submodule init && git submodule update` after the 
  clone.
  
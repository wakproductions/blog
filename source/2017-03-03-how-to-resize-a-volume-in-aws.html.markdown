---
title: How to Resize a Volume in AWS
date: 2017-03-03 01:30 EST
tags:
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/1Brbqkzqvjw" frameborder="0" allowfullscreen></iframe>

# Useful Unix Commands

`$ df -h` - gives the disk usage

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            7.5G   12K  7.5G   1% /dev
tmpfs           1.5G  392K  1.5G   1% /run
/dev/xvda1      7.8G  5.9G  1.6G  80% /
none            4.0K     0  4.0K   0% /sys/fs/cgroup
none            5.0M     0  5.0M   0% /run/lock
none            7.5G     0  7.5G   0% /run/shm
none            100M     0  100M   0% /run/user
/dev/xvdc       296G  136G  147G  49% /mnt/mysql
```

`$ sudo file -s /dev/xvd*` - gives information about the available volumes

```
$ sudo file -s /dev/xvd*
/dev/xvda:  x86 boot sector
/dev/xvda1: Linux rev 1.0 ext4 filesystem data, UUID=240ad8b1-c46c-4ed6-b233-02b4d2a7ede3, volume name "cloudimg-rootfs" (needs journal recovery) (extents) (large files) (huge files)
/dev/xvdb:  FoxPro FPT, blocks size 0, next free block index 1664118375
/dev/xvdc:  Linux rev 1.0 ext4 filesystem data, UUID=72ebf16a-eedc-432a-9364-1e4a9f311aad (needs journal recovery) (extents) (large files) (huge files)
``` 

`$ sudo resize2fs /dev/xvda1` - expands the given volume xvda1 to take up the newly allocated space (works only on ext4) file system

```
$ sudo resize2fs /dev/xvdc
resize2fs 1.42.9 (4-Feb-2014)
Filesystem at /dev/xvdc is mounted on /mnt/mysql; on-line resizing required
old_desc_blocks = 19, new_desc_blocks = 69
The filesystem on /dev/xvdc is now 288358400 blocks long.
```
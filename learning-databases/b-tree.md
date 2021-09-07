B Tree

https://en.m.wikipedia.org/wiki/B-tree

https://ysangkok.github.io/js-clrs-btree/btree.html

http://ysangkok.github.io/js-clrs-btree/btree.html#{%22actions%22:[[%22initTree2%22,{%22keys%22:[1,2,3]}],[%22insert%22,4],[%22insert%22,5],[%22insert%22,6],[%22insert%22,7]]}

https://www.cs.usfca.edu/~galles/visualization/BTree.html

https://cis.stvincent.edu/html/tutorials/swd/btree/btree.html

---

I was looking at this video to understand some basics

https://www.youtube.com/watch?v=TOb1tuEZ2X4

It was good!

This is another nice video - https://youtu.be/aZjYr87r1b8 !

Some questions on the top of my mind
- How are disk blocks and files related? Since everything on systems are stored in the form of files on the disk [Question]
- What is the size of the disk block on a system? How do I find it? For example on Linux, or MacOS, or Windows. [Question]
- Do Databases find the system's disk block size? and then accordingly store the data on the disk? Using files that is [Question]
- Is disk block based on the disk? or the system? Like, operating system / kernel. Or is it based on the file system? [Question]
- Do databases store all their data in a single file? [Question]

I'm also wondering how databases work on data concurrently, I mean, if there are multiple cores used by the database program, or if there are multiple instances of the database program each using one core, or even multiple cores. Things seem to get pretty complicated. I guess multiple instances of the database program would mean a distributed system, and hence a distributed database. For one database program using multiple cores and all data in the same system - I'm wondering how requests are concurrently handled. How things work, like locks, transactions etc. There are also different kinds of transactions - 2 phase commit etc etc. Sounds pretty complicated to do all of that stuff when you have to first read from the disk and store it in memory and also ensure that the data is not dirty - some other request updating it concurrently on the disk after finishing processing in the memory. Phew.

---

Block size stuff!

https://duckduckgo.com/?t=ffab&q=linux+block+size&ia=web

https://unix.stackexchange.com/questions/52215/determine-the-size-of-a-block-device#52223

https://duckduckgo.com/?t=ffab&q=macos+block+size&ia=web

https://apple.stackexchange.com/questions/78802/what-are-the-sector-sizes-on-mac-os-x#78810

```bash
database-stuff $ docker run -it ubuntu bash
root@485e801c573f:/# bl
blkdiscard  blkid       blkzone     blockdev    
root@485e801c573f:/# bl
blkdiscard  blkid       blkzone     blockdev    
root@485e801c573f:/# blockdev --getsize64 /dev/
console  fd/      mqueue/  ptmx     random   stderr   stdout   urandom  
core     full     null     pts/     shm/     stdin    tty      zero     
root@485e801c573f:/# blockdev --getsize64 /dev/^C
root@485e801c573f:/# df -H
Filesystem      Size  Used Avail Use% Mounted on
overlay         127G  6.5G  114G   6% /
tmpfs            68M     0   68M   0% /dev
tmpfs           5.3G     0  5.3G   0% /sys/fs/cgroup
shm              68M     0   68M   0% /dev/shm
/dev/vda1       127G  6.5G  114G   6% /etc/hosts
tmpfs           5.3G     0  5.3G   0% /proc/acpi
tmpfs           5.3G     0  5.3G   0% /sys/firmware
root@485e801c573f:/# blockdev --getsize64 /dev/
blockdev: ioctl error on BLKGETSIZE64: Inappropriate ioctl for device
root@485e801c573f:/# blockdev --getsize64 /dev/vda1
blockdev: cannot open /dev/vda1: No such file or directory
root@485e801c573f:/# blockdev --getsize64 /        
blockdev: ioctl error on BLKGETSIZE64: Inappropriate ioctl for device
root@485e801c573f:/# blockdev --getsize64 /sys/firmware/
blockdev: ioctl error on BLKGETSIZE64: Inappropriate ioctl for device
root@485e801c573f:/# blockdev --getsize64 overlay
blockdev: cannot open overlay: No such file or directory
root@485e801c573f:/# exit
database-stuff $ diskutil info / | grep "Block Size"
   Device Block Size:         4096 Bytes
   Allocation Block Size:     4096 Bytes
database-stuff $ 
```

I couldn't find the block size on Linux because of some issues

I had asked `Is disk block based on the disk? or the system? Like, operating system / kernel. Or is it based on the file system?` [Question]

So, to answer my question about block size and whose property / attribute it is - it is the attribute of a file system. At least that's what I just read. For example over here

https://alvinalexander.com/misc/how-determine-macos-linux-filesystem-block-size/

```bash
database-stuff $ docker run --rm -it ubuntu bash
root@308461b97da6:/# echo foo > food
root@308461b97da6:/# du -sh .
root@308461b97da6:/# du -sh food 
4.0K	food
root@308461b97da6:/# 
```

```bash
database-stuff $ echo a > dummy
database-stuff $ du -sh dummy 
4.0K	dummy
database-stuff $ cat dummy 
a
database-stuff $ 
```

```bash
database-stuff $ diskutil info /
   Device Identifier:         disk1s1s1
   Device Node:               /dev/disk1s1s1
   Whole:                     No
   Part of Whole:             disk1

   Volume Name:               Macintosh HD
   Mounted:                   Yes
   Mount Point:               /

   Partition Type:            41504653-0000-11AA-AA11-00306543ECAC
   File System Personality:   APFS
   Type (Bundle):             apfs
   Name (User Visible):       APFS
   Owners:                    Enabled

   OS Can Be Installed:       No
   Booter Disk:               disk1s3
   Recovery Disk:             disk1s4
   Media Type:                Generic
   Protocol:                  PCI-Express
   SMART Status:              Verified
   Volume UUID:               FD65E785-A6E2-43D2-A121-7FF5FA007DDC
   Disk / Partition UUID:     FD65E785-A6E2-43D2-A121-7FF5FA007DDC

   Disk Size:                 1.0 TB (1000240963584 Bytes) (exactly 1953595632 512-Byte-Units)
   Device Block Size:         4096 Bytes

   Container Total Space:     1.0 TB (1000240963584 Bytes) (exactly 1953595632 512-Byte-Units)
   Container Free Space:      856.3 GB (856271474688 Bytes) (exactly 1672405224 512-Byte-Units)
   Allocation Block Size:     4096 Bytes

   Media OS Use Only:         No
   Media Read-Only:           Yes
   Volume Read-Only:          Yes (read-only mount flag set)

   Device Location:           Internal
   Removable Media:           Fixed

   Solid State:               Yes
   Hardware AES Support:      Yes

   This disk is an APFS Volume Snapshot.  APFS Information:
   APFS Snapshot Name:        com.apple.os.update-674E036024D932EADEE67F4DEE8D8B74122062574D16919C166D8B2AD0912951
   APFS Snapshot UUID:        FD65E785-A6E2-43D2-A121-7FF5FA007DDC
   APFS Container:            disk1
   APFS Physical Store:       disk0s2
   Fusion Drive:              No
   APFS Volume Group:         5E8C7175-8FD9-481F-943C-4E11DC99E455
   EFI Driver In macOS:       1677141001000000
   Encrypted:                 No
   FileVault:                 Yes
   Sealed:                    Broken
   Locked:                    No

database-stuff $ 
```

This shows some hardware level data and shows block size. Also, https://www.youtube.com/watch?v=aZjYr87r1b8 mentioned that the block size is dependent on the manufacturer - assuming it's the hardware manufacturer, then it must be the disk block size. So, disk's property? 🤔

Wow. I just read this http://www.linuxintro.org/wiki/Blocks,_block_devices_and_block_sizes . It says that there are block sizes for disks, file systems AND kernel ;) Wow.

So, I guess that answers my question with a vague answer that's not yet clear. Funny how I thought kernel might be at play here when I was like "nah, most probably not.."

I'll come back and check more on my question I think!

`Is disk block based on the disk? or the system? Like, operating system / kernel. Or is it based on the file system?` [Question]

---

I was checking how to find the block size when running code, let's say in Golang

https://duckduckgo.com/?t=ffab&q=find+block+size+in+golang&ia=web&iax=qa

Found this small thing https://stackoverflow.com/questions/46558824/how-do-i-get-a-block-devices-size-correctly-in-go#46559181

I was thinking there might be some standard library, like file system, with which I can get the block size in all platforms, with programming language capabilities. But yeah, I don't know what block size all of these are, that I'm seeing

golang standard library - https://duckduckgo.com/?q=golang+file+system+standard+library&t=ffab&ia=web

https://pkg.go.dev/std

https://pkg.go.dev/io/fs@go1.17

https://pkg.go.dev/io/ioutil@go1.17

https://pkg.go.dev/internal/poll@go1.17

https://pkg.go.dev/testing/fstest@go1.17

Hmm, I couldn't find anything when searching for `block`, hmm

---

Some questions I had in mind

What's the hardware disk block size of disks in the cloud? [Question]

Will golang syscall to find block size work in all platforms? Or just Linux? And what block size is it? File system block size? [Question]

What do the different block sizes mean? In disk at hardware level, in file system and in kernel, for example in Linux [Question]

---

https://www.youtube.com/results?search_query=b+tree

https://www.youtube.com/watch?v=UzHl2VzyZS4

https://www.youtube.com/watch?v=UzHl2VzyZS4&list=RDCMUC_ML5xP23TOWKUcc-oAE_Eg&start_radio=1



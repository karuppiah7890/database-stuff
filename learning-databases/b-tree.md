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

https://www.youtube.com/watch?v=a1Z40OC553Y - I'll probably see this later when I have time, I'll pay and join for a month at that time

---

I'm planning to implement a B tree now. I was thinking about how to do it :P lol

I mean, I have seen different ways that people spoke about the "constraints" of a B tree compared to a binary search tree or a simple no constraints tree

The MIT course spoke about a branching factor and had constraints based on that. The other videos I saw had some sort of max count and used some formula to show the max number of elements and stuff

I think the easiest algorithm was - having a maximum degree M - which is the maximum number of children nodes in a B Tree and then the max number of keys in a node is (M-1). As the relationship between number of keys in a node and the number of children of the same node is -

number of keys in the node N = number of children of the node N - 1

or put it differently

number of children of the node N = number of keys in the node N + 1

So, the number of children in the node is always 1 more than the number of keys in the node

All leaves are at the same level - the tree looks balanced based on this

I gotta try some visualizations to ensure that I understand this whole thing right

Okay, I was looking at the MIT class of B-Tree https://www.youtube.com/watch?v=TOb1tuEZ2X4 again

It talks about branching factor. Maybe it's not needed!

Not sure what the M in here https://ysangkok.github.io/js-clrs-btree/btree.html means

Thinking about it, and using the tool here - https://www.cs.usfca.edu/~galles/visualization/BTree.html , I think the following algorithm would simply work -

- Have a max degree defined for the B Tree - this is the upper bound on the max number of keys that a node can have. If M = 3, then a node can have M - 1 keys = 3 - 1 = 2 keys. Since number of keys in the node is constrained, number of children of the node are also constrained from what I understand. So, max number of children for M = 3 is M, which is 3 children

- When inserting, insert after doing a search of where to place the element - so that it's all sorted while we place it. After inserting, check if the upper bound condition is still valid. If not, split the node into two nodes in the middle and pick a middle key - only one middle key if number of keys is odd, there will be two middle keys when number of keys is even, just pick one from the two. Push the middle key to the parent node in the appropriate position. If the parent node is violating the upper bound condition, then keep iterating till all nodes respect the upper bound condition

I think the lower bound condition is also important - especially when we do deletion! If there's no lower bound, then we would have very very less elements. To solve for very low number of elements is the reason why we have merge process as part of deletion. So I guess I need to check how to incorporate lower bound check too, hmm

Also, as part of lower bound on number of children - there's no lower bound for leaf nodes - leaf nodes have 0 children, hence the name leaf node, it's at the leaf, with no children nodes

As part of lower bound on the number of keys - there's no lower bound on the root node. It can have even 1 key, even with large upper bounds on the whole tree for other nodes. Why? This is because when we create the tree, we need to push some nodes up the tree, and end up creating a root node with single key at times, or very few number of keys, and that's like a necessary thing, or else we can't insert into the tree by following a lower bound rule on the number of keys in the root node too, considering the other rules / conditions / constraints we try to maintain

I was checking out a bit of https://www.youtube.com/watch?v=aZjYr87r1b8 too. It just conveys the MIT video formula differently

In MIT video -

B <= number of children in a node (other than leaf node) < 2B

Where B is the branching factor

B - 1 <= number of keys (other than root node) < 2B - 1

In https://www.youtube.com/watch?v=aZjYr87r1b8 it says - minimum number of children = Ceil(M / 2), assuming M denotes the M for M-way search tree. Max number of children is supposed to be M

Clearly M in https://www.youtube.com/watch?v=aZjYr87r1b8 seems to be the branching factor mentioned in MIT video https://www.youtube.com/watch?v=TOb1tuEZ2X4 or at least related to it. So, by just dividing 2 on the left and right hand side of the inequality equation containing B and 2B, we get the B/2 and B, but that would also divide the middle variable by 2, so, clearly, branching factor and M are related proportionally, but not equal though. Kind of like B = M / 2, or M = 2B.

I think I'll choose the MIT video thing and try to use it! :) As that's pretty straight forward. Let me also check wikipedia on what it has to say

I was reading the wikipedia page - https://en.m.wikipedia.org/wiki/B-tree

It also uses `M` kind of notation, but calls it `m` and mentions max / upper bound as `m` and min / lower bound as `[ m /2 ]` where `[]` refers to ceil I think, according to https://www.youtube.com/watch?v=aZjYr87r1b8 .

I guess it's just a form of saying - upper bound is twice the lower bound, at least roughly.

The only interesting thing here is, in case of MIT video - https://www.youtube.com/watch?v=TOb1tuEZ2X4 , it says 2B is the upper bound for number of children and 2B - 1 is the upper bound for number of keys and that when we reach 2B - 1 number of keys in a node, it will have odd number of nodes as it's 2B - 1 and that we can always find a middle element. So, the upper bound on number of keys according to the MIT course is always odd

But in https://www.youtube.com/watch?v=aZjYr87r1b8 and wikipedia page, `m` can be anything - even or odd and accordingly `[ m / 2 ]` will be calculated and there could one or two middle elements when a node overflows and reaches upper bound while adding keys. I do like avoiding all the ceil function and stuff, so I think I might choose the MIT video method and always use 2B as upper bound (excluded upper bound) for number of children, and I'll choose a B value accordingly

I have been using the word upper bound a bit too much in a loose fashion, to denote a max value, but I gotta check if it means the max value is included "<=" or excluded "<", but I guess have been using it for both, lol

I was also thinking about how the insertions happen, and I gotta think about how deletions happen. I mean, let's say we do a split operation during insertion and move an element, that is a key, to the parent node, for this to be done, we need to have a reference to the parent element I think, or else how will we traverse to a node and add a key and find it overflowing (above upper bound) and then go back to parent node for split operation and maybe keep continuing if parent node also overflows due to addition of key and keep doing it until there is no overflow and all conditions of B Tree are satisfied

I was also thinking about creating a SQL or KV store using the B Tree. But I quickly realized there might be enough complexity without any record pointers. So I'll first finish the B Tree with just keys in the node and children node under it with pointers to the children node, but no values along with the keys in any of the nodes - root, internal and leaf nodes

Implementing the B Tree is going to be interesting!

I was also wondering how databases do indexing - if they modify the database file and then modify the index asynchronously in the background or if they do it all at once synchronously as though it's a single unit of work. How does indexing affect insertions of data / records into the table / database. How does it affect client request-response cycle time in a client server architecture of a database

And do database server start and immediately get the complete index into the main memory? What happens when queries are sent to the server before the index is loaded into the memory? Or do servers serve clients only after the index is loaded? Also, can the whole index be loaded into the memory? Hussein Nasser mentioned that Postgres can store 1% of the index in the memory according to Postgres docs, and the 1% constitutes the root node and the internal nodes, excluding the leaf nodes - but that is in the case of B+ tree though, as in B+ tree, values (record pointers) are stored only in leaf nodes but not on root or internal nodes. But I see postgres saying it using B tree - https://www.postgresql.org/docs/13/indexes-types.html . Hmm. I gotta check Hussein's video again. He did mention Postgres uses tuple ID for something and MySQL uses primary key etc. Gotta check if it was mentioned as B Tree in the video too. Looks like it is a B Tree, gotta check more on it

Some information on pages in terms of Postgres - https://www.postgresql.org/docs/13/storage-page-layout.html

Postgres B Tree and B+ Tree - https://en.wikipedia.org/wiki/Talk%3AB%2B_tree , [specific section](https://en.wikipedia.org/wiki/Talk%3AB%2B_tree#PostgreSQL's_use_of_B+_trees) , https://www.postgresql.org/about/ , https://duckduckgo.com/?t=ffab&q=postgres+b+tree&ia=web , https://www.google.com/search?hl=en&q=postgres%20b%20tree , https://www.google.com/search?hl=en&q=postgres%20b%2B%20tree , https://stackoverflow.com/questions/25004505/b-tree-or-b-tree - https://stackoverflow.com/a/25005372/4772008 [TODO]

---

I was also wondering about what pages are since that was mentioned a lot in a lot of places including the https://www.youtube.com/watch?v=UzHl2VzyZS4 video

I also saw a small video - short ones - https://www.youtube.com/watch?v=cll-lsNK_N4 



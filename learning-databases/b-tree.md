#b-tree #btree #b+tree #trees #tree #indexing #index #indexes #indices #multilevel-indexing

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

---

I saw another interesting video today

https://www.youtube.com/watch?v=xprkGzP36TI " Could Conventional B-Trees harm Solid State Drives? " related to B trees and SSDs

It also spoke about Log Structured Merge Tree mainly

---

About B tree implementation, I was thinking about how exactly I'm going to implement if I don't know the low level details

I was wondering about insertion, deletion and even search which is part of insertion and deletion too

I was thinking about space constraints - as I wanted to have the same constraints a modern database would have and I wanted to solve and implement a B tree keeping that in mind. For example - I was thinking the following things

- How will each node look like? Use an array of keys as one field? Array of child pointers as another field? But then while searching, I'll have to lookup the child pointer array to get the child pointer. But, if it's an array, I just the correct index, which is mostly related to the array index of the keys array that I'm traversing to find which key's children (left children, right children) I should be looking at, so it might look something like this when it comes to index of the arrays -

keys array index - 0 1 2
child pointers array index - 0 1 2 3

CPs - Child pointers array
Keys - Keys array

CPs[0] and CPs[1] are left and right children of Keys[0]
CPs[1] and CPs[2] are left and right children of Keys[1]
CPs[2] and CPs[3] are left and right children of Keys[2]

So I guess that's pretty straight forward. Or otherwise, I was thinking of putting keys and child pointers all together in some way. Not easy though!

- Why use arrays for storing keys and child pointers? Why not lists? like linked lists?
- Also, if it's array, should it be like a array of values or array of pointers to values? If it's pointers to values, it's very easy to copy and move around the pointer, during insertions, deletions, which will be pretty small in size. If we copy and move around values, it will take up more space in memory - and this will happen during insertion and deletions when split or merge operations. During insertion with split, we move values up the tree. During deletion, we do merge and there's one more way too. Gotta check on that!
- For getting hold of the nodes, we can use pointers. Especially for root node also - we can use pointer, instead of concrete value variable. As child pointers are also pointers and point to internal and leaf nodes. Having root node also being pointed to using a pointer is easier. Especially when we want to do moving around during insertion, deletion. Also, it takes up less space when doing copy and moving around etc, also, while traversing, the logic is pretty straight forward - every node is pointed by a pointer, and we keep traversing
- For getting hold of a parent node to be able to push keys to the parent node during insertion, as part of the split process, one thing that can be done is - while traversing, we can have two pointers, one pointer pointing to the current node we are traversing / processing, for example, checking the keys in it, another pointer will point to the parent of the current node we are processing. When current node is root node, the parent of the root node would be null, or `nil` in golang :P But at one point I was wondering if it even helps to have the pointer to the parent node. Only while implementing or thinking about it I'll know
- Use linked list instead of arrays for storing keys, child pointers. Put it all in one linked list. How will the structure of linked list look like? Each element in the linked list would have a key and a pointer to the right child. This way, for K keys, we would have K children pointers for all the right children of each key. This way, we store exactly one pointer to a child node, even though in some cases it's both - the left child of one key and also the right child of another key. But if there are K keys, there would be K + 1 children. Right! Since the pointers in linked list have pointer to the right child always, the left children of all keys but one key is taken care of too. For the left most key, the left child node pointer is not store anywhere. This can be store in a separate field. What's the benefit? We store each value / pointer exactly once! So no space is wasted! :D This way, given a fixed memory - we can fit more keys and pointers in each node and even values in each node in the case of B trees. Another alternative that I thought was less efficient - each linked list would contain one key and two pointers - one for the left child and one for the right child. But then, this would store duplicate pointers, a element with a key would be storing the right child in it's right child pointer field and the same child would be stored as left child pointer in the next element. It's almost like we are using up twice the space to store the pointers. Which seems completely unnecessary. I also want to avoid null values in my fields. I think the field does take up some memory even if the value is empty, even if the field is a pointer field. I'm just trying to decrease and remove anything that's possible to keep it small and simple! Not to mention, I have to think about traversal when using a single linked list to store keys and child pointers. I mean, if I'm looking for key 5 and I'm currently at key 4, I can't simply jump into the right child of key 4, I first need to check the next element in the linked list to see if it's 5, if it is 5 then I can stop in case of B tree as I can find the value along with the key, if it's not 5, then I can go back to element with key 4 having right child pointer and traverse from that child. For this reason, I'll need to have a pointer to the current and previous element when traversing the linked list. But it's just two pointers, so, meh

All in all, I need to think more about the exact details of the implementation

I guess I really need to learn more about how efficient systems are made. How programs are written efficiently where performance is squeezed, because databases need to be performant! I need to look at space complexity, time complexity and more things! Space complexity - I didn't check this before much, but now, given that memory is limited and a very very important resource, I need to use it very carefully and get rid of any unnecessary objects whenever possible

Reminds me of this tweet - https://twitter.com/manishrjain/status/1435483231286038534

" Releasing objects when you're done is still the best way to build high performance systems. GCs are great for non-critical path. "

The picture in it has a old lady walking with a stick saying " I used to retain and release my objects " and a helper says " Sure Grandma, let's get you to bed "

More like, retaining objects when not necessary and then releasing the objects later (using GC automatic help I guess? or without it) is just not great and can make things less performant - less memory available, operations could do away with more memory instead, but with less memory operations might be slow

But I'm not sure. Maybe I gotta clarify! But the tweet text clearly says - GC - Garbage Collectors are great for non-critical path - so, you can let GC do the automatic releasing of memory in case of non-critical stuff, but for critical stuff, you gotta own the retaining and releasing of objects I guess

Some interesting comments on this one https://twitter.com/palmin/status/1434941842286686212/

Anyways, I was wondering if I could write the B tree in Golang and write it in an efficient manner and also test it's efficiency using some benchmarking by using lots of data and also checking the memory usage etc. Like, less nodes in the B tree, memory usage should be less, etc, kind of an obvious thing, but if I'm keeping things in memory unnecessarily, then it's not so obvious. For example, if I let GC take care of things but don't know how GC does it or assume it will take care of things but it doesn't for some valid reason, then it's gonna be using a lot of memory even when the tree is too small or say just has one key, though it could have previously had 100 keys or something. Or more ;) Like, millions ;)

Some TODOs that I'm thinking of adding to my list

- Learn how to write efficient programs to implement algorithms - efficient in terms of memory usage (space complexity), time (time complexity) / compute. Programming languages - Golang, Rust!
- Read books and see videos on data structures and algorithms. And also on design and analysis of algorithms!

---

I have started to write some code already! :D

```bash
database-stuff $ code code/b-tree/
database-stuff $ cd code/b-tree/
b-tree $ ls
b_tree.go	b_tree_test.go
b-tree $ go test -v
go: cannot find main module, but found .git/config in /Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff
	to create a module there, run:
	cd ../.. && go mod init
b-tree $ go test -v ./...
go: cannot find main module, but found .git/config in /Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff
	to create a module there, run:
	cd ../.. && go mod init
b-tree $ go mod init github.com/karuppiah7890/database-stuff/code/b-tree
go: creating new go.mod: module github.com/karuppiah7890/database-stuff/code/b-tree
go: to add module requirements and sums:
	go mod tidy
b-tree $ go mod tidy
b-tree $
```

I'm planning to write tests while I implement B trees. To write the test, I need to do operations and be able to check if it was performed right, to verify / test the functionality by checking the output for example

Operations for B-Tree are Insert, Delete, Search. It could also have Update, to Update the value corresponding to a key ;). The Search is only for searching one key, and to return it's value I guess. All operations are on the Tree, with input as key usually

To check if the operation was performed right, I was wondering if I could render the tree in some way and then check if it's all good

One render mechanism is - render it in a line in a sorted manner. But then, the output is always a single line, a sorted one, I cannot say for sure if the final data structure is a tree or not, and if it's balanced or not and if it obeys all the restrictions / conditions or not. It's a whole big thing

I could print the tree as a YAML or JSON! ;) With root node as the top level key and then it's children in the nested value, and then it's children nodes in the nested value and so on and so forth. And then traverse it / process it to test if the positioning of all the keys, values and child pointers and the whole structure is good and is a balanced tree and no violation of any conditions

For JSON, I can customize like this - https://pkg.go.dev/encoding/json#example-package-CustomMarshalJSON I guess

---

I was thinking about the implementation and some of the thoughts I had -

If I use array for storing keys, then I could do random access and do binary search, as keys would be sorted. But, insertion and deletion would be slow, as I'll have to move elements around

If I use linked list, insertion and deletion will be fast, but search will be slow and sequential, as we can't do random access

So, if the tree is write heavy, linked list. If it's read heavy...arrays? Or maybe still linked list?

Also, for making linked list search better, I was thinking about adding a pointer to point to the middle element, and then to some more elements like between first and middle element, and between middle and last element and other middle elements like that. I quickly realized I can't add a pointer to all the elements, that's useless and also too much space (memory) used up. Also, if I add such pointers, it's kind of like indexing the keys inside the root node and if I do this for all nodes, which I was thinking about only later, that would be indexing a lot of nodes, the keys in those nodes. So, it's kind of like adding another level of index or b Tree node but just for the keys in a node, like as if the keys are all separated or something. And this all uses up more space. So I figured linear and sequential search in linked list is fine and that worst case scenario, we will search and reach the right most element if traversing from left to right. Anyways, it's cool to think about all this and try to implement it! I'm also planning to see how others implement b Tree when I have some decent version of a b Tree. Maybe check YouTube video or GitHub repo. I noticed one YouTube video title saying B Tree implemented in C++, I was like "nice!"

---

I was thinking about using Linked List for now and then optimizing more later. But yeah, I could also check other ways to store a list or line of elements

One thing to note is - I was wondering about how the structure would like in the code. When I started writing the code, I named the golang struct as BTree, and I quickly realized it would contain only a node of the tree and then pointers to the children. But I guess it won't make sense to call it just a node as it also has pointers to the children. I think I'm just going to call it BTree only for now

About the Linked List, I was wondering how I would traverse it and how I would insert the keys in the tree. Like, I was thinking how would I know if I need to insert the key in the same node or in the child node. Then I realized that - first, I need to check if there are child pointers. For example, if I have just one node, the root node, with max keys for the node as 4, and if the keys are 6 and 8 and I want to insert 7, I could just traverse and find that 7 is between 6 and 8 and since there are no child pointers as there's only the root node, also the leaf node, I just insert 7 between 6 and 8. Now I check if the conditions of the B Tree are not violated by this node. In this case, it's not. If it is, I'll have to do a split operation. But if there are child pointers let's say, then I would have to traverse to the child pointers and find a position in a node where there are no child pointers and I can insert the key in that node, and then split it in case it violates the B Tree conditions

Come to think of it, inserting and then splitting the node sounds complicated. What if I don't insert and directly insert? That would work if the key I'm going to add is going to be put in the middle of the list of keys. But yeah, if that's note the case, the insertion and then split might be required, as insertion would be at one position in the list, but split would be another position!

Also, for splitting, we need to first know when to split, for which we check the B Tree conditions. The simplest being - check the node in which the key was inserted and see if the node respects the B Tree conditions, for example, check if more than the max number of keys is present in the node, for this we need to find the number of keys - that is the length of the list. If we use arrays to implement the list of keys, it's too easy to find the length. But if we use linked list, we will have to traverse the whole list to find the length. Or, we can store the length separately in a field I guess!

I was also checking out different list implementations, starting with Redis but then didn't dig too much into it

https://matt.sh/redis-quicklist

I guess I'll implement something basic and simple first, and make it work and then try out more by optmizing

Also, I was thinking about - in golang how do I free up pointer memory etc. I was checking this out a bit and noticed some folks mentioning how it's costly to do deferencing of pointers and more. I guess taking care of memory allocation and using pointers is not straight forward and probably comes with a cost depending on the language I use, something to learn more about [TODO]

---

Now to do the implementation, I'm still not sure how to do the testing. Also, funny thing is, for testing other operations, I need to first implement the printing the tree in a JSON format with proper nesting and I need to first test the JSON printing first :P Lol. So, let's do that first maybe ;)

To test the printing, I need to put some data in the Tree, or initialize the tree with some existing data in some way. Both test and code are in the same package, so I can change any field in the tree structure. I was also planning to put all the fields as private / non-exposed fields in the structure, that way, only tests written within the package can access the non-exposed fields in the structure. I could also write the b-tree code in such a way that it can be consumed as a library, but, this is just an experiment. Maybe I could write two test files - one within the package, to test printing, another outside, to test specificall other operations! That makes sense I guess!

I can see a JSON like this here https://ysangkok.github.io/js-clrs-btree/btree.html

```json
{
  "keys": [10, 20, 30],
  "children": [
    { "keys": [1, 2] },
    { "keys": [11, 12] },
    { "keys": [21, 22] },
    { "keys": [31, 32] }
  ]
}
```

I was thinking of having a different JSON. Also, in the above, the traversal of the JSON is more breadth first. I was thinking depth first kind of JSON

```json
{
  "node": {
    "leftMostKeyLeftSubTree": null,
    "keys": [
      {
        "key": 1,
        "rightSubTree": null
      },
      {
        "key": 2,
        "rightSubTree": null
      }
    ]
  }
}
```

a more complex one -

```json
{
  "node": {
    "leftMostKeyLeftSubTree": {
      "leftMostKeyLeftSubTree": null,
      "keys": [
        {
          "key": 1,
          "rightSubTree": null
        }
      ]
    },
    "keys": [
      {
        "key": 2,
        "rightSubTree": {
          "leftMostKeyLeftSubTree": null,
          "keys": [
            {
              "key": 3,
              "rightSubTree": null
            }
          ]
        }
      },
      {
        "key": 4,
        "rightSubTree": {
          "leftMostKeyLeftSubTree": null,
          "keys": [
            {
              "key": 5,
              "rightSubTree": null
            }
          ]
        }
      }
    ]
  }
}
```

Woah. I guess that's pretty complex and takes up too much space, hmm. I think printing breadth first is easier!

I just tried out a complex B tree JSON printing in https://ysangkok.github.io/js-clrs-btree/btree.html and saw this

```json
{
  "keys": [32],
  "children": [
    {
      "keys": [20],
      "children": [
        {
          "keys": [10],
          "children": [{ "keys": [1, 2] }, { "keys": [11, 12] }]
        },
        { "keys": [30], "children": [{ "keys": [21, 22] }, { "keys": [31] }] }
      ]
    },
    {
      "keys": [36],
      "children": [
        { "keys": [34], "children": [{ "keys": [33] }, { "keys": [35] }] },
        {
          "keys": [38, 40],
          "children": [{ "keys": [37] }, { "keys": [39] }, { "keys": [41, 42] }]
        }
      ]
    }
  ]
}
```

Actually, it's not entirely breadth first, more like a mix. But surely compact than what I had in mind. I guess I need to think on how I use the word breadth first and depth first and also how I see the nodes in B Trees. I keep seeing list of keys in a node and keep trying to print them separately. Maybe I should try to just put the whole node - the keys together, and print child nodes separately, like the above

I was just thinking how to print the JSON with the current structure I have. I was also thinking how the JSON printing mechanism is probably going to be very very inefficient, lol. Hmm. Damn, testing is not so easy if not done well I guess. Gotta think if there's a better way to test if operations are done right on the tree and if no conditions are violated. Hmm. Printing seems to be an easy and straight forward way to ensure the tree looks the way it's supposed to look like, hmm

Wow, with my structure, it's also too much work to initialize a tree!

I think it would be nice to take the JSON and initialize the tree 🙈 LOL. I really need to learn some data structures and algorithms again and understand how to implement efficiently and also test this stuff! :D And also learn the traversal and also printing so that it's all easy!

I was also thinking about how to make it easy to give tree data as input, compare trees etc. If I use JSON as tree data, then I have to write code to parse it and convert it to tree structure in code, lol

I was also thinking about simple one line representations without JSON, using `(`, `)` or `[`, `]` to denote tree nodes, keys, maybe represent them differently or same way, etc. But that is hard too, I mean, I could print using `()` and `[]`, but I can't parse all that and spend time to create a tree with that I think. I mean, it will be pretty complex and unncessary at this point. Hmm

```json
{
  "keys": [10, 20, 30],
  "children": [
    { "keys": [1, 2] },
    { "keys": [11, 12] },
    { "keys": [21, 22] },
    { "keys": [31, 32] }
  ]
}
```

```json
{
  "keys": [20],
  "children": [
    { "keys": [10], "children": [{ "keys": [1, 2] }, { "keys": [11, 12] }] },
    {
      "keys": [30],
      "children": [{ "keys": [21, 22] }, { "keys": [31, 32, 33] }]
    }
  ]
}
```

```json
{
  "keys": [20],
  "children": [
    { "keys": [10], "children": [{ "keys": [1, 2] }, { "keys": [11, 12] }] },
    {
      "keys": [30, 32],
      "children": [{ "keys": [21, 22] }, { "keys": [31] }, { "keys": [33, 34] }]
    }
  ]
}
```

Some things I need to take care of while printing - no nil pointer exception. For the current test, there is no nil pointer exception though!

[TODO] Check for nil pointers and only work on non-nil pointers! Maybe write tests for that?!

Okay, I didn't have to write separate test for nil pointer. The single test took care of it! :D

There were multiple hiccups and I had to debug the test to find out the issues and it was all because I didn't handle nil pointers

```bash
b-tree $ go test -v ./...
=== RUN   TestInsert
    b_tree_test.go:11:
--- SKIP: TestInsert (0.00s)
=== RUN   TestMarshalJson
--- FAIL: TestMarshalJson (0.00s)
panic: runtime error: invalid memory address or nil pointer dereference [recovered]
	panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x117c25f]

goroutine 22 [running]:
testing.tRunner.func1.2({0x119b100, 0x132d190})
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1209 +0x24e
testing.tRunner.func1()
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1212 +0x218
panic({0x119b100, 0x132d190})
	/usr/local/Cellar/go/1.17/libexec/src/runtime/panic.go:1038 +0x215
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0x0)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:40 +0x7f
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0xc000062f50)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:51 +0x206
github.com/karuppiah7890/database-stuff/code/b-tree.(*BTree).MarshalJSON(0x1067cc2)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:58 +0x19
github.com/karuppiah7890/database-stuff/code/b-tree.TestMarshalJson(0x0)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree_test.go:73 +0x3e8
testing.tRunner(0xc000122340, 0x11d9b90)
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1259 +0x102
created by testing.(*T).Run
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1306 +0x35a
FAIL	github.com/karuppiah7890/database-stuff/code/b-tree	0.473s
FAIL
b-tree $ go test -v ./...
=== RUN   TestInsert
    b_tree_test.go:11:
--- SKIP: TestInsert (0.00s)
=== RUN   TestMarshalJson
--- FAIL: TestMarshalJson (0.00s)
panic: runtime error: invalid memory address or nil pointer dereference [recovered]
	panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x117c25f]

goroutine 22 [running]:
testing.tRunner.func1.2({0x119b120, 0x132d190})
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1209 +0x24e
testing.tRunner.func1()
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1212 +0x218
panic({0x119b120, 0x132d190})
	/usr/local/Cellar/go/1.17/libexec/src/runtime/panic.go:1038 +0x215
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0x0)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:40 +0x7f
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0xc000062f50)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:53 +0x21a
github.com/karuppiah7890/database-stuff/code/b-tree.(*BTree).MarshalJSON(0x1067cc2)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:60 +0x19
github.com/karuppiah7890/database-stuff/code/b-tree.TestMarshalJson(0x0)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree_test.go:73 +0x3e8
testing.tRunner(0xc00011e680, 0x11d9bb0)
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1259 +0x102
created by testing.(*T).Run
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1306 +0x35a
FAIL	github.com/karuppiah7890/database-stuff/code/b-tree	0.450s
FAIL
b-tree $ go test -v ./...
=== RUN   TestInsert
    b_tree_test.go:11:
--- SKIP: TestInsert (0.00s)
=== RUN   TestMarshalJson
--- FAIL: TestMarshalJson (0.00s)
panic: runtime error: invalid memory address or nil pointer dereference [recovered]
	panic: runtime error: invalid memory address or nil pointer dereference
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x117c256]

goroutine 36 [running]:
testing.tRunner.func1.2({0x119b100, 0x132d190})
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1209 +0x24e
testing.tRunner.func1()
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1212 +0x218
panic({0x119b100, 0x132d190})
	/usr/local/Cellar/go/1.17/libexec/src/runtime/panic.go:1038 +0x215
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0x0)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:40 +0x76
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0xc000111030)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:53 +0x205
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0xc000111020)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:53 +0x205
github.com/karuppiah7890/database-stuff/code/b-tree.BTreeToBTreeJson(0xc000062f50)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:53 +0x205
github.com/karuppiah7890/database-stuff/code/b-tree.(*BTree).MarshalJSON(0x1067cc2)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree.go:60 +0x19
github.com/karuppiah7890/database-stuff/code/b-tree.TestMarshalJson(0x0)
	/Users/karuppiahn/projects/github.com/karuppiah7890/database-stuff/code/b-tree/b_tree_test.go:73 +0x3e8
testing.tRunner(0xc000105ba0, 0x11d9b90)
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1259 +0x102
created by testing.(*T).Run
	/usr/local/Cellar/go/1.17/libexec/src/testing/testing.go:1306 +0x35a
FAIL	github.com/karuppiah7890/database-stuff/code/b-tree	0.381s
FAIL
b-tree $ go test -v ./...
=== RUN   TestInsert
    b_tree_test.go:11:
--- SKIP: TestInsert (0.00s)
=== RUN   TestMarshalJson
    b_tree_test.go:75:
        	Error Trace:	b_tree_test.go:75
        	Error:      	Not equal:
        	            	expected: "{\"keys\":[20],\"children\":[{\"keys\":[10],\"children\":[{\"keys\":[1,2]},{\"keys\":[11,12]}]},{\"keys\":[30,32],\"children\":[{\"keys\":[21,22]},{\"keys\":[31]},{\"keys\":[33,34]}]}]}"
        	            	actual  : "{\"keys\":[20],\"children\":[{\"keys\":[10],\"children\":[{\"keys\":[1,2],\"children\":null},{\"keys\":[11,12],\"children\":null}]},{\"keys\":[30,32],\"children\":[{\"keys\":[21,22],\"children\":null},{\"keys\":[31],\"children\":null},{\"keys\":[33,34],\"children\":null}]}]}"

        	            	Diff:
        	            	--- Expected
        	            	+++ Actual
        	            	@@ -1 +1 @@
        	            	-{"keys":[20],"children":[{"keys":[10],"children":[{"keys":[1,2]},{"keys":[11,12]}]},{"keys":[30,32],"children":[{"keys":[21,22]},{"keys":[31]},{"keys":[33,34]}]}]}
        	            	+{"keys":[20],"children":[{"keys":[10],"children":[{"keys":[1,2],"children":null},{"keys":[11,12],"children":null}]},{"keys":[30,32],"children":[{"keys":[21,22],"children":null},{"keys":[31],"children":null},{"keys":[33,34],"children":null}]}]}
        	Test:       	TestMarshalJson
--- FAIL: TestMarshalJson (0.00s)
FAIL
FAIL	github.com/karuppiah7890/database-stuff/code/b-tree	0.524s
FAIL
b-tree $ go test -v ./...
=== RUN   TestInsert
    b_tree_test.go:11:
--- SKIP: TestInsert (0.00s)
=== RUN   TestMarshalJson
--- PASS: TestMarshalJson (0.00s)
PASS
ok  	github.com/karuppiah7890/database-stuff/code/b-tree	0.422s
b-tree $
```

Finally it works! :D :D

I'm afraid that if I'm testing the B tree with this JSON printing, the printing will take up more memory! LOL. Hmm

Especially for benchmark tests! If I want to ensure that speed and correctness is maintained, it's going to be a bit hard, hmm

I think I can finally start writing test and code for Insert, Search and Delete! :D

Also, I realized that there are currently no checks to tell if the B Tree is obeying all the conditions and is balanced. Once I write Insert, or Delete, I need to start doing that! Also, maybe I could start with Search ;)

As part of testing, I want to do the following
- Test how fast the operations are when I use lots and lots of data - benchmark test
- Test that the B Tree structure is correct for a given data set and the order in which it was inserted. Maybe I could use some online service or some script to get the correct data. But if I write the script, I can't tell if it's correct in case I write the wrong script. Maybe I could use some online service, assuming it works and gives the correct information, and store that in the repo and use it!
- Test that the B Tree structure obeys all the rules - ideally, the second point should take care of this. But I still need this for cases where I...okay, maybe I don't I guess, assuming the full tree data is properly structured in second point for the assertion. Or else, or as an extra thing, we could use an extra checker which checks if the tree obeys all the conditions of a B Tree! :D
- Check the memory usage of the B tree when I use lots and lots of data

Some things to beware of -
- Don't convert to JSON while checking memory usage. JSON conversion is only for checking the final output and that can take a lot of memory. Capture memory usage data only when doing operations - before and after. Ensure no checking of tree structure, or JSON printing and other side work is going on while checking memory usage, or else it's a problem!
- For every insert I do - assuming I can't do batch inserts, or maybe I could, let's see, for every insert, I need to know that the tree is balanced and is obeying the B tree conditions / properties. The full data set of final tree will help only in checking at the end, not in between, or I'll need more data! It's gonna be tricky to check if tree is balanced and also check memory usage. I mean, to check if tree is balanced - a lot of memory will be used I think. Or, I could just check more on how to capture memory and do something like - check memory usage before start of operation and then after end of operation and take the difference, every time, but I don'know if it's thing that will give proper results with proper data
